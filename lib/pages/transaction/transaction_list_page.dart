// lib/pages/transaction/transaction_list_page.dart
// (100% Siap Pakai - Menggantikan file lama)
// Terhubung dengan TransactionRepository & AccountRepository

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/transaction.dart' as model;
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  // === 1. State Variables ===
  bool _isLoading = true;
  List<model.Transaction> _transactions = [];
  
  /// Map untuk menyimpan data Akun (ID -> Objek Akun)
  /// Ini adalah cara profesional untuk menghindari query N+1 di dalam ListView.
  Map<String, Account> _accountMap = {};

  // === 2. Repository Instances ===
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // === 3. Data Loading Function ===
  /// Memuat semua transaksi DAN semua akun untuk pencocokan nama
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ambil semua data secara paralel
      final results = await Future.wait([
        _transactionRepo.getAllTransactions(),
        _accountRepo.getAllAccounts(),
      ]);

      final fetchedTransactions = results[0] as List<model.Transaction>;
      final fetchedAccounts = results[1] as List<Account>;

      // 2. Buat "Peta" Akun untuk pencarian cepat
      // Ini mengubah List<Account> menjadi Map<String, Account>
      // Kunci: ID Akun, Nilai: Objek Akun
      final accountMap = { for (var acc in fetchedAccounts) acc.id : acc };

      // 3. Update State
      setState(() {
        _transactions = fetchedTransactions;
        _accountMap = accountMap;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat transaksi: $e')),
      );
    }
  }

  // === 4. Build Method (UI) ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData, // Tombol refresh
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTransactionList(),
    );
  }

  /// Widget untuk menampilkan daftar transaksi
  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada transaksi.\nCoba tambahkan satu dari halaman Home!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Menggunakan ListView.separated untuk garis pemisah
    return ListView.separated(
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final trx = _transactions[index];
        
        // Ambil nama akun dari Map (pencarian super cepat)
        final accountName = _accountMap[trx.accountId]?.name ?? 'Akun Dihapus';
        
        // Tentukan ikon dan warna
        final isIncome = trx.type == 'income';
        final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
        final color = isIncome ? Colors.green : Colors.red;
        final sign = isIncome ? '+' : '-';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            trx.description ?? 'Tanpa Deskripsi',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            // Tampilkan Nama Akun dan Tanggal
            '$accountName\n${DateFormat('EEEE, d MMM yyyy').format(trx.transactionDate)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          isThreeLine: true, // Izinkan subtitle memiliki 2 baris
          trailing: Text(
            '$sign Rp ${trx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          // TODO: Tambahkan fungsi onTap untuk Edit/Delete
          onTap: () {
            // Kita bisa panggil modal edit di sini nanti
          },
        );
      },
    );
  }
}