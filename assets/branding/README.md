# Branding Assets

Place your branding assets here:

## App Icons

- `icons/app_icon.png` — 1024x1024px source icon (used to generate all platform sizes)
- `icons/app_icon_rounded.png` — Android adaptive icon foreground
- `icons/app_icon_background.png` — Android adaptive icon background

## Splash Screen

- `images/splash_logo.png` — Logo displayed on splash screen (512x512px recommended)

## Generate Icons

With `flutter_launcher_icons` package:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  windows:
    generate: true
    image_path: 'assets/icons/app_icon.png'
  image_path: 'assets/icons/app_icon.png'
```

Then run: `flutter pub run flutter_launcher_icons`

## Fonts

Add font files to `assets/fonts/` and register in `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: YourFont
      fonts:
        - asset: assets/fonts/YourFont-Regular.ttf
        - asset: assets/fonts/YourFont-Bold.ttf
          weight: 700
```
