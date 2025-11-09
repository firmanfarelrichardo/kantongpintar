// lib/pages/home/home_page.dart
// (100% Siap Pakai - Versi V5, dengan tombol ke Pockets Page)

import 'package:flutter/material.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/transaction.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';
import 'package:testflutter/pages/transaction/transaction_form_modal.dart';
import 'package:testflutter/pages/account/account_form_modal.dart';
import 'package:testflutter/pages/saving_goals/saving_goals_page.dart';
// BARU: Import halaman pockets
import 'package:testflutter/pages/pockets/pocket_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === 1. State Variables ===
  bool _isLoading = true;
  double _totalBalance = 0.0;
  List<Account> _accounts = [];
  List<Transaction> _recentTransactions = [];

  // === 2. Repository Instances ===
  final AccountRepository _accountRepo = AccountRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();

  // === 3. Lifecycle: initState ===
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // === 4. Data Loading Function ===
  Future<void> _loadData() async {
    setState(() { _isLoading = true; });

    try {
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _transactionRepo.getAllTransactions(),
      ]);

      final fetchedAccounts = results[0] as List<Account>;
      final fetchedTransactions = results[1] as List<Transaction>;

      double tempTotal = 0.0;
      for (final account in fetchedAccounts) {
        tempTotal += account.initialBalance;
      }
      for (final trx in fetchedTransactions) {
        if (trx.type == 'income') {
          tempTotal += trx.amount;
        } else if (trx.type == 'expense') {
          tempTotal -= trx.amount;
        }
      }

      if (mounted) {
        setState(() {
          _totalBalance = tempTotal;
          _accounts = fetchedAccounts;
          _recentTransactions = fetchedTransactions.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  // === 5. Modal & Page Helpers ===
  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return TransactionFormModal(
          onSaveSuccess: _loadData,
        );
      },
    );
  }

  void _showAddAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return AccountFormModal(
          onSaveSuccess: _loadData,
        );
      },
    );
  }
  
  void _navigateToSavingGoals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SavingGoalsPage(),
      ),
    ).then((_) => _loadData());
  }

  /// BARU: Navigasi ke Halaman Pockets (Budget)
  void _navigateToPockets() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PocketManagementPage(),
      ),
    ).then((_) => _loadData()); // Refresh data saat kembali
  }

  // === 6. Build Method (UI) ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantong Pintar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // === 7. Helper Widgets untuk UI ===
  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildTotalBalanceCard(),
        const SizedBox(height: 16),
        
        // BARU: Kartu Navigasi ke Pockets
        _buildPocketsCard(),
        const SizedBox(height: 8),

        // Kartu Navigasi ke Saving Goals
        _buildSavingGoalsCard(),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daftar Akunmu', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: _showAddAccountModal,
            ),
          ],
        ),
        _buildAccountList(),
        const SizedBox(height: 24),

        Text('Transaksi Terakhir', style: Theme.of(context).textTheme.titleLarge),
        _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildTotalBalanceCard() {
    // (Kode sama persis)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL SALDO',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${(_totalBalance).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// BARU: Helper untuk kartu navigasi "Pockets"
  Widget _buildPocketsCard() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.wallet, color: Colors.orange, size: 30),
        title: const Text('Kantong Budget', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Alokasikan dan lacak budget-mu'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _navigateToPockets,
      ),
    );
  }

  Widget _buildSavingGoalsCard() {
    // (Kode sama persis)
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.savings, color: Colors.green, size: 30),
        title: const Text('Tujuan Nabung', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Lacak progres tabunganmu di sini'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _navigateToSavingGoals,
      ),
    );
  }

  Widget _buildAccountList() {
    // (Kode sama persis)
    if (_accounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Klik tombol (+) di atas untuk menambah akun.')),
      );
    }
    
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Card(
            elevation: 2,
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    account.bankName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    'Rp ${account.initialBalance.toStringAsFixed(0)}',
                     style: const TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 12,
                     ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions() {
    // (Kode sama persis)
    if (_recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Belum ada transaksi.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        final trx = _recentTransactions[index];
        final isIncome = trx.type == 'income';
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
            title: Text(trx.description ?? 'Tanpa Deskripsi'),
            subtitle: Text(trx.transactionDate.toLocal().toString().split(' ')[0]),
            trailing: Text(
              '${isIncome ? '+' : '-'}Rp ${trx.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}