# Accessibility Features: Text-to-Speech (TTS)

## Overview
Algebrini now includes a Text-to-Speech (TTS) accessibility feature, allowing users to have instructions and content read aloud throughout the app. This supports a more inclusive experience for young learners and those with reading difficulties.

## Usage
- **Listen Buttons:**
  - On the Home Screen and Game Screen, a "Listen" button is available. Pressing this button will read aloud the current instructions or content using the device's TTS engine.
- **TTS Toggle:**
  - Users can enable or disable TTS from the Settings screen via a dedicated toggle labeled "Text-to-Speech (TTS)".
  - The TTS setting is persisted and respected throughout the app. When disabled, "Listen" buttons are hidden or inactive.

## Technical Details
- TTS is implemented using the [`flutter_tts`](https://pub.dev/packages/flutter_tts) package.
- TTS state is managed via `SharedPreferences` for persistence.
- The TTS service is modular and can be extended for additional languages or voices.

## Automated Testing
- Comprehensive widget tests ensure:
  - The TTS toggle is present and defaults to enabled.
  - The toggle can be disabled and the state persists across app restarts.
  - The UI updates accordingly based on the TTS setting.
- Tests are located in `test/screens/settings_screen_tts_test.dart` and are run via the Taskfile (`task test`).

## Next Steps
- Additional accessibility features (font size, color schemes, dyslexia mode) are planned and will be documented here as implemented.

# Adjustable Font Size

## Overview
Users can adjust the app's font size for improved readability and comfort. This supports users with low vision, reading difficulties, or personal preferences.

## Usage
- **Font Size Slider:**
  - In the Settings screen, under Accessibility, a slider labeled "Font Size" allows users to select their preferred text size (14–32pt).
  - A live preview shows the effect of the selected size.
- **Persistence:**
  - The selected font size is saved and applied throughout the app, including Home, Game, Progress, Profile, and Settings screens.
  - The setting persists across app restarts.

## Technical Details
- Font size is managed by a `FontSizeProvider` (using Provider/ChangeNotifier).
- The value is stored in `SharedPreferences` for persistence.
- All major text widgets and Google Fonts usages respect the selected font size.

## Automated Testing
- Widget tests ensure:
  - The slider is present and updates the preview text.
  - The font size persists after saving and app restart.
  - The setting is respected app-wide.
- Tests are located in `test/screens/settings_screen_font_size_test.dart` and are run via the Taskfile (`task test`).

# High Contrast/Colorblind Mode

## Overview
Users can enable a high-contrast, colorblind-friendly mode for improved visibility and accessibility. This mode uses a dark background with bright, distinct colors and increased text contrast.

## Usage
- **Toggle:**
  - In the Settings screen, under Accessibility, a switch labeled "High Contrast/Colorblind Mode" enables or disables this feature.
- **Persistence:**
  - The setting is saved and applied throughout the app, and persists across app restarts.

## Technical Details
- Managed by a `ThemeProvider` (using Provider/ChangeNotifier).
- The value is stored in `SharedPreferences` for persistence.
- The app's color scheme and text colors update dynamically when toggled.

## Automated Testing
- Widget tests ensure:
  - The toggle is present and updates the theme.
  - The setting persists after saving and app restart.
- Tests are located in `test/screens/settings_screen_theme_test.dart` and are run via the Taskfile (`task test`).

# Dyslexia-Friendly Font

## Overview
Users can enable a dyslexia-friendly font (Lexend) for improved readability and accessibility. This font is designed to reduce letter confusion and reading fatigue for users with dyslexia.

## Usage
- **Toggle:**
  - In the Settings screen, under Accessibility, a switch labeled "Dyslexia-Friendly Font" enables or disables this feature.
- **Persistence:**
  - The setting is saved and applied throughout the app, and persists across app restarts.

## Technical Details
- Managed by the `FontSizeProvider` (using Provider/ChangeNotifier).
- The value is stored in `SharedPreferences` for persistence.
- All major text widgets and Google Fonts usages update dynamically when toggled.

## Automated Testing
- Widget tests ensure:
  - The toggle is present and updates the font.
  - The setting persists after saving and app restart.
- Tests are located in `test/screens/settings_screen_font_size_test.dart` and are run via the Taskfile (`task test`). 