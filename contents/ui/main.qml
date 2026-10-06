import QtQuick
import org.kde.plasma.plasmoid
import Qt5Compat.GraphicalEffects

WallpaperItem {
    id: root
    width: 800
    height: 600

    readonly property var defaultConfig: ({
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

    readonly property var activeConfig: (root.configuration && root.configuration.characterSize !== undefined) ? root.configuration : root.defaultConfig

    FontLoader {
        id: matrixFont
        source: '../fonts/Matrix-Code.ttf'
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
    property color activeCursorColor: activeConfig.cursorColor || '#2de500'
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

    // Schedule container cache update on resize
    onWidthChanged: containerSource.scheduleUpdate()
    onHeightChanged: containerSource.scheduleUpdate()

    // Low-frequency cycle timer for subtle character mutation without freezing CPU
    Timer {
        id: cycleTimer
        interval: Math.max(1000, Math.floor(30 / Math.max(0.001, activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed : 0.01)))
        running: (activeConfig.cycleSpeed !== undefined ? activeConfig.cycleSpeed > 0 : false) && (activeConfig.animationSpeed !== undefined ? activeConfig.animationSpeed > 0 : true)
        repeat: true
        onTriggered: {
            if (columnsRepeater.count === 0) return;
            let randomCol = Math.floor(Math.random() * columnsRepeater.count);
            let colItem = columnsRepeater.itemAt(randomCol);
            if (colItem && typeof colItem.randomizeRandomCell === 'function') {
                colItem.randomizeRandomCell();
            }
            containerSource.scheduleUpdate();
        }
    }

    // Static GPU texture cache for text grid - avoids re-rasterizing thousands of Text items every frame
    ShaderEffectSource {
        id: containerSource
        sourceItem: container
        hideSource: true
        live: false
        anchors.fill: container
        smooth: true
        visible: false
        Component.onCompleted: scheduleUpdate()
    }

    // Main GPU rain effect
    ShaderEffect {
        id: rainColored
        anchors.fill: parent
        visible: false
        property variant source: containerSource
        property real simTime: root.simTime
        property real fallSpeed: activeConfig.fallSpeed !== undefined ? activeConfig.fallSpeed : 0.3
        property real raindropLength: activeConfig.raindropLength !== undefined ? activeConfig.raindropLength : 0.75
        property real slant: activeConfig.slant !== undefined ? activeConfig.slant : 0.0
        property real numColumns: root.columnsCount
        property real screenRows: root.height / Math.max(1, root.cellHeight)
        property real cellHeightRatio: root.cellHeight / Math.max(1, root.height)

        property real loops: 0.0
        property color glintColor: activeConfig.glintColor || '#c1ff75'
        property color baseColor: root.activeGlyphColor
        property real trailBrightness: activeConfig.trailBrightness !== undefined ? activeConfig.trailBrightness : 1.0
        property real glintIntensity: activeConfig.glintIntensity !== undefined ? activeConfig.glintIntensity : 1.0
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
            property real glintIntensity: activeConfig.glintIntensity !== undefined ? activeConfig.glintIntensity : 1.0
            property real cursorIntensity: activeConfig.cursorIntensity !== undefined ? activeConfig.cursorIntensity : 2.0
            fragmentShader: 'squared.frag.qsb'
        }
    }

    // Optimized Bloom Downsample Pyramid (Eliminates redundant multi-pass FastBlurs at full resolution)
    property real currentBloomSize: activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : 0.4
    property real currentBloomStrength: activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : 0.7

    ShaderEffectSource {
        id: pyr0Downsample
        sourceItem: squaredContainer
        width: Math.max(1, root.width * root.currentBloomSize)
        height: Math.max(1, root.height * root.currentBloomSize)
        sourceRect: Qt.rect(0, 0, root.width, root.height)
        smooth: true
        visible: false
    }

    ShaderEffectSource {
        id: pyr1Downsample
        sourceItem: pyr0Downsample
        width: Math.max(1, pyr0Downsample.width / 2)
        height: Math.max(1, pyr0Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr0Downsample.width, pyr0Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr1Blur
        anchors.fill: pyr1Downsample
        source: pyr1Downsample
        radius: 8
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr1Source
        sourceItem: pyr1Blur
        anchors.fill: pyr1Blur
        smooth: true
        visible: false
    }

    ShaderEffectSource {
        id: pyr2Downsample
        sourceItem: pyr1Source
        width: Math.max(1, pyr1Downsample.width / 2)
        height: Math.max(1, pyr1Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr1Downsample.width, pyr1Downsample.height)
        smooth: true
        visible: false
    }

    ShaderEffectSource {
        id: pyr3Downsample
        sourceItem: pyr2Downsample
        width: Math.max(1, pyr2Downsample.width / 2)
        height: Math.max(1, pyr2Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr2Downsample.width, pyr2Downsample.height)
        smooth: true
        visible: false
    }

    ShaderEffectSource {
        id: pyr4Downsample
        sourceItem: pyr3Downsample
        width: Math.max(1, pyr3Downsample.width / 2)
        height: Math.max(1, pyr3Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr3Downsample.width, pyr3Downsample.height)
        smooth: true
        visible: false
    }

    ShaderEffect {
        id: finalComposite
        anchors.fill: parent
        property variant primaryTex: rainColoredSource
        property variant pyr0Tex: pyr0Downsample
        property variant pyr1Tex: pyr1Source
        property variant pyr2Tex: pyr2Downsample
        property variant pyr3Tex: pyr3Downsample
        property variant pyr4Tex: pyr4Downsample
        property real bloomStrength: root.currentBloomStrength
        property color glintColor: activeConfig.glintColor || '#c1ff75'

        fragmentShader: 'compose.frag.qsb'
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
