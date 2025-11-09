// lib/pages/home/home_page.dart
// (100% Siap Pakai - Versi V2, Terhubung dengan Modal Baru)

import 'package:flutter/material.dart';
import 'package:testflutter/models/account.dart'; // Model baru
import 'package:testflutter/models/transaction.dart'; // Model baru
import 'package:testflutter/services/account_repository.dart'; // Repo baru
import 'package:testflutter/services/transaction_repository.dart'; // Repo baru
// Import modal BARU, bukan yang lama
import 'package:testflutter/pages/transaction/transaction_form_modal.dart';

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
  /// Mengambil semua data dari database dan menghitung kalkulasi
  Future<void> _loadData() async {
    // Tampilkan loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ambil semua data secara paralel
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _transactionRepo.getAllTransactions(),
      ]);

      // 2. Pisahkan data
      final fetchedAccounts = results[0] as List<Account>;
      final fetchedTransactions = results[1] as List<Transaction>;

      // 3. Kalkulasi Total Saldo (Fitur Utama)
      double tempTotal = 0.0;
      
      // Tambahkan semua saldo awal dari setiap akun
      for (final account in fetchedAccounts) {
        tempTotal += account.initialBalance;
      }

      // Tambah/Kurangi berdasarkan histori transaksi
      for (final trx in fetchedTransactions) {
        if (trx.type == 'income') {
          tempTotal += trx.amount;
        } else if (trx.type == 'expense') {
          tempTotal -= trx.amount;
        }
        // Tipe 'transfer' tidak mempengaruhi total saldo (uang hanya pindah)
      }

      // 4. Update State untuk "Gambar Ulang"
      setState(() {
        _totalBalance = tempTotal;
        _accounts = fetchedAccounts;
        // Ambil 5 transaksi terbaru untuk ditampilkan
        _recentTransactions = fetchedTransactions.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Error handling jika database gagal
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  // === 5. Helper untuk menampilkan Modal Transaksi (UPDATE DARI LANGKAH SEBELUMNYA) ===
  /// Fungsi ini dipanggil oleh FloatingActionButton
  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar keyboard tidak menutupi
      builder: (ctx) {
        // Panggil TransactionFormModal BARU
        return TransactionFormModal(
          // Ini adalah kuncinya:
          // Kita 'memberikan' fungsi _loadData ke modal.
          // Saat modal memanggil onSaveSuccess, _loadData akan dieksekusi.
          onSaveSuccess: _loadData,
        );
      },
    );
  }

  // === 6. Build Method (UI) (UPDATE DARI LANGKAH SEBELUMNYA) ===
  // Ganti seluruh method 'build' kamu dengan yang ini
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantong Pintar (V2)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData, // Panggil ulang fungsi _loadData
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      
      // FloatingActionButton sekarang memanggil helper baru kita
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal, // <-- DIUBAH DI SINI
        child: const Icon(Icons.add),
      ),
    );
  }

  // === 7. Helper Widgets untuk UI ===

  /// Widget untuk membangun konten utama (dipisah agar `build` tetap bersih)
  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // === Kartu Total Saldo (Tema Gen Z) ===
        _buildTotalBalanceCard(),
        const SizedBox(height: 24),

        // === Daftar Akun (Multi-Bank) ===
        Text('Daftar Akunmu', style: Theme.of(context).textTheme.titleLarge),
        _buildAccountList(),
        const SizedBox(height: 24),

        // === Transaksi Terakhir ===
        Text('Transaksi Terakhir', style: Theme.of(context).textTheme.titleLarge),
        _buildRecentTransactions(),
      ],
    );
  }

  /// Widget untuk kartu total saldo
  Widget _buildTotalBalanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple, // Tema "Gen Z"
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
              // Format mata uang (akan kita perbaiki nanti)
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

  /// Widget untuk menampilkan daftar akun
  Widget _buildAccountList() {
    if (_accounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Kamu belum punya akun. Tambahkan satu!')),
      );
    }
    
    // Tampilkan secara horizontal agar keren
    return Container(
      height: 100, // Tinggi kartu akun
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Card(
            elevation: 2,
            child: Container(
              width: 150, // Lebar kartu akun
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(account.bankName, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget untuk menampilkan transaksi terakhir
  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('Belum ada transaksi.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Agar bisa di dalam ListView utama
      physics: const NeverScrollableScrollPhysics(), // Non-scrollable
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