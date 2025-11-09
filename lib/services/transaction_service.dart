// transaction_service.dart

import '../models/transaction.dart';

/// Kelas Service untuk mengelola semua operasi CRUD transaksi.
/// Data disimpan dalam memori (RAM) menggunakan List<Transaction>.
class TransactionService {
  
  // =======================================================
  // Singleton Pattern: Memastikan hanya ada satu instance (Konsistensi)
  // Digunakan agar semua widget mengakses List<Transaction> yang sama.
  // =======================================================
  static final TransactionService _instance = TransactionService._internal();

  factory TransactionService() {
    return _instance;
  }

  TransactionService._internal();

  // List Transaksi: Tempat penyimpanan data utama (memory/RAM)
  final List<Transaction> _transactions = [];

  // =======================================================
  // READ: Mengambil semua transaksi.
  // =======================================================
  List<Transaction> getTransactions() {
    // Comments: Mengembalikan salinan List untuk mencegah perubahan data 
    // secara tidak sengaja dari luar Service.
    return List.unmodifiable(_transactions); 
  }

  // =======================================================
  // CREATE: Menambahkan transaksi baru.
  // =======================================================
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    // Comments: Mengurutkan list berdasarkan tanggal terbaru ke terlama
    _transactions.sort((a, b) => b.date.compareTo(a.date)); 
  }

  // =======================================================
  // UPDATE: Memperbarui transaksi berdasarkan ID.
  // =======================================================
  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  // =======================================================
  // DELETE: Menghapus transaksi berdasarkan ID.
  // =======================================================
  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
  }

  // =======================================================
  // Tambahan: Menghitung Saldo Saat Ini
  // =======================================================
  double calculateBalance() {
    double balance = 0;
    for (var t in _transactions) {
      if (t.type == TransactionType.income) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }
}