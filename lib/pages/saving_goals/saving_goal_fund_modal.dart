// lib/pages/saving_goals/saving_goal_fund_modal.dart
// (100% Siap Pakai - FILE BARU)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/models/saving_goal.dart';
import 'package:testflutter/models/transaction.dart' as model;
import 'package:testflutter/services/pocket_repository.dart';
import 'package:testflutter/services/saving_goal_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';

/// Modal untuk menambah dana ke "Tujuan Nabung" (Saving Goal).
class SavingGoalFundModal extends StatefulWidget {
  /// Tujuan yang akan diisi dananya.
  final SavingGoal goal;
  
  /// Callback untuk me-refresh halaman SavingGoalsPage.
  final VoidCallback onSaveSuccess;

  const SavingGoalFundModal({
    required this.goal,
    required this.onSaveSuccess,
    super.key,
  });

  @override
  State<SavingGoalFundModal> createState() => _SavingGoalFundModalState();
}

class _SavingGoalFundModalState extends State<SavingGoalFundModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Repositories
  final _goalRepo = SavingGoalRepository();
  final _pocketRepo = PocketRepository();
  final _transactionRepo = TransactionRepository();

  // Controller
  final _amountController = TextEditingController();

  // State
  bool _isLoading = true;
  bool _isSaving = false;
  List<Pocket> _pockets = [];
  String? _selectedPocketId;
  
  // State untuk melacak sisa budget kantong
  Map<String, double> _pocketExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadPockets();
  }

  /// Memuat semua kantong (budget) yang tersedia
  Future<void> _loadPockets() async {
    setState(() { _isLoading = true; });
    try {
      // Kita butuh 2 data: daftar kantong & total pengeluaran per kantong
      final results = await Future.wait([
         _pocketRepo.getAllPockets(),
         _transactionRepo.getAggregatedExpensesByPocket(),
      ]);
       
      if (mounted) {
        setState(() {
          _pockets = results[0] as List<Pocket>;
          _pocketExpenses = results[1] as Map<String, double>;
          
          if (_pockets.isNotEmpty) {
            _selectedPocketId = _pockets.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar kantong: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Menyimpan alokasi dana
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPocketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kantong sumber dana.')),
      );
      return;
    }
    
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final pocket = _pockets.firstWhere((p) => p.id == _selectedPocketId);
    final spent = _pocketExpenses[pocket.id] ?? 0.0;
    final remaining = pocket.budgetedAmount - spent;

    // Validasi sisa budget
    if (amount > remaining) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dana di kantong "${pocket.name}" tidak cukup (Sisa: Rp $remaining)')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();

      // === Aksi 1: Update Saving Goal ===
      final updatedGoal = widget.goal.copyWith(
        currentAmount: widget.goal.currentAmount + amount,
        updatedAt: now,
      );
      
      // === Aksi 2: Buat Transaksi Pengeluaran ===
      final newTransaction = model.Transaction(
        id: now.millisecondsSinceEpoch.toString(),
        // Ambil 'accountId' dari kantong yang dipilih
        accountId: pocket.accountId,
        amount: amount,
        type: 'expense',
        description: 'Menabung untuk: ${widget.goal.name}',
        transactionDate: now,
        // Hubungkan ke kantong (untuk mengurangi budget)
        pocketId: _selectedPocketId!, 
        // Hubungkan ke kategori "Tujuan Nabung" (jika ada)
        categoryId: null, // TODO: Bisa dibuat kategori khusus "Nabung"
        createdAt: now,
        updatedAt: now,
      );
      
      // Eksekusi kedua aksi
      await _goalRepo.updateGoal(updatedGoal);
      await _transactionRepo.createTransaction(newTransaction);

      // Panggil callback untuk refresh
      widget.onSaveSuccess();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dana berhasil ditambahkan! 💸')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: 20,
          right: 20,
          bottom: 20 + bottomPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah Dana ke "${widget.goal.name}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // === Input Jumlah ===
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  hintText: '50000',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                validator: (v) {
                  if (v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) {
                    return 'Masukkan jumlah yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // === Dropdown Kantong (Pockets) ===
              _buildPocketDropdown(),
              const SizedBox(height: 30),

              // === Tombol Simpan ===
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isSaving ? null : _submitForm,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'TAMBAH DANA',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Helper untuk dropdown kantong (Pockets)
  Widget _buildPocketDropdown() {
    if (_pockets.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Sumber Dana (Kantong)',
          errorText: 'Buat kantong budget terlebih dahulu!',
        ),
      );
    }
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Sumber Dana (Kantong)'),
      value: _selectedPocketId,
      items: _pockets.map((pocket) {
        // Hitung sisa budget
        final spent = _pocketExpenses[pocket.id] ?? 0.0;
        final remaining = pocket.budgetedAmount - spent;
        return DropdownMenuItem(
          value: pocket.id,
          child: Text('${pocket.name} (Sisa: Rp $remaining)'),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedPocketId = v),
      validator: (v) => v == null ? 'Wajib dipilih.' : null,
    );
  }
}