// lib/services/database_service.dart
// (100% Siap Pakai - Versi Revisi: Tanpa SavingGoals + Kategori Default)

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
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

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    // Saya ubah nama DB agar fresh (dibuat ulang dari awal)
    final path = join(documentsDirectory.path, 'kantong_pintar_final.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

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

    // === BAGIAN BARU: INSERT KATEGORI DEFAULT ===
    // Saya menggunakan emoji sebagai icon.

    // Kategori Pengeluaran (Expense)
    _insertDefaultCategory(batch, 'def_exp_1', 'Makanan', 'expense', '🍔');
    _insertDefaultCategory(batch, 'def_exp_2', 'Jajan', 'expense', '🍦');
    _insertDefaultCategory(batch, 'def_exp_3', 'Transportasi', 'expense', '🚗');
    _insertDefaultCategory(batch, 'def_exp_4', 'Belanja', 'expense', '🛒');
    _insertDefaultCategory(batch, 'def_exp_5', 'Tagihan & Listrik', 'expense', '⚡');
    _insertDefaultCategory(batch, 'def_exp_6', 'Hiburan', 'expense', '🎬');
    _insertDefaultCategory(batch, 'def_exp_7', 'Kesehatan', 'expense', '💊');
    _insertDefaultCategory(batch, 'def_exp_8', 'Pendidikan', 'expense', '📚');

    // Kategori Pemasukan (Income)
    _insertDefaultCategory(batch, 'def_inc_1', 'Gaji', 'income', '💰');
    _insertDefaultCategory(batch, 'def_inc_2', 'Bonus', 'income', '🎁');
    _insertDefaultCategory(batch, 'def_inc_3', 'Penjualan', 'income', '📈');
    _insertDefaultCategory(batch, 'def_inc_4', 'Investasi', 'income', '📊');

    await batch.commit(noResult: true);
  }

  // Helper function agar kode lebih rapi
  void _insertDefaultCategory(Batch batch, String id, String name, String type, String emoji) {
    batch.insert('Categories', {
      'id': id,
      'name': name,
      'type': type,
      'icon_emoji': emoji,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}