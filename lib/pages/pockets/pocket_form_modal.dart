// lib/pages/pockets/pocket_form_modal.dart
// (100% Siap Pakai - FILE BARU)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/services/pocket_repository.dart';

/// Modal untuk membuat "Kantong" (Budget) baru.
class PocketFormModal extends StatefulWidget {
  final VoidCallback onSaveSuccess;

  const PocketFormModal({
    required this.onSaveSuccess,
    super.key,
  });

  @override
  State<PocketFormModal> createState() => _PocketFormModalState();
}

class _PocketFormModalState extends State<PocketFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _pocketRepo = PocketRepository();
  final _accountRepo = AccountRepository();
  final _categoryRepo = CategoryRepository();

  // Controller
  final _nameController = TextEditingController();
  final _budgetAmountController = TextEditingController();

  // State
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedAccountId;
  String? _selectedCategoryId; // Opsional

  // Data Dropdown
  List<Account> _accounts = [];
  List<Category> _expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  /// Memuat data yang diperlukan untuk dropdown (Akun & Kategori)
  Future<void> _loadFormData() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _categoryRepo.getCategoriesByType('expense'),
      ]);

      if (mounted) {
        setState(() {
          _accounts = results[0] as List<Account>;
          _expenseCategories = results[1] as List<Category>;

          if (_accounts.isNotEmpty) {
            _selectedAccountId = _accounts.first.id;
          }
          // Tidak ada default untuk kategori, karena opsional
          
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

  @override
  void dispose() {
    _nameController.dispose();
    _budgetAmountController.dispose();
    super.dispose();
  }

  /// Menyimpan "Kantong" baru ke database
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih akun sumber dana.')),
      );
      return;
    }
    
    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      final budgetAmount = double.parse(_budgetAmountController.text.replaceAll(',', '.'));
      
      final newPocket = Pocket(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId, // Bisa null
        budgetedAmount: budgetAmount,
        createdAt: now,
        updatedAt: now,
      );

      await _pocketRepo.createPocket(newPocket);
      widget.onSaveSuccess();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kantong baru berhasil dibuat!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan kantong: $e')),
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
                'Buat Kantong Budget',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // === Input Nama Kantong ===
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kantong',
                  hintText: 'Misal: Makan Bulanan, Transportasi',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi.' : null,
              ),
              const SizedBox(height: 16),

              // === Input Jumlah Budget ===
              TextFormField(
                controller: _budgetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Budget (Rp)',
                  hintText: '500000',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi.';
                  if (double.tryParse(v) == null) return 'Angka tidak valid.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // === Dropdown Akun (Wajib) ===
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sumber Dana (Akun)'),
                value: _selectedAccountId,
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text('${account.bankName} - ${account.name}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedAccountId = v),
                validator: (v) => v == null ? 'Wajib dipilih.' : null,
              ),
              const SizedBox(height: 16),
              
              // === Dropdown Kategori (Opsional) ===
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori (Opsional)',
                  hintText: 'Pilih Kategori Spesifik'
                ),
                value: _selectedCategoryId,
                items: _expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                // Tidak ada validator, karena opsional
              ),
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
                        'SIMPAN KANTONG',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}