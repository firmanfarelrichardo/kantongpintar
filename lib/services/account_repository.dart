// lib/services/account_repository.dart
// (100% Siap Pakai)

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/account.dart';

/// Repository untuk mengelola operasi CRUD tabel 'Accounts'.
class AccountRepository {
  final DatabaseService _dbService = DatabaseService();
  static const String _tableName = 'Accounts';

  /// CREATE: Menyimpan akun baru
  Future<void> createAccount(Account account) async {
    final db = await _dbService.database;
    try {
      await db.insert(
        _tableName,
        account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error createAccount: $e');
      rethrow;
    }
  }

  /// READ: Mengambil semua akun
  Future<List<Account>> getAllAccounts() async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'bank_name ASC',
      );
      return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
    } catch (e) {
      print('Error getAllAccounts: $e');
      return [];
    }
  }

  /// UPDATE: Memperbarui akun
  Future<void> updateAccount(Account account) async {
    final db = await _dbService.database;
    try {
      await db.update(
        _tableName,
        account.toMap(),
        where: 'id = ?',
        whereArgs: [account.id],
      );
    } catch (e) {
      print('Error updateAccount: $e');
      rethrow;
    }
  }

  /// DELETE: Menghapus akun
  /// PENTING: Ini akan gagal jika akun masih punya Pockets atau Transactions
  /// (karena aturan ON DELETE RESTRICT di skema SQL kita).
  Future<void> deleteAccount(String id) async {
    final db = await _dbService.database;
    try {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleteAccount: $e');
      rethrow;
    }
  }
}