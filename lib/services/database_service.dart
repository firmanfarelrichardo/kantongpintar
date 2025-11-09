// lib/services/database_service.dart

import 'package_path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// Kelas ini berfungsi sebagai "Juru Kunci" (Database Helper) untuk seluruh aplikasi.
/// Dibuat sebagai Singleton agar hanya ada satu instance koneksi database
/// yang aktif di seluruh aplikasi.
class DatabaseService {
  // === 1. Singleton Pattern ===
  
  // Instance privat yang statik
  static DatabaseService? _instance;
  
  // Database instance privat dari sqflite
  static Database? _database;

  /// Konstruktor factory untuk mengembalikan instance singleton
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  /// Konstruktor privat internal
  DatabaseService._internal();

  /// Getter publik untuk database.
  /// Ini akan menginisialisasi database jika belum ada.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // Jika database null, kita inisialisasi
    _database = await _initDB();
    return _database!;
  }

  // === 2. Inisialisasi Database ===

  /// Fungsi untuk menginisialisasi database.
  Future<Database> _initDB() async {
    // Mendapatkan path direktori yang aman untuk menyimpan database
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'kantong_pintar_v2.db');

    // Membuka database
    return await openDatabase(
      path,
      version: 1, // Versi database (penting untuk migrasi)
      
      // onConfigure: Dipanggil sebelum onCreate/onUpgrade
      onConfigure: (db) async {
        // WAJIB: Mengaktifkan Foreign Key constraint
        await db.execute('PRAGMA foreign_keys = ON');
      },
      
      // onCreate: Dipanggil HANYA JIKA database belum ada di 'path'
      onCreate: _createDB,
    );
  }

  /// Fungsi privat untuk mengeksekusi skrip SQL saat database dibuat.
  Future<void> _createDB(Database db, int version) async {
    // Gunakan 'batch' untuk mengeksekusi beberapa perintah SQL sekaligus
    // Ini lebih efisien dan transaksional (jika satu gagal, semua gagal)
    final batch = db.batch();

    // === MENJALANKAN SKEMA DARI TAHAP 1 ===

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
    // Trigger Accounts
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
    // Trigger Categories
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

    // Eksekusi semua perintah SQL dalam batch
    await batch.commit(noResult: true);
  }

  // === 3. CONTOH METODE CRUD (CREATE, READ, UPDATE, DELETE) ===
  
  // Ini adalah contoh bagaimana kita akan berinteraksi dengan tabel.
  // Kita akan butuh model Dart (misal: 'Account') untuk ini.

  /* // (Ini adalah L-angakah selanjutnya, kita buat modelnya dulu)

  // CREATE: Contoh memasukkan Akun baru
  Future<void> createAccount(Account account) async {
    final db = await database;
    await db.insert(
      'Accounts',       // Nama tabel
      account.toMap(),  // Data (diubah dari Object -> Map)
      conflictAlgorithm: ConflictAlgorithm.replace, // Jika ID sama, timpa
    );
  }

  // READ: Contoh mengambil semua Akun
  Future<List<Account>> getAccounts() async {
    final db = await database;
    
    // Query ke tabel 'Accounts'
    final List<Map<String, dynamic>> maps = await db.query('Accounts');

    // Ubah List<Map> menjadi List<Account>
    return List.generate(maps.length, (i) {
      return Account.fromMap(maps[i]);
    });
  }
  
  // UPDATE
  Future<void> updateAccount(Account account) async {
    final db = await database;
    await db.update(
      'Accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  // DELETE
  Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete(
      'Accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  */
}