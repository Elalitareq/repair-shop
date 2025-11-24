# repair_shop_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Troubleshooting: Flutter web "web_entrypoint.dart" missing

If you see an error like "web_entrypoint.dart. DOESNT EXIST", the Flutter tool is trying to use the generated web entrypoint during a web build or run but it hasn't been created or was removed (for example after a `flutter clean`).

Try these steps to re-generate the artifact:

```bash
# From the `mobile` folder
flutter clean
flutter pub get
flutter config --enable-web
flutter build web
```

Alternatively, use the provided helper script to automate the steps:

```bash
./scripts/rebuild_web.sh
```

If you run from VS Code, make sure your launch configuration doesn't point to a custom, non-existent entrypoint and restart the Dart & Flutter extension.

If the issue persists, check the `build/web` directory for generated files like `main.dart.js` and `index.html` and confirm that `lib/main.dart` contains `void main()`.

