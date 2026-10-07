import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.FormLayout {
    id: root

    property var configDialog
    property var wallpaperConfiguration
    property var parentLayout

    property alias formLayout: root

    property alias cfg_performanceMode: performanceModeCheckBox.checked
    property alias cfg_scalingMode: scalingModeCombo.currentIndex
    property alias cfg_numColumns: numColumnsSpinBox.value
    property alias cfg_characterSize: characterSizeSpinBox.value
    property alias cfg_animationSpeed: animSpeedSlider.value
    property alias cfg_fallSpeed: fallSpeedSlider.value
    property alias cfg_cycleSpeed: cycleSpeedSlider.value
    property alias cfg_raindropLength: raindropLengthSlider.value
    property alias cfg_slant: slantSlider.value
    property alias cfg_trailBrightness: trailBrightnessSlider.value
    property alias cfg_cursorColor: cursorColorBtn.color
    property alias cfg_glyphColor: glyphColorBtn.color
    property alias cfg_backgroundColor: bgColorBtn.color
    property alias cfg_glintColor: glintColorBtn.color
    property alias cfg_bloomSize: bloomSizeSlider.value
    property alias cfg_bloomStrength: bloomStrengthSlider.value
    property alias cfg_cursorIntensity: cursorIntensitySlider.value
    property alias cfg_glintIntensity: glintIntensitySlider.value

    QQC2.CheckBox {
        id: performanceModeCheckBox
        checked: false
        text: i18n("Performance Mode")
        Kirigami.FormData.label: i18n("Rendering:")
    }
    QQC2.Label {
        text: i18n("Reduces bloom and glyph changes and uses a darker trail palette. Disable for the original appearance.")
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: 420
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Simulation & Grid")
    }

    QQC2.ComboBox {
        id: scalingModeCombo
        currentIndex: 1
        Kirigami.FormData.label: i18n("Column Scaling Mode:")
        model: [
            i18n("Fixed Number of Columns"),
            i18n("Fixed Character Size (Auto-fill)")
        ]
    }

    QQC2.SpinBox {
        id: numColumnsSpinBox
        value: 80
        Kirigami.FormData.label: i18n("Number of Columns:")
        from: 10
        to: 500
        editable: true
        visible: scalingModeCombo.currentIndex === 0
    }

    QQC2.SpinBox {
        id: characterSizeSpinBox
        value: 40
        Kirigami.FormData.label: i18n("Character Size (px):")
        from: 8
        to: 256
        editable: true
        visible: scalingModeCombo.currentIndex === 1
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Animation Speed:")
        QQC2.Slider {
            id: animSpeedSlider
            value: 1.0
            from: 0.1
            to: 10.0
            stepSize: 0.1
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: animSpeedSlider.value.toFixed(2) + "x"
            Layout.preferredWidth: 45
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Fall Speed:")
        QQC2.Slider {
            id: fallSpeedSlider
            value: 0.3
            from: -2.0
            to: 10.0
            stepSize: 0.1
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: fallSpeedSlider.value.toFixed(2)
            Layout.preferredWidth: 45
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Glyph Cycle Speed:")
        QQC2.Slider {
            id: cycleSpeedSlider
            value: 0.03
            from: 0.0
            to: 2.0
            stepSize: 0.01
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: cycleSpeedSlider.value.toFixed(2)
            Layout.preferredWidth: 45
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Raindrop Length:")
        QQC2.Slider {
            id: raindropLengthSlider
            value: 0.75
            from: 0.1
            to: 5.0
            stepSize: 0.05
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: raindropLengthSlider.value.toFixed(2)
            Layout.preferredWidth: 40
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Rain Slant (Angle):")
        QQC2.Slider {
            id: slantSlider
            value: 0.0
            from: -90.0
            to: 90.0
            stepSize: 1.0
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: slantSlider.value.toFixed(1) + "°"
            Layout.preferredWidth: 40
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Trail Brightness:")
        QQC2.Slider {
            id: trailBrightnessSlider
            value: 1.0
            from: 0.5
            to: 3.0
            stepSize: 0.05
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: trailBrightnessSlider.value.toFixed(2)
            Layout.preferredWidth: 40
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Colors & Glow")
    }

    KQuickControls.ColorButton {
        id: cursorColorBtn
        color: "#c1ff75"
        Kirigami.FormData.label: i18n("Cursor/Lead Color:")
        dialogTitle: i18n("Select Cursor Color")
    }

    KQuickControls.ColorButton {
        id: glyphColorBtn
        color: "#006618"
        enabled: root.cfg_performanceMode
        Kirigami.FormData.label: i18n("Performance Mode Trail Color:")
        dialogTitle: i18n("Select Letter Color")
    }

    KQuickControls.ColorButton {
        id: bgColorBtn
        color: "#000000"
        Kirigami.FormData.label: i18n("Background Color:")
        dialogTitle: i18n("Select Background Color")
    }

    KQuickControls.ColorButton {
        id: glintColorBtn
        color: "#c1ff75"
        Kirigami.FormData.label: i18n("Glint Highlight Color:")
        dialogTitle: i18n("Select Glint Color")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Bloom Size:")
        QQC2.Slider {
            id: bloomSizeSlider
            value: 0.4
            from: 0.0
            to: 1.0
            stepSize: 0.02
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: bloomSizeSlider.value.toFixed(2)
            Layout.preferredWidth: 40
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Bloom Strength:")
        QQC2.Slider {
            id: bloomStrengthSlider
            value: 0.7
            from: 0.0
            to: 1.0
            stepSize: 0.02
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: bloomStrengthSlider.value.toFixed(2)
            Layout.preferredWidth: 40
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Lead Glyph Glow:")
        QQC2.Slider {
            id: cursorIntensitySlider
            value: 0.7
            from: 0.0
            to: 5.0
            stepSize: 0.1
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: cursorIntensitySlider.value.toFixed(1)
            Layout.preferredWidth: 40
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Trail Sparkle Intensity:")
        QQC2.Slider {
            id: glintIntensitySlider
            value: 0.35
            from: 0.0
            to: 2.0
            stepSize: 0.05
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: glintIntensitySlider.value.toFixed(2)
            Layout.preferredWidth: 40
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Actions")
    }

    function resetToDefaults() {
        root.cfg_performanceMode = false;
        root.cfg_scalingMode = 1;
        root.cfg_numColumns = 80;
        root.cfg_characterSize = 40;
        root.cfg_animationSpeed = 1.0;
        root.cfg_fallSpeed = 0.3;
        root.cfg_cycleSpeed = 0.03;
        root.cfg_raindropLength = 0.75;
        root.cfg_slant = 0.0;
        root.cfg_trailBrightness = 1.0;
        root.cfg_cursorColor = "#c1ff75";
        root.cfg_glyphColor = "#006618";
        root.cfg_backgroundColor = "#000000";
        root.cfg_glintColor = "#c1ff75";
        root.cfg_bloomSize = 0.4;
        root.cfg_bloomStrength = 0.7;
        root.cfg_cursorIntensity = 0.7;
        root.cfg_glintIntensity = 0.35;
    }

    // Instantiated only on request; no extra renderer while preview is closed.
    function openPreview() {
        return testWindowComponent.createObject(root)
    }

    QQC2.Button {
        text: i18n("Launch Fullscreen Preview")
        icon.name: "media-playback-start"
        onClicked: root.openPreview()
    }

    Component {
        id: testWindowComponent
        Window {
            id: testWin
            objectName: "matrixFullscreenPreview"
            visible: true
            visibility: Window.FullScreen
            title: i18n("Matrix Fullscreen Preview")
            color: "black"
            onClosing: testWin.destroy()

            property int numColumns: root.cfg_numColumns
            property bool performanceMode: root.cfg_performanceMode
            property int scalingMode: root.cfg_scalingMode
            property int characterSize: root.cfg_characterSize
            property real animationSpeed: root.cfg_animationSpeed
            property real fallSpeed: root.cfg_fallSpeed
            property real cycleSpeed: root.cfg_cycleSpeed
            property real raindropLength: root.cfg_raindropLength
            property real slant: root.cfg_slant
            property real bloomSize: root.cfg_bloomSize
            property real bloomStrength: root.cfg_bloomStrength
            property color cursorColor: root.cfg_cursorColor
            property color glyphColor: root.cfg_glyphColor
            property color backgroundColor: root.cfg_backgroundColor
            property color glintColor: root.cfg_glintColor
            property real trailBrightness: root.cfg_trailBrightness
            property real glintIntensity: root.cfg_glintIntensity
            property real cursorIntensity: root.cfg_cursorIntensity

            Loader {
                anchors.fill: parent
                source: "main.qml"
                onLoaded: item.testProxyConfig = testWin
            }
            MouseArea {
                anchors.fill: parent
                onClicked: testWin.close()
            }
            Item {
                focus: true
                Keys.onPressed: testWin.close()
            }
        }
    }

    QQC2.Button {
        text: i18n("Reset to Defaults")
        icon.name: "edit-undo"
        onClicked: root.resetToDefaults()
    }
}
