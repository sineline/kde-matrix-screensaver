# KDE Plasma Matrix Screensaver & Wallpaper

![Matrix Screensaver Demo](assets/demo.gif)

A fully GPU-accelerated Matrix digital rain effect designed natively for KDE Plasma 6 as a Wallpaper plugin and Screen Locker.

This project is a native QML and Qt shader rewrite of the incredible [web-based Matrix digital rain](https://github.com/rezmason/matrix) created by **Rezmason**.

## Why a rewrite?

While there are methods to run the original WebGL code as a wallpaper in KDE using webview plugins, this approach has a critical flaw for many users. The original WebGL code in combination with AMD/MESA graphics drivers triggers a driver bug that results in a glaring diagonal white artifact cutting across the entire effect.

By rewriting the rendering pipeline natively using KDE Plasma's QML and Qt's `ShaderEffect` framework, this project:
- Completely bypasses the AMD/MESA driver artifact issue
- Integrates seamlessly and natively into the KDE Plasma 6 desktop environment
- Delivers native GPU performance without the overhead of a Chromium/WebEngine instance

## Features

- **Native KDE Plasma Integration:** Works flawlessly as both a Desktop Wallpaper and Screen Locker.
- **High-Performance Rendering:** Uses direct Qt `ShaderEffect` pipelines (including custom Bloom shaders) for butter-smooth 60+ FPS without draining CPU.
- **Customizable Configuration:** Full settings panel to adjust matrix colors (glint, cursor, background), sizing, density, speed, and bloom intensity right from KDE's System Settings.

## Installation

### From the KDE Store (Recommended)

1. Open **System Settings** → **Wallpaper** (or **Screen Locker**).
2. Click **"Get New Wallpaper Plugins..."**
3. Search for **"KDE Plasma Matrix Screensaver & Wallpaper"** and click **Install**.

### From GitHub Releases

1. Download the latest `matrix-screensaver.tar.xz` from the [Releases](../../releases) page.
2. Install via the UI:
   - Open KDE System Settings → Wallpaper (or Screen Locker).
   - Click **"Add New..."** or **"Install from File..."**
   - Select the downloaded `.tar.xz` package.
3. Or install via CLI:
   ```bash
   kpackagetool6 --type Plasma/Wallpaper -i matrix-screensaver.tar.xz
   ```

To update an existing installation, use `-u` instead of `-i`.

## Requirements

- KDE Plasma 6.0 or later
- Qt 6 with QtQuick and Qt5Compat.GraphicalEffects

## Rendering modes

The default mode uses the original five-level bloom, softened glyphs, cursor-derived
trail palette, and frequent character changes. **Performance Mode** is opt-in in
the wallpaper settings: it uses reduced bloom, a cached glyph grid, sparse character
changes, and a darker configurable trail colour. This trades visual fidelity for
lower rendering work; actual performance depends on your hardware and settings.
Only the selected bloom pipeline is loaded. Reset to Defaults disables Performance
Mode. Existing settings without a mode entry also use the default mode.

The settings page includes a fullscreen preview of the current, unsaved values.
Click or press a key to close the preview.

## Testing changes locally

With Python 3, PyQt6 (including QtTest), and the Qt/KDE QML modules installed:

```bash
python3 scripts/test_modes.py
python3 scripts/test_modes.py --settings
```

The first command runs offscreen functional checks for both rendering modes,
configuration defaults, reset notifications, glyph updates, and preview lifecycle.
The second opens standalone settings and preview windows without installing the
wallpaper or saving anything to Plasma. Try both modes and change grid size, bloom,
and cycle speed, including zero. Offscreen checks cannot establish GPU image
correctness, frame pacing, or Plasma settings persistence/crash behaviour; those
require testing in the actual desktop session.

## Credits & Acknowledgements

The digital rain mechanics, aesthetic logic, and Matrix-Code font are credited to **Rezmason** and their amazing [Matrix](https://github.com/rezmason/matrix) project, released under the MIT License. This native KDE port was built to bring their meticulously crafted digital rain effect to Linux desktop users without WebGL driver issues.

## License

[MIT](LICENSE)
