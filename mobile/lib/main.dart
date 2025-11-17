import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  // Initialize sqflite for web
  if (kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Load environment variables
  await dotenv.load();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize SQLite database
  await DatabaseHelper.initialize();

  runApp(const ProviderScope(child: RepairShopApp()));
}
