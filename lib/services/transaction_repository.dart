// lib/services/transaction_repository.dart
// (100% Siap Pakai)
// Ini adalah pengganti profesional untuk transaction_service.dart

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/transaction.dart'; // Model yang baru kita buat

/// Repository untuk mengelola operasi CRUD (Create, Read, Update, Delete)
/// untuk entitas Transaksi.
/// Ini adalah "Departemen Transaksi" yang hanya berbicara dengan
/// "Juru Kunci Brankas" (DatabaseService).
class TransactionRepository {
  final DatabaseService _dbService = DatabaseService();

  /// NAMA TABEL: Didefinisikan sebagai konstanta
  /// (Clean Code: Reusabilitas + Konsistensi)
  static const String _tableName = 'Transactions';

  // === CREATE ===
  /// Menyimpan transaksi baru ke database lokal (SQLite).
  Future<void> createTransaction(Transaction transaction) async {
    final db = await _dbService.database;
    try {
      await db.insert(
        _tableName,
        transaction.toMap(), // Menggunakan model 'toMap'
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Implementasi error handling profesional
      print('Error createTransaction: $e');
      rethrow; // Lemparkan error agar UI bisa menangani
    }
  }

  // === READ (Contoh: Ambil semua transaksi) ===
  /// Mengambil semua transaksi dari database, diurutkan dari yang terbaru.
  Future<List<Transaction>> getAllTransactions() async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'transaction_date DESC', // Urutkan berdasarkan tanggal
      );

      // Ubah List<Map> menjadi List<Transaction> menggunakan model 'fromMap'
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      print('Error getAllTransactions: $e');
      return []; // Kembalikan list kosong jika error
    }
  }
  
  // === READ (Contoh: Ambil transaksi berdasarkan Akun) ===
  /// Mengambil semua transaksi untuk 'accountId' tertentu.
  Future<List<Transaction>> getTransactionsForAccount(String accountId) async {
    final db = await _dbService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'transaction_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      print('Error getTransactionsForAccount: $e');
      return [];
    }
  }

  // === UPDATE ===
  /// Memperbarui data transaksi yang sudah ada di database.
  Future<void> updateTransaction(Transaction transaction) async {
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
  /// Menghapus transaksi dari database berdasarkan ID-nya.
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