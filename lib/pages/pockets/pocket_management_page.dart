// lib/pages/pockets/pocket_management_page.dart
// (100% Siap Pakai - VERSI BARU dengan kalkulasi sisa budget)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/services/pocket_repository.dart';
import 'package:testflutter/pages/pockets/pocket_form_modal.dart';
// BARU: Impor TransactionRepository
import 'package:testflutter/services/transaction_repository.dart';

class PocketManagementPage extends StatefulWidget {
  const PocketManagementPage({super.key});

  @override
  State<PocketManagementPage> createState() => _PocketManagementPageState();
}

class _PocketManagementPageState extends State<PocketManagementPage> {
  // === 1. State & Repositories ===
  bool _isLoading = true;
  List<Pocket> _pockets = [];
  Map<String, Account> _accountMap = {};
  Map<String, Category> _categoryMap = {};
  // BARU: Menyimpan total pengeluaran per kantong
  Map<String, double> _pocketExpenses = {};

  final _pocketRepo = PocketRepository();
  final _accountRepo = AccountRepository();
  final _categoryRepo = CategoryRepository();
  // BARU: TransactionRepo
  final _transactionRepo = TransactionRepository();

  // === 2. Lifecycle ===
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // === 3. Data Loading (DIUPDATE) ===
  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      // Muat semua data yang diperlukan secara paralel
      final results = await Future.wait([
        _pocketRepo.getAllPockets(),
        _accountRepo.getAllAccounts(),
        _categoryRepo.getCategoriesByType('expense'),
        // BARU: Ambil data agregasi pengeluaran
        _transactionRepo.getAggregatedExpensesByPocket(), 
      ]);

      // Buat Peta (Maps) untuk pencocokan
      final pockets = results[0] as List<Pocket>;
      final accounts = results[1] as List<Account>;
      final categories = results[2] as List<Category>;
      // BARU: Simpan data pengeluaran
      final expenses = results[3] as Map<String, double>; 
      
      final accMap = { for (var a in accounts) a.id : a };
      final catMap = { for (var c in categories) c.id : c };
      
      if (mounted) {
        setState(() {
          _pockets = pockets;
          _accountMap = accMap;
          _categoryMap = catMap;
          _pocketExpenses = expenses; // <-- BARU
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data kantong: $e')),
        );
      }
    }
  }

  // === 4. Modal Helper ===
  void _showAddPocketModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return PocketFormModal(
          onSaveSuccess: _loadData, // Callback untuk me-refresh
        );
      },
    );
  }

  // === 5. Build Method ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantong Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPocketList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPocketModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Helper untuk membangun daftar "Kantong" (DIUPDATE)
  Widget _buildPocketList() {
    if (_pockets.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kantong budget.\nKlik (+) untuk membuat.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    final formatCurrency = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _pockets.length,
      itemBuilder: (context, index) {
        final pocket = _pockets[index];
        
        final accountName = _accountMap[pocket.accountId]?.name ?? '...';
        final categoryName = _categoryMap[pocket.categoryId]?.name ?? 'Umum';
        
        // === KALKULASI REAL-TIME ===
        final expenses = _pocketExpenses[pocket.id] ?? 0.0;
        final remaining = pocket.budgetedAmount - expenses;
        // Safety check agar pembagian tidak error jika budget 0
        final progress = (pocket.budgetedAmount > 0)
            ? (expenses / pocket.budgetedAmount).clamp(0.0, 1.0)
            : 0.0;
        // === SELESAI KALKULASI ===

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  pocket.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sumber: $accountName', // Info tambahan
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                
                // Progress Bar (sudah fungsional)
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.8 ? Colors.red : (progress > 0.5 ? Colors.orange : Colors.green),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),

                // Label Progress (sudah fungsional)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sisa: ${formatCurrency.format(remaining)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      '(${formatCurrency.format(expenses)} / ${formatCurrency.format(pocket.budgetedAmount)})',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}