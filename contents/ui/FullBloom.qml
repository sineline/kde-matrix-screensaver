import QtQuick
import Qt5Compat.GraphicalEffects

// Only the selected bloom pipeline is instantiated by main.qml.
Item {
    id: root
    objectName: "fullBloom"
    required property var activeConfig
    required property Item bloomInput
    required property Item primarySource

    // Define properties updated via declarative QML bindings
    property real currentBloomSize: activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : 0.4
    property real currentBloomStrength: activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : 0.7
    property real bloomScale: Math.max(0.01, currentBloomSize) / 0.4
    property real bloomDownsample: 4.0
    property real bloomRadiusMultiplier: bloomScale

    // Progressive downsample/blur pyramid levels
    // Level 0: bloomSize scale of screen (typically 0.4x)
    ShaderEffectSource {
        id: pyr0Downsample
        sourceItem: root.bloomInput
        width: Math.max(1, root.width * root.currentBloomSize)
        height: Math.max(1, root.height * root.currentBloomSize)
        sourceRect: Qt.rect(0, 0, root.width, root.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr0Blur
        anchors.fill: pyr0Downsample
        source: pyr0Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr0Source
        sourceItem: pyr0Blur
        anchors.fill: pyr0Blur
        smooth: true
        visible: false
    }

    // Level 1: Half of Level 0
    ShaderEffectSource {
        id: pyr1Downsample
        sourceItem: pyr0Source
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
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
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

    // Level 2: Half of Level 1
    ShaderEffectSource {
        id: pyr2Downsample
        sourceItem: pyr1Source
        width: Math.max(1, pyr1Downsample.width / 2)
        height: Math.max(1, pyr1Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr1Downsample.width, pyr1Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr2Blur
        anchors.fill: pyr2Downsample
        source: pyr2Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr2Source
        sourceItem: pyr2Blur
        anchors.fill: pyr2Blur
        smooth: true
        visible: false
    }

    // Level 3: Half of Level 2
    ShaderEffectSource {
        id: pyr3Downsample
        sourceItem: pyr2Source
        width: Math.max(1, pyr2Downsample.width / 2)
        height: Math.max(1, pyr2Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr2Downsample.width, pyr2Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr3Blur
        anchors.fill: pyr3Downsample
        source: pyr3Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr3Source
        sourceItem: pyr3Blur
        anchors.fill: pyr3Blur
        smooth: true
        visible: false
    }

    // Level 4: Half of Level 3
    ShaderEffectSource {
        id: pyr4Downsample
        sourceItem: pyr3Source
        width: Math.max(1, pyr3Downsample.width / 2)
        height: Math.max(1, pyr3Downsample.height / 2)
        sourceRect: Qt.rect(0, 0, pyr3Downsample.width, pyr3Downsample.height)
        smooth: true
        visible: false
    }
    FastBlur {
        id: pyr4Blur
        anchors.fill: pyr4Downsample
        source: pyr4Downsample
        radius: Math.min(64, Math.max(1, 4 * root.bloomRadiusMultiplier))
        transparentBorder: true
        visible: false
    }
    ShaderEffectSource {
        id: pyr4Source
        sourceItem: pyr4Blur
        anchors.fill: pyr4Blur
        smooth: true
        visible: false
    }

    ShaderEffect {
        id: finalComposite
        anchors.fill: parent
        property variant primaryTex: root.primarySource
        property variant pyr0Tex: pyr0Source
        property variant pyr1Tex: pyr1Source
        property variant pyr2Tex: pyr2Source
        property variant pyr3Tex: pyr3Source
        property variant pyr4Tex: pyr4Source
        property real bloomStrength: root.currentBloomStrength
        property color glintColor: activeConfig.glintColor || "#c1ff75"

        fragmentShader: "compose.frag.qsb"
    }

}
