// lib/services/pocket_repository.dart
// (100% Siap Pakai - Menambahkan getAllPockets)

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/pocket.dart';

/// Repository untuk mengelola operasi CRUD tabel 'Pockets'.
class PocketRepository {
  final DatabaseService _dbService = DatabaseService();
  static const String _tableName = 'Pockets';

  /// CREATE: Menyimpan kantong baru
  Future<void> createPocket(Pocket pocket) async {
    final db = await _dbService.database;
    try {
      await db.insert(
        _tableName,
        pocket.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error createPocket: $e');
      rethrow;
    }
  }

  /// READ: Mengambil semua kantong (UNTUK HALAMAN BARU)
  Future<List<Pocket>> getAllPockets() async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'name ASC',
      );
      return List.generate(maps.length, (i) => Pocket.fromMap(maps[i]));
    } catch (e) {
      print('Error getAllPockets: $e');
      return [];
    }
  }

  /// READ: Mengambil semua kantong untuk satu akun
  Future<List<Pocket>> getPocketsForAccount(String accountId) async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'name ASC',
      );
      return List.generate(maps.length, (i) => Pocket.fromMap(maps[i]));
    } catch (e) {
      print('Error getPocketsForAccount: $e');
      return [];
    }
  }

  /// UPDATE: Memperbarui kantong
  Future<void> updatePocket(Pocket pocket) async {
    final db = await _dbService.database;
    try {
      await db.update(
        _tableName,
        pocket.toMap(),
        where: 'id = ?',
        whereArgs: [pocket.id],
      );
    } catch (e) {
      print('Error updatePocket: $e');
      rethrow;
    }
  }

  /// DELETE: Menghapus kantong
  Future<void> deletePocket(String id) async {
    final db = await _dbService.database;
    try {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deletePocket: $e');
      rethrow;
    }
  }
}