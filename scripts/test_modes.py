#!/usr/bin/env python3
"""Headless functional tests, or a standalone settings UI: --settings.

Requires PyQt6 and the installed Qt/KDE QML modules. Never installs the package
or changes Plasma configuration. Headless checks do not validate GPU rendering.
"""
import argparse
import math
import os
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--settings', action='store_true')
    args = parser.parse_args()
    if not args.settings:
        os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
        os.environ.setdefault('QT_QUICK_BACKEND', 'software')

    from PyQt6.QtCore import QObject, QUrl, QEvent, QCoreApplication
    from PyQt6.QtWidgets import QApplication
    from PyQt6.QtQml import QQmlComponent, QQmlExpression, QQmlPropertyMap
    from PyQt6.QtQuick import QQuickView, QQuickItem
    from PyQt6.QtTest import QTest

    app = QApplication([])
    view = QQuickView()
    engine = view.engine()
    # Plasma normally supplies these translation functions.
    engine.rootContext().setContextProperty('i18n', engine.evaluate('(function(s) { return s; })'))
    engine.rootContext().setContextProperty('i18nc', engine.evaluate('(function(c,s) { return s; })'))
    warnings = []
    engine.warnings.connect(lambda errors: warnings.extend(e.toString() for e in errors))
    view.setResizeMode(QQuickView.ResizeMode.SizeRootObjectToView)
    view.resize(1000 if args.settings else 640, 1000 if args.settings else 480)
    view.setSource(QUrl.fromLocalFile(str(ROOT / 'contents/ui' / ('config.qml' if args.settings else 'main.qml'))))
    assert view.status() == QQuickView.Status.Ready, [e.toString() for e in view.errors()]
    view.show()
    if args.settings:
        view.setTitle('Matrix settings test — no changes saved to Plasma')
        return app.exec()

    root = view.rootObject()
    component = QQmlComponent(engine, QUrl.fromLocalFile(str(ROOT / 'contents/ui/config.qml')))
    config = component.create()
    assert config is not None, [e.toString() for e in component.errors()]

    def evaluate(obj, code):
        expr = QQmlExpression(engine.contextForObject(obj), obj, code)
        result, undefined = expr.evaluate()
        assert not expr.hasError(), expr.error().toString()
        return result

    entries = ET.parse(ROOT / 'contents/config/main.xml').findall('.//{*}entry')
    assert len(entries) == 18
    defaults = {}
    for entry in entries:
        name, kind, raw = entry.attrib['name'], entry.attrib['type'], entry.findtext('{*}default')
        value = (raw == 'true') if kind == 'Bool' else raw if kind == 'Color' else int(raw) if kind == 'Int' else float(raw)
        defaults[name] = value

    def check_defaults():
        for name, expected in defaults.items():
            actual = config.property('cfg_' + name)
            if isinstance(expected, str):
                assert actual.name() == expected, (name, actual, expected)
            else:
                assert math.isclose(actual, expected, abs_tol=1e-8), (name, actual, expected)
            fallback = evaluate(root, 'defaultConfig.' + name)
            assert fallback == expected, (name, fallback, expected)

    check_defaults()
    assert not root.property('performanceMode')
    QTest.qWait(60)

    def check_pipeline(performance):
        assert root.property('performanceMode') == performance
        assert evaluate(root, 'bloomLoader.item.objectName') == ('performanceBloom' if performance else 'fullBloom')
        assert evaluate(root, 'containerSource.live') == (not performance)
        assert evaluate(root, 'softBaseLoader.active') == (not performance)
        assert evaluate(root, 'softBaseLoader.item === null') == performance
        names = [item.objectName() for item in root.findChildren(QObject)]
        assert names.count('performanceBloom') == int(performance), names
        assert names.count('fullBloom') == int(not performance), names
        assert evaluate(root, 'cycleTimer.interval') == (1000 if performance else 33)

    check_pipeline(False)
    assert (ROOT / 'contents/ui/FullBloom.qml').read_text().count('FastBlur {') == 5
    assert (ROOT / 'contents/ui/PerformanceBloom.qml').read_text().count('FastBlur {') == 1
    print('PASS: all schema/control/fallback defaults agree; original pipeline is default')

    proxy = QQmlPropertyMap(engine)
    for name, value in defaults.items():
        proxy.insert(name, value)
    assert root.setProperty('testProxyConfig', proxy)
    for performance in [True, False, True, False]:
        proxy.insert('performanceMode', performance)
        QTest.qWait(60)
        check_pipeline(performance)
        proxy.insert('bloomSize', .6)
        assert math.isclose(evaluate(root, 'bloomLoader.item.currentBloomSize'), .6)
        proxy.insert('bloomSize', defaults['bloomSize'])
    print('PASS: repeated mode switches load only the selected pipeline; bloom binding updates')

    def changed_glyphs():
        def visual_items(item):
            yield item
            for child in item.childItems():
                yield from visual_items(child)
        glyphs = [item for item in visual_items(root)
                  if item.metaObject().className().startswith('QQuickText')
                  and isinstance(item.property('text'), str)]
        assert len(glyphs) > 20
        before = [item.property('text') for item in glyphs]
        QTest.qWait(180)
        return sum(item.property('text') != old for item, old in zip(glyphs, before))

    assert changed_glyphs() > 1
    proxy.insert('performanceMode', True)
    assert changed_glyphs() <= 1
    proxy.insert('cycleSpeed', 0.0)
    assert changed_glyphs() == 0
    proxy.insert('cycleSpeed', defaults['cycleSpeed'])
    proxy.insert('performanceMode', False)
    print('PASS: normal glyph mutation is frequent; performance mutation is sparse; zero pauses it')

    assert math.isclose(evaluate(root, 'rainColored.glintIntensity'), .35)
    assert evaluate(root, 'rainColored.baseColor.toString()') != '#006618'
    proxy.insert('performanceMode', True)
    QTest.qWait(40)
    assert evaluate(root, 'rainColored.baseColor.toString()') == '#006618'
    proxy.insert('glyphColor', '#008844')
    assert evaluate(root, 'rainColored.baseColor.toString()') == '#008844'
    proxy.insert('cycleSpeed', 0.0)
    assert not evaluate(root, 'cycleTimer.running')
    # Check refresh wiring statically: software rendering does not implement the
    # shader texture updates. Actual pixel refresh needs a desktop GPU test.
    source = (ROOT / 'contents/ui/main.qml').read_text()
    for handler in ['onWidthChanged', 'onHeightChanged', 'onColumnsCountChanged',
                    'onColWidthChanged', 'onPerformanceModeChanged']:
        assert handler + ': requestGlyphRefresh()' in source, handler
    assert 'onAngleChanged: root.requestGlyphRefresh()' in source
    assert 'onStatusChanged: root.requestGlyphRefresh()' in source
    assert 'Qt.callLater(refreshGlyphTexture)' in source
    assert 'containerSource.scheduleUpdate()' in source
    for name, value in [('characterSize', 20), ('scalingMode', 0), ('numColumns', 45), ('slant', .2)]:
        proxy.insert(name, value)
        QTest.qWait(40)
        assert evaluate(root, 'activeConfig.' + name) == value
    assert root.property('columnsCount') == 45
    view.resize(700, 500)
    QTest.qWait(40)
    assert math.isclose(root.property('colWidth'), 700 / 45)
    print('PASS: palette selection, paused cycling and grid updates; cache-refresh wiring present')

    # Reset operates via aliases; test emitted notifications, not Plasma dirty state.
    notifications = []
    config.cfg_performanceModeChanged.connect(lambda: notifications.append('mode'))
    config.cfg_bloomSizeChanged.connect(lambda: notifications.append('bloom'))
    config.setProperty('cfg_performanceMode', True)
    config.setProperty('cfg_bloomSize', .8)
    config.setProperty('cfg_glyphColor', '#112233')
    notifications.clear()
    evaluate(config, 'resetToDefaults()')
    check_defaults()
    assert sorted(notifications) == ['bloom', 'mode'], notifications
    config.setProperty('cfg_fallSpeed', -1.0)
    assert config.property('cfg_fallSpeed') == -1.0
    evaluate(config, 'resetToDefaults()')
    print('PASS: reset restores defaults and emits alias notifications; reverse falling supported')

    for performance in [False, True]:
        config.setProperty('cfg_performanceMode', performance)
        preview = evaluate(config, 'openPreview()')
        if hasattr(preview, 'toQObject'):
            preview = preview.toQObject()
        assert preview is not None
        QTest.qWait(50)
        renderers = [item for item in preview.findChildren(QQuickItem)
                     if item.metaObject().indexOfProperty('testProxyConfig') >= 0]
        assert len(renderers) == 1
        renderer = renderers[0]
        assert renderer.property('performanceMode') == performance
        config.setProperty('cfg_performanceMode', not performance)
        QTest.qWait(50)
        assert renderer.property('performanceMode') != performance
        config.setProperty('cfg_bloomSize', .2)
        assert math.isclose(renderer.property('currentBloomSize'), .2)
        assert preview.close()
        QTest.qWait(30)
        evaluate(config, 'resetToDefaults()')
    print('PASS: fullscreen preview opens in both modes, follows mode/settings changes, and closes')

    root.setProperty('testProxyConfig', None)
    QTest.qWait(30)
    assert not root.property('performanceMode')
    # Old/partial standalone configurations have no newly introduced keys.
    legacy = QQmlPropertyMap(engine)
    legacy.insert('bloomSize', .5)
    root.setProperty('testProxyConfig', legacy)
    QTest.qWait(30)
    assert not root.property('performanceMode')
    assert math.isclose(root.property('currentBloomSize'), .5)
    assert math.isclose(evaluate(root, 'rainColored.glintIntensity'), .35)
    root.setProperty('testProxyConfig', None)
    standalone_component = QQmlComponent(engine, QUrl.fromLocalFile(str(ROOT / 'scripts/run_window.qml')))
    standalone = standalone_component.create()
    assert standalone is not None, [e.toString() for e in standalone_component.errors()]
    QTest.qWait(60)
    assert standalone.close()
    assert not warnings, '\n'.join(warnings)
    print('PASS: no QML errors. GPU visuals, physical refresh and Plasma save/crash behaviour remain unverified.')
    view.close()
    config.deleteLater()
    QCoreApplication.sendPostedEvents(None, QEvent.Type.DeferredDelete)
    return 0


if __name__ == '__main__':
    sys.exit(main())
