import QtQuick
import org.kde.plasma.plasmoid
import Qt5Compat.GraphicalEffects

WallpaperItem {
    id: root
    width: 800
    height: 600

    readonly property var defaultConfig: ({
        performanceMode: false,
        scalingMode: 1,
        characterSize: 40,
        numColumns: 80,
        animationSpeed: 1.0,
        fallSpeed: 0.3,
        cycleSpeed: 0.03,
        trailBrightness: 1.0,
        glintIntensity: 0.35,
        cursorIntensity: 0.7,
        raindropLength: 0.75,
        slant: 0.0,
        bloomSize: 0.4,
        bloomStrength: 0.7,
        cursorColor: '#c1ff75',
        glyphColor: '#006618',
        backgroundColor: '#000000',
        glintColor: '#c1ff75'
    })

    // Standalone previews cannot replace WallpaperItem's typed configuration.
    property var testProxyConfig: null
    readonly property var activeConfig: root.testProxyConfig ? root.testProxyConfig : ((root.configuration && root.configuration.characterSize !== undefined) ? root.configuration : root.defaultConfig)

    readonly property bool performanceMode: activeConfig.performanceMode === true

    // Coalesce grid changes and refresh even when glyph cycling is paused.
    function refreshGlyphTexture() {
        containerSource.scheduleUpdate()
    }
    function requestGlyphRefresh() {
        Qt.callLater(refreshGlyphTexture)
    }

    FontLoader {
        id: matrixFont
        source: '../fonts/Matrix-Code.ttf'
        onStatusChanged: root.requestGlyphRefresh()
    }

    readonly property int columnsCount: {
        if (activeConfig.scalingMode === 1) {
            return Math.max(1, Math.floor(width / (activeConfig.characterSize !== undefined ? activeConfig.characterSize : 40)))
        } else {
            return activeConfig.numColumns !== undefined ? activeConfig.numColumns : 80
        }
    }
    readonly property double colWidth: width / columnsCount
    readonly property double cellHeight: colWidth

    property real baseHue: 0.3
    property real baseSat: 1.0
    property color activeCursorColor: activeConfig.cursorColor || root.defaultConfig.cursorColor
    property color activeGlyphColor: activeConfig.glyphColor || '#006618'
    property real activeHue: activeCursorColor.hslHue
    property real activeSat: activeCursorColor.hslSaturation

    readonly property var charsList: ['モ', 'エ', 'ヤ', 'キ', 'オ', 'カ', '7', 'ケ', 'サ', 'ス', 'z', '1', '5', '2', 'ヨ', 'タ', 'ワ', '4', 'ネ', 'ヌ', 'ナ', '9', '8', 'ヒ', '0', 'ホ', 'ア', '3', 'ウ', 'セ', 'ミ', 'ラ', 'リ', 'ツ', 'テ', 'ニ', 'ハ', 'ソ', 'コ', 'シ', 'マ', 'ム', 'メ']

    function randomFloat(x, y) {
        var a = 12.9898, b = 78.233, c = 43758.5453;
        var dt = x * a + y * b;
        var sn = dt % Math.PI;
        var val = Math.sin(sn) * c;
        var res = val - Math.floor(val);
        if (isNaN(res) || res < 0) return 0.0;
        if (res >= 1.0) return 0.999;
        return res;
    }

    Rectangle {
        anchors.fill: parent
        color: activeConfig.backgroundColor || '#000000'
        z: -1
    }

    Item {
        id: container
        anchors.fill: parent

        transform: Rotation {
            origin.x: container.width / 2
            origin.y: container.height / 2
            angle: (activeConfig.slant !== undefined ? activeConfig.slant : 0.0) * 180 / Math.PI
            onAngleChanged: root.requestGlyphRefresh()
        }

        Repeater {
            id: columnsRepeater
            model: columnsCount
            delegate: Item {
                id: columnItem
                x: index * colWidth
                width: colWidth
                height: container.height

                readonly property int maxVisibleRows: Math.ceil(root.height / root.colWidth) + 3

                function randomizeRandomCell() {
                    if (trailRepeater.count === 0) return;
                    let randomRow = Math.floor(Math.random() * trailRepeater.count);
                    let cell = trailRepeater.itemAt(randomRow);
                    if (cell && typeof cell.randomizeChar === 'function') {
                        cell.randomizeChar();
                    }
                }

                Repeater {
                    id: trailRepeater
                    model: columnItem.maxVisibleRows
                    delegate: Item {
                        width: colWidth
                        height: cellHeight
                        y: index * cellHeight

                        Component.onCompleted: {
                            myText.text = charsList[Math.floor(Math.random() * charsList.length)]
                        }
                        
                        function randomizeChar() {
                            myText.text = charsList[Math.floor(Math.random() * charsList.length)]
                        }

                        Text {
                            id: myText
                            anchors.fill: parent
                            text: ' '
                            color: '#ffffff'
                            font.family: matrixFont.name
                            font.pixelSize: Math.ceil(parent.width * 1.15)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    // A static texture must also refresh after layout/configuration changes.
    onWidthChanged: requestGlyphRefresh()
    onHeightChanged: requestGlyphRefresh()
    onColumnsCountChanged: requestGlyphRefresh()
    onColWidthChanged: requestGlyphRefresh()
    onPerformanceModeChanged: requestGlyphRefresh()

    // Normal mode retains upstream's default per-cell mutation rate.
    // Performance mode intentionally changes only one cell per slow tick.
    Timer {
        id: cycleTimer
        interval: root.performanceMode ? Math.max(1000, Math.floor(30 / Math.max(0.001, activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed : 0.01))) : 33
        running: (activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed > 0 : true) && (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed > 0 : true)
        repeat: true
        onTriggered: {
            if (columnsRepeater.count === 0) return;
            const cycleSpeed = activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed : root.defaultConfig.cycleSpeed;
            const totalCells = root.columnsCount * (Math.ceil(root.height / root.colWidth) + 3);
            const changes = root.performanceMode ? 1 : Math.max(1, Math.floor(1.8 * (cycleSpeed / 0.03) * totalCells / 30));
            for (let i = 0; i < changes; ++i) {
                let randomCol = Math.floor(Math.random() * columnsRepeater.count);
                let colItem = columnsRepeater.itemAt(randomCol);
                if (colItem) colItem.randomizeRandomCell();
            }
            if (root.performanceMode) containerSource.scheduleUpdate();
        }
    }

    // Performance mode caches the grid between explicit updates.
    ShaderEffectSource {
        id: containerSource
        sourceItem: container
        hideSource: true
        live: !root.performanceMode
        anchors.fill: container
        smooth: true
        visible: false
        Component.onCompleted: root.requestGlyphRefresh()
    }

    Loader {
        id: softBaseLoader
        anchors.fill: parent
        active: !root.performanceMode
        visible: false
        sourceComponent: Component {
            ShaderEffectSource {
                objectName: "softBaseSource"
                sourceItem: softBase
                hideSource: true
                smooth: true
                visible: false
                FastBlur {
                    id: softBase
                    anchors.fill: parent
                    source: containerSource
                    radius: 3
                    transparentBorder: true
                    visible: false
                }
            }
        }
    }

    // Main GPU rain effect
    ShaderEffect {
        id: rainColored
        anchors.fill: parent
        visible: false
        property variant source: root.performanceMode ? containerSource : softBaseLoader.item
        property real simTime: root.simTime
        property real fallSpeed: activeConfig.fallSpeed !== undefined ? activeConfig.fallSpeed : 0.3
        property real raindropLength: activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75
        property real slant: activeConfig.slant !== undefined ? activeConfig.slant : 0.0
        property real numColumns: root.columnsCount
        property real screenRows: root.height / Math.max(1, root.cellHeight)
        property real cellHeightRatio: root.cellHeight / Math.max(1, root.height)

        property real loops: 0.0
        property color glintColor: activeConfig.glintColor || '#c1ff75'
        property color baseColor: root.performanceMode ? root.activeGlyphColor : Qt.hsla(root.activeHue, root.activeSat, 0.5, 1.0)
        property real trailBrightness: activeConfig.trailBrightness !== undefined ? activeConfig.trailBrightness : 1.0
        property real glintIntensity: activeConfig.glintIntensity !== undefined ? activeConfig.glintIntensity : root.defaultConfig.glintIntensity
        fragmentShader: 'rain.frag.qsb'
    }

    ShaderEffectSource {
        id: rainColoredSource
        sourceItem: rainColored
        hideSource: true
        anchors.fill: rainColored
        smooth: true
        visible: false
    }

    Item {
        id: squaredContainer
        anchors.fill: rainColoredSource
        ShaderEffect {
            anchors.fill: parent
            property variant sourceTex: rainColoredSource
            property color glintColor: activeConfig.glintColor || '#c1ff75'
            property real glintIntensity: activeConfig.glintIntensity !== undefined ? activeConfig.glintIntensity : root.defaultConfig.glintIntensity
            property real cursorIntensity: activeConfig.cursorIntensity !== undefined ? activeConfig.cursorIntensity : root.defaultConfig.cursorIntensity
            fragmentShader: 'squared.frag.qsb'
        }
    }

    readonly property real currentBloomSize: activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : defaultConfig.bloomSize
    readonly property real currentBloomStrength: activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : defaultConfig.bloomStrength

    Loader {
        id: bloomLoader
        objectName: "bloomLoader"
        anchors.fill: parent
        sourceComponent: root.performanceMode ? performanceBloomComponent : fullBloomComponent
    }
    Component {
        id: fullBloomComponent
        FullBloom {
            activeConfig: root.activeConfig
            bloomInput: squaredContainer
            primarySource: rainColoredSource
        }
    }
    Component {
        id: performanceBloomComponent
        PerformanceBloom {
            activeConfig: root.activeConfig
            bloomInput: squaredContainer
            primarySource: rainColoredSource
        }
    }

    property real internalSimTime: 0.0
    NumberAnimation {
        id: timeAnim
        target: root
        property: 'internalSimTime'
        from: 0.0
        to: 1000000.0
        duration: 1000000000
        loops: Animation.Infinite
        running: true
    }

    readonly property real simTime: internalSimTime * (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed : 1.0)
}
