import QtQuick
import Qt5Compat.GraphicalEffects

// Only the selected bloom pipeline is instantiated by main.qml.
Item {
    id: root
    objectName: "performanceBloom"
    required property var activeConfig
    required property Item bloomInput
    required property Item primarySource

    // Optimized Bloom Downsample Pyramid (Eliminates redundant multi-pass FastBlurs at full resolution)
    property real currentBloomSize: activeConfig.bloomSize !== undefined ? activeConfig.bloomSize : 0.4
    property real currentBloomStrength: activeConfig.bloomStrength !== undefined ? activeConfig.bloomStrength : 0.7

    ShaderEffectSource {
        id: pyr0Downsample
        sourceItem: root.bloomInput
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
        property variant primaryTex: root.primarySource
        property variant pyr0Tex: pyr0Downsample
        property variant pyr1Tex: pyr1Source
        property variant pyr2Tex: pyr2Downsample
        property variant pyr3Tex: pyr3Downsample
        property variant pyr4Tex: pyr4Downsample
        property real bloomStrength: root.currentBloomStrength
        property color glintColor: activeConfig.glintColor || '#c1ff75'

        fragmentShader: 'compose.frag.qsb'
    }

}
