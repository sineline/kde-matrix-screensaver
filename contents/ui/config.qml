import QtQuick
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

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Simulation & Grid")
    }

    QQC2.ComboBox {
        id: scalingModeCombo
        Kirigami.FormData.label: i18n("Column Scaling Mode:")
        model: [
            i18n("Fixed Number of Columns"),
            i18n("Fixed Character Size (Auto-fill)")
        ]
    }

    QQC2.SpinBox {
        id: numColumnsSpinBox
        Kirigami.FormData.label: i18n("Number of Columns:")
        from: 10
        to: 500
        editable: true
        visible: scalingModeCombo.currentIndex === 0
    }

    QQC2.SpinBox {
        id: characterSizeSpinBox
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
            from: 0.1
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
        Kirigami.FormData.label: i18n("Cursor/Lead Color:")
        dialogTitle: i18n("Select Cursor Color")
    }

    KQuickControls.ColorButton {
        id: glyphColorBtn
        Kirigami.FormData.label: i18n("Letter/Trail Color:")
        dialogTitle: i18n("Select Letter Color")
    }

    KQuickControls.ColorButton {
        id: bgColorBtn
        Kirigami.FormData.label: i18n("Background Color:")
        dialogTitle: i18n("Select Background Color")
    }

    KQuickControls.ColorButton {
        id: glintColorBtn
        Kirigami.FormData.label: i18n("Glint Highlight Color:")
        dialogTitle: i18n("Select Glint Color")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Bloom Size:")
        QQC2.Slider {
            id: bloomSizeSlider
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

    QQC2.Button {
        text: i18n("Reset to Defaults")
        icon.name: "edit-undo"
        onClicked: {
            scalingModeCombo.currentIndex = 1;
            numColumnsSpinBox.value = 80;
            characterSizeSpinBox.value = 40;
            animSpeedSlider.value = 1.0;
            fallSpeedSlider.value = 0.3;
            cycleSpeedSlider.value = 0.03;
            raindropLengthSlider.value = 0.75;
            slantSlider.value = 0.0;
            trailBrightnessSlider.value = 1.0;
            cursorColorBtn.color = "#c1ff75";
            glyphColorBtn.color = "#006618";
            bgColorBtn.color = "#000000";
            glintColorBtn.color = "#c1ff75";
            bloomSizeSlider.value = 0.4;
            bloomStrengthSlider.value = 0.7;
            cursorIntensitySlider.value = 0.7;
            glintIntensitySlider.value = 0.35;
        }
    }
}
