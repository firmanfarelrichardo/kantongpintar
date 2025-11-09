// lib/services/transaction_repository.dart
// (100% Siap Pakai - FIX Error Ambiguous Import + Fungsi Agregasi)

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
// SOLUSI: Kita impor model kita 'as model' untuk memberinya nama panggilan
import '../models/transaction.dart' as model;

/// Repository untuk mengelola operasi CRUD (Create, Read, Update, Delete)
/// untuk entitas Transaksi.
class TransactionRepository {
  final DatabaseService _dbService = DatabaseService();

  static const String _tableName = 'Transactions';

  // === CREATE ===
  // Gunakan 'model.Transaction' untuk merujuk ke model kita
  Future<void> createTransaction(model.Transaction transaction) async {
    final db = await _dbService.database;
    try {
      await db.insert(
        _tableName,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error createTransaction: $e');
      rethrow;
    }
  }

  // === READ (Ambil semua) ===
  // Tipe data yang dikembalikan adalah List dari 'model.Transaction'
  Future<List<model.Transaction>> getAllTransactions() async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'transaction_date DESC',
      );
      // Gunakan 'model.Transaction.fromMap'
      return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
    } catch (e) {
      print('Error getAllTransactions: $e');
      return [];
    }
  }
  
  // === READ (Ambil per Akun) ===
  Future<List<model.Transaction>> getTransactionsForAccount(String accountId) async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'transaction_date DESC',
      );
      // Gunakan 'model.Transaction.fromMap'
      return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
    } catch (e) {
      print('Error getTransactionsForAccount: $e');
      return [];
    }
  }

  // === READ (Agregasi Pengeluaran per Kantong) ===
  Future<Map<String, double>> getAggregatedExpensesByPocket() async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        columns: ['pocket_id', 'SUM(amount) as total'],
        where: "type = 'expense' AND pocket_id IS NOT NULL",
        groupBy: 'pocket_id',
      );

      final Map<String, double> expensesMap = {
        for (var item in maps) 
          item['pocket_id'] as String : item['total'] as double
      };
      
      return expensesMap;

    } catch (e) {
      print('Error getAggregatedExpensesByPocket: $e');
      return {};
    }
  }

  // === UPDATE ===
  // Gunakan 'model.Transaction'
  Future<void> updateTransaction(model.Transaction transaction) async {
    final db = await _dbService.database;
    try {
      await db.update(
        _tableName,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      print('Error updateTransaction: $e');
      rethrow;
    }
  }

  // === DELETE ===
  Future<void> deleteTransaction(String id) async {
    final db = await _dbService.database;
    try {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleteTransaction: $e');
      rethrow;
    }
  }
}