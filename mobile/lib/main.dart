import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
// sqflite_common_ffi is for native desktop platforms. Do not initialize on web.
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Import for web URL strategy
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/app/app.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web (remove # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize sqflite for non-web (desktop) platforms only.
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Load environment variables
  await dotenv.load();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize SQLite database (skip on web; we'll use backend API only in web builds)
  if (!kIsWeb) {
    await DatabaseHelper.initialize();
  } else {
    // For web builds we don't initialize the local DB; the app will rely on backend APIs.
    // This prevents sqflite/ffi errors on web and aligns with using the backend as the source of truth.
  }

  if (kIsWeb) {
    // Helpful runtime message for debugging and to make it explicit in logs
    // that the client will rely on backend APIs and not local DB.
    debugPrint(
      'Running on web: local SQLite database disabled; using backend APIs only.',
    );
  }

  runApp(const ProviderScope(child: RepairShopApp()));
}
