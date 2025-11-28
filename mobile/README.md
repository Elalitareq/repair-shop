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

You can also run the helper to search for generated entrypoints and related build artifacts:

```bash
./scripts/find_web_entrypoint.sh
```

If you run from VS Code, make sure your launch configuration doesn't point to a custom, non-existent entrypoint and restart the Dart & Flutter extension.

Helpful scripts available in `mobile/scripts/`:

- `./scripts/rebuild_web.sh` — cleans and rebuilds web artifacts
- `./scripts/run_web.sh` — starts flutter run for web (defaults to bodyless 'chrome' device) and will regenerate the entrypoint while launching a debug session
- `./scripts/find_web_entrypoint.sh` — searches for generated entrypoints in common build locations

- `./scripts/serve_build.sh` — serve the static `build/web` folder using python3 or `http-server` for quick debugging (prevents `file://` and CORS errors)

If the issue persists, check the `build/web` directory for generated files like `main.dart.js` and `index.html` and confirm that `lib/main.dart` contains `void main()`.

Also verify Flutter web support is enabled on your machine:

```bash
flutter doctor -v
```

If web support is not enabled, run:

````bash
flutter config --enable-web

Note: This project uses a backend-first architecture — the mobile frontend no longer initializes or uses a local SQLite database. All persistence and data operations are performed via the backend APIs. If you need local DB for a specific platform in the future, we recommend adding a platform-specific implementation, but do so deliberately and keep server sync logic separate.

## Deployment

This repo includes a simple deployment helper and example Nginx config to help publish the `build/web` artifacts to a server.

Files added:
- `mobile/scripts/deploy_to_server.sh` — rsync-based deploy script that copies `build/web/` into a remote path, optionally changes owner, reloads Nginx and runs a health check.
- `mobile/deploy/nginx/repair_shop.conf` — example Nginx server config tuned for Flutter web (static assets served directly, correct caching for fingerprinted assets, and SPA fallback for other URLs).

Deploy example (root deploy):
```bash
cd mobile
chmod +x scripts/deploy_to_server.sh
./scripts/deploy_to_server.sh --host root@185.70.185.15 --remote-path /var/www/repair_shop_web --reload --base-url https://repairshop.thefallenpc.com

Override the API base URL at deploy time (optional):
````

./scripts/deploy_to_server.sh --host root@185.70.185.15 --remote-path /var/www/repair_shop_web --reload --chown www-data:www-data --api-base-url https://repairshop.thefallenpc.com/api --env-file .env

```

```

The script uses `rsync -avz` and `--delete` so your remote folder reflects the build output exactly. It also supports `--chown owner:group` if you want to update ownership, and `--reload` to run `sudo nginx -t && sudo systemctl reload nginx` on the remote host.

Security & SSH notes:

- The script assumes SSH key-based login for convenience; if your server requires password authentication you may want to use an SSH agent or `rsync` setup with a key.
- Use a deploy account with minimal privileges where possible (avoid deploying as root if not necessary). The script will attempt to `sudo` only when `--reload` or `--chown` require it.

After deploy, validate the site with the asset check helper:

````bash
chmod +x scripts/check_server_assets.sh
./scripts/check_server_assets.sh https://repairshop.thefallenpc.com

Also verify that your Nginx configuration proxies API requests to your backend API and does not apply SPA fallback to `/api/` paths. If an API fetch returns HTML (index.html) and your app tries to parse JSON it will throw a syntax error like `Unexpected token '<'`.

Use the API check helper to verify JSON endpoints:

```bash
chmod +x scripts/check_api_endpoints.sh
./scripts/check_api_endpoints.sh https://repairshop.thefallenpc.com /api/health /api/backups/download
````

If the script prints HTML content for the endpoint or the `Content-Type` is `text/html`, ensure your Nginx config contains the `location /api/` proxy rule and reload Nginx.

```

```
