import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
// sqflite_common_ffi is for native desktop platforms. Do not initialize on web.

// Import for web URL strategy
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web (remove # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Load environment variables`
  await dotenv.load();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  runApp(const ProviderScope(child: RepairShopApp()));
}
