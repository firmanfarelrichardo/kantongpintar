import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart' as model; // Pakai alias biar ga bentrok
import '../services/account_repository.dart';
import '../services/transaction_repository.dart';

class HomeProvider extends ChangeNotifier {
  final AccountRepository _accountRepo = AccountRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  double _totalBalance = 0.0;
  double get totalBalance => _totalBalance;

  double _totalIncome = 0.0;
  double get totalIncome => _totalIncome;

  double _totalExpense = 0.0;
  double get totalExpense => _totalExpense;

  List<TransactionDisplayItem> _recentTransactions = [];
  List<TransactionDisplayItem> get recentTransactions => _recentTransactions;

  // Fungsi utama untuk memuat data
  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners(); // Beritahu UI bahwa kita sedang loading

    try {
      final accounts = await _accountRepo.getAllAccounts();
      final transactions = await _transactionRepo.getAllTransactions();

      _calculateTotals(accounts, transactions);
      _processRecentTransactions(transactions, accounts);

    } catch (e) {
      print("Error loading home data: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Beritahu UI bahwa data siap
    }
  }

  void _calculateTotals(List<Account> accounts, List<model.Transaction> transactions) {
    double saldoAwal = 0.0;
    double pemasukan = 0.0;
    double pengeluaran = 0.0;

    // 1. Hitung saldo awal dari semua akun
    for (var acc in accounts) {
      saldoAwal += acc.initialBalance;
    }

    // 2. Hitung income dan expense dari transaksi
    for (var trx in transactions) {
      if (trx.type == 'income') {
        pemasukan += trx.amount;
      } else if (trx.type == 'expense') {
        pengeluaran += trx.amount;
      }
    }

    _totalIncome = pemasukan;
    _totalExpense = pengeluaran;
    // Rumus: Saldo Awal + Pemasukan - Pengeluaran
    _totalBalance = saldoAwal + pemasukan - pengeluaran;
  }

  void _processRecentTransactions(List<model.Transaction> transactions, List<Account> accounts) {
    // Buat Map akun untuk pencarian nama cepat
    final accountMap = {for (var acc in accounts) acc.id: acc.name};

    // Ambil 5 transaksi terakhir
    final recent = transactions.take(5).map((trx) {
      return TransactionDisplayItem(
        id: trx.id,
        amount: trx.amount,
        type: trx.type,
        categoryName: trx.description ?? 'Umum', // Sementara pakai deskripsi sbg judul
        description: accountMap[trx.accountId] ?? 'Akun',
        date: trx.transactionDate.toIso8601String(),
      );
    }).toList();

    _recentTransactions = recent;
  }
}

// Helper Class untuk data yang siap tampil di UI
class TransactionDisplayItem {
  final String id;
  final double amount;
  final String type;
  final String categoryName;
  final String description;
  final String date;

  TransactionDisplayItem({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.description,
    required this.date,
  });
}