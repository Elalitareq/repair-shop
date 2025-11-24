Title: Request to Add Inline Platform Implementations for `file_picker`

Hello maintainers,

We are using `file_picker` in our project and encountered analytical warnings indicating the plugin references a default implementation for `linux`, `macos`, and `windows`, but the package does not provide an inline implementation in its `pubspec.yaml`:

- platforms: linux: default_package: file_picker
- platforms: macos: default_package: file_picker
- platforms: windows: default_package: file_picker

This triggers the following guidance from the Flutter tooling:

"The package `file_picker:<platform>` references `file_picker:<platform>` as the default package, but it does not provide an inline implementation, and therefore the `default_package` cannot be used. To fix this, either:

1. Avoid referencing a default implementation via `platforms: <platform>: default_package: file_picker`.
   OR
2. Provide an inline implementation in `file_picker` by adding a `pluginClass` or `dartPluginClass` entry under `platforms: <platform>` in the `file_picker` `pubspec.yaml`.
   "

Suggested sample snippet for `file_picker` package `pubspec.yaml` (example for `macos` and `windows`):

```yaml
flutter:
  plugin:
    platforms:
      macos:
        pluginClass: FilePickerMacOS
      windows:
        pluginClass: FilePickerWindows
      linux:
        pluginClass: FilePickerLinux
```

For pure-dart implementation or using platform interface patterns, you can also add `dartPluginClass` under each platform, e.g.:

```yaml
flutter:
  plugin:
    platforms:
      linux:
        dartPluginClass: FilePickerLinux
```

Until the package is updated, downstream apps can either:

- Add a platform alternative like `file_selector` which is the Flutter team's package for file selection APIs.

OR

- Continue using `file_picker` and ignore/accept analyzer warnings for the moment but avoid adding non-existent platform packages to `pubspec.yaml`
  (we removed the `file_picker_linux`, `file_picker_macos`, and `file_picker_windows` dependencies from our mobile app, because they are not available on pub.dev at time of editing).

If the plugin owners add platform-specific implementations in `file_picker`, this step will no longer be necessary and you (the downstream app) can rely on the single `file_picker` package.

Thanks for considering this change — it will remove warnings and make multi-platform integration smoother.

— Repair Shop Mobile
