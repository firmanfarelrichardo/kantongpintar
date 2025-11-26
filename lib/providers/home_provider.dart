import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/pocket.dart'; // IMPORT MODEL POCKET
import '../models/transaction.dart' as model;
import '../services/account_repository.dart';
import '../services/pocket_repository.dart'; // IMPORT REPO POCKET
import '../services/transaction_repository.dart';

class HomeProvider extends ChangeNotifier {
  final AccountRepository _accountRepo = AccountRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final PocketRepository _pocketRepo = PocketRepository(); // TAMBAH REPO

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

  List<model.Transaction> _allTransactions = [];
  List<model.Transaction> get allTransactions => _allTransactions;

  // === TAMBAHAN DATA POCKET & AKUN ===
  List<Pocket> _pockets = [];
  List<Pocket> get pockets => _pockets;

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;
  // ===================================

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load semua data sekaligus (Parallel)
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _transactionRepo.getAllTransactions(),
        _pocketRepo.getAllPockets(), // LOAD POCKETS JUGA
      ]);

      _accounts = results[0] as List<Account>;
      _allTransactions = results[1] as List<model.Transaction>;
      _pockets = results[2] as List<Pocket>; // SIMPAN POCKETS

      _calculateTotals(_accounts, _allTransactions);
      _processRecentTransactions(_allTransactions, _accounts);

    } catch (e) {
      print("Error loading home data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // (Sisa fungsi _calculateTotals dan _processRecentTransactions SAMA, tidak perlu diubah)
  void _calculateTotals(List<Account> accounts, List<model.Transaction> transactions) {
    double saldoAwal = 0.0;
    double pemasukan = 0.0;
    double pengeluaran = 0.0;

    for (var acc in accounts) {
      saldoAwal += acc.initialBalance;
    }

    for (var trx in transactions) {
      if (trx.type == 'income') {
        pemasukan += trx.amount;
      } else if (trx.type == 'expense') {
        pengeluaran += trx.amount;
      }
    }

    _totalIncome = pemasukan;
    _totalExpense = pengeluaran;
    _totalBalance = saldoAwal + pemasukan - pengeluaran;
  }

  void _processRecentTransactions(List<model.Transaction> transactions, List<Account> accounts) {
    final accountMap = {for (var acc in accounts) acc.id: acc.name};

    final recent = transactions.take(5).map((trx) {
      return TransactionDisplayItem(
        id: trx.id,
        amount: trx.amount,
        type: trx.type,
        categoryName: trx.description ?? 'Umum',
        description: accountMap[trx.accountId] ?? 'Akun',
        date: trx.transactionDate.toIso8601String(),
      );
    }).toList();

    _recentTransactions = recent;
  }
}

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