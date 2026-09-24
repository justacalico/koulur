# koulur

A colour palette generator for every platform. Generate harmonious five-colour
palettes, lock the shades you like, copy hex codes with a tap.

## Features

- Six harmony modes: random, analogous, complementary, triadic, tetradic,
  monochromatic
- Lock individual colours and reshuffle the rest
- Tap a swatch to copy its hex code
- Built with Flutter: Android, iOS, Linux, Windows, macOS and web

## Install

Prebuilt binaries for every platform are attached to each
[release](https://gitlab.com/HttpAnimations/koulur/-/releases) and never
expire. The web build is also live on
[GitLab Pages](https://koulur-288b3e.gitlab.io/).

| Platform | Package |
|----------|---------|
| Android  | APK / AAB (signed) |
| iOS      | unsigned `.ipa`, sideload via AltStore |
| Linux    | tar.gz, zip, .deb, .rpm, AppImage (x86_64 + arm64) |
| Windows  | zip (x86_64 + arm64) |
| macOS    | dmg / zip (Apple Silicon) |
| Web      | `web.tar.gz` |

### AltStore

Add the source in AltStore under Sources → +:

```
https://koulur-288b3e.gitlab.io/altstore/apps.json
```

## Build from source

```bash
flutter pub get
flutter run            # pick a device
flutter build apk      # or linux / windows / macos / web / ipa
```

## Development

- Commits follow [Conventional Commits](https://www.conventionalcommits.org)
  and are checked by [cocogitto](https://github.com/cocogitto/cocogitto).
- Releases are cut automatically: `cog bump --auto` on every push to `main`
  decides the next version from the commit history.
- `flutter test --coverage`; the CI gate requires 100% line coverage.

## License

[AGPL-3.0](LICENSE)
