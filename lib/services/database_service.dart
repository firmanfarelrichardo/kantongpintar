// lib/services/database_service.dart
// (100% Siap Pakai - FIX Error 'join' undefined)

import 'package:path/path.dart'; // <-- SOLUSI: Impor paket 'path'
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// Kelas ini berfungsi sebagai "Juru Kunci" (Database Helper) untuk seluruh aplikasi.
/// Dibuat sebagai Singleton agar hanya ada satu instance koneksi database
/// yang aktif di seluruh aplikasi.
class DatabaseService {
  // === 1. Singleton Pattern ===
  
  static DatabaseService? _instance;
  static Database? _database;

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  // === 2. Inisialisasi Database ===

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    // Fungsi 'join' sekarang dikenali karena kita sudah mengimpor 'package:path/path.dart'
    final path = join(documentsDirectory.path, 'kantong_pintar_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  /// Fungsi privat untuk mengeksekusi skrip SQL saat database dibuat.
  Future<void> _createDB(Database db, int version) async {
    final batch = db.batch();

    // 1. Tabel Accounts
    batch.execute('''
      CREATE TABLE Accounts (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        bank_name TEXT NOT NULL,
        initial_balance REAL NOT NULL DEFAULT 0.0,
        icon_path TEXT,
        created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'))
      );
    ''');
    batch.execute('''
      CREATE TRIGGER trg_accounts_updated_at
      AFTER UPDATE ON Accounts
      FOR EACH ROW
      BEGIN
          UPDATE Accounts 
          SET updated_at = STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now') 
          WHERE id = OLD.id;
      END;
    ''');

    // 2. Tabel Categories
    batch.execute('''
      CREATE TABLE Categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        icon_emoji TEXT,
        parent_id TEXT,
        created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        FOREIGN KEY (parent_id) REFERENCES Categories(id) ON DELETE SET NULL
      );
    ''');
    batch.execute('CREATE INDEX idx_categories_parent ON Categories(parent_id);');
    batch.execute('''
      CREATE TRIGGER trg_categories_updated_at
      AFTER UPDATE ON Categories
      FOR EACH ROW
      BEGIN
          UPDATE Categories 
          SET updated_at = STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now') 
          WHERE id = OLD.id;
      END;
    ''');
    
    // 3. Tabel Pockets
    batch.execute('''
      CREATE TABLE Pockets (
        id TEXT PRIMARY KEY NOT NULL,
        account_id TEXT NOT NULL,
        category_id TEXT,
        name TEXT NOT NULL,
        budgeted_amount REAL NOT NULL DEFAULT 0.0,
        created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        FOREIGN KEY (account_id) REFERENCES Accounts(id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE SET NULL
      );
    ''');
    batch.execute('CREATE INDEX idx_pockets_account ON Pockets(account_id);');
    batch.execute('CREATE INDEX idx_pockets_category ON Pockets(category_id);');

    // 4. Tabel Transactions
    batch.execute('''
      CREATE TABLE Transactions (
        id TEXT PRIMARY KEY NOT NULL,
        account_id TEXT NOT NULL,
        category_id TEXT,
        pocket_id TEXT,
        transfer_group_id TEXT,
        amount REAL NOT NULL CHECK (amount > 0),
        type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
        description TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        FOREIGN KEY (account_id) REFERENCES Accounts(id) ON DELETE RESTRICT,
        FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE SET NULL,
        FOREIGN KEY (pocket_id) REFERENCES Pockets(id) ON DELETE SET NULL
      );
    ''');
    batch.execute('CREATE INDEX idx_transactions_date ON Transactions(transaction_date);');
    
    // 5. Tabel SavingGoals
    batch.execute('''
      CREATE TABLE SavingGoals (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL CHECK (target_amount > 0),
        current_amount REAL NOT NULL DEFAULT 0.0,
        target_date TEXT,
        icon_emoji TEXT,
        created_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        updated_at TEXT NOT NULL DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'))
      );
    ''');

    await batch.commit(noResult: true);
  }
}