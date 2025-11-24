import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'repair_shop.db';
  static const int _databaseVersion = 1;

  static Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Local SQLite database is disabled on the web. Use backend APIs instead.',
      );
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      // For web, use a simple database name
      path = _databaseName;
    } else {
      final databasePath = await getDatabasesPath();
      path = join(databasePath, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    await database;
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await _createTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades
    if (oldVersion < newVersion) {
      // Add migration logic here
      await _createTables(db);
    }
  }

  static Future<void> _createTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT DEFAULT 'user',
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        parent_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (parent_id) REFERENCES categories(id)
      )
    ''');

    // Conditions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS conditions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Qualities table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS qualities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        grade_order INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        company_name TEXT,
        type TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        address TEXT,
        tax_number TEXT,
        location_link TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Item batches table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS item_batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        batch_number TEXT UNIQUE NOT NULL,
        supplier_id INTEGER,
        purchase_date TEXT,
        total_quantity INTEGER,
        total_cost REAL,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (supplier_id) REFERENCES customers(id)
      )
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER,
        brand TEXT,
        model TEXT,
        condition_id INTEGER,
        quality_id INTEGER,
        purchase_date TEXT,
        supplier_id INTEGER,
        batch_id INTEGER,
        stock_quantity INTEGER DEFAULT 0,
        unit_cost REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (condition_id) REFERENCES conditions(id),
        FOREIGN KEY (quality_id) REFERENCES qualities(id),
        FOREIGN KEY (supplier_id) REFERENCES customers(id),
        FOREIGN KEY (batch_id) REFERENCES item_batches(id)
      )
    ''');
    // Serial table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS serials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          imei TEXT UNIQUE NOT NULL,
          item_id INTEGER NOT NULL,
          batch_id INTEGER NOT NULL,
          status TEXT DEFAULT 'available',
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (item_id) REFERENCES items(id),
          FOREIGN KEY (batch_id) REFERENCES item_batches(id)
        )
      ''');

    // Repair states table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repair_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        color_code TEXT,
        order_sequence INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Issue types table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS issue_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        category TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Repairs table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repairs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repair_number TEXT UNIQUE NOT NULL,
        customer_id INTEGER NOT NULL,
        device_brand TEXT,
        device_model TEXT,
        device_imei TEXT,
        password TEXT,
        extra_info TEXT,
        state_id INTEGER,
        repair_date TEXT DEFAULT CURRENT_DATE,
        completion_date TEXT,
        estimated_cost REAL,
        final_cost REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (state_id) REFERENCES repair_states(id)
      )
    ''');

    // Repair issues table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repair_issues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repair_id INTEGER NOT NULL,
        issue_type_id INTEGER,
        description TEXT,
        is_resolved INTEGER DEFAULT 0,
        resolution_notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (repair_id) REFERENCES repairs(id),
        FOREIGN KEY (issue_type_id) REFERENCES issue_types(id)
      )
    ''');

    // Repair images table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repair_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repair_id INTEGER NOT NULL,
        image_type TEXT,
        local_path TEXT,
        cloud_url TEXT,
        file_size INTEGER,
        mime_type TEXT,
        sync_status INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (repair_id) REFERENCES repairs(id)
      )
    ''');

    // Stock usage table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repair_id INTEGER,
        item_id INTEGER NOT NULL,
        quantity_used INTEGER NOT NULL,
        usage_date TEXT DEFAULT CURRENT_DATE,
        notes TEXT,
        cost REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (repair_id) REFERENCES repairs(id),
        FOREIGN KEY (item_id) REFERENCES items(id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        retry_count INTEGER DEFAULT 0,
        last_attempt TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for better performance
    await _createIndexes(db);
  }

  static Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_items_category ON items(category_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_serials_imei ON serials(imei)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_serials_item ON serials(item_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_repairs_customer ON repairs(customer_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_repairs_date ON repairs(repair_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_repair_images_repair ON repair_images(repair_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_stock_usage_repair ON stock_usage(repair_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_table_record ON sync_queue(table_name, record_id)',
    );
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
