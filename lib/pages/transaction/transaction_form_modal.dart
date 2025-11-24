// lib/pages/transaction/transaction_form_modal.dart
// (100% Siap Pakai - VERSI BARU dengan Kategori)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/category.dart'; // BARU
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/category_repository.dart'; // BARU
import 'package:testflutter/services/transaction_repository.dart';
import 'package:testflutter/models/transaction.dart' as model;

class TransactionFormModal extends StatefulWidget {
  final VoidCallback onSaveSuccess;

  const TransactionFormModal({
    required this.onSaveSuccess,
    super.key,
  });

  @override
  State<TransactionFormModal> createState() => _TransactionFormModalState();
}

class _TransactionFormModalState extends State<TransactionFormModal> {
  final _formKey = GlobalKey<FormState>();
  
  // === 1. Repositories ===
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();
  final CategoryRepository _categoryRepo = CategoryRepository(); // BARU

  // === 2. Controller & State Form ===
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedCategoryId; // BARU

  // === 3. State untuk UI ===
  bool _isLoading = true; // Satu state loading gabungan
  bool _isSaving = false;
  
  // Daftar data untuk dropdown
  List<Account> _accounts = [];
  List<Category> _expenseCategories = []; // BARU
  List<Category> _incomeCategories = []; // BARU

  @override
  void initState() {
    super.initState();
    // Muat semua data yang diperlukan untuk form
    _loadFormData();
  }

  /// Memuat semua data (Akun & Kategori) secara paralel
  Future<void> _loadFormData() async {
    setState(() { _isLoading = true; });
    try {
      // Ambil semua data sekaligus
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _categoryRepo.getCategoriesByType('expense'),
        _categoryRepo.getCategoriesByType('income'),
      ]);

      if (mounted) {
        setState(() {
          _accounts = results[0] as List<Account>;
          _expenseCategories = results[1] as List<Category>;
          _incomeCategories = results[2] as List<Category>;

          // Set default Akun
          if (_accounts.isNotEmpty) {
            _selectedAccountId = _accounts.first.id;
          }
          // Set default Kategori (berdasarkan tipe default 'expense')
          if (_expenseCategories.isNotEmpty) {
            _selectedCategoryId = _expenseCategories.first.id;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data form: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fungsi utama untuk menyimpan data ke database
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus memilih satu akun.')),
      );
      return;
    }
    
    if (_selectedCategoryId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus memilih kategori.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      final newTransaction = model.Transaction(
        id: now.millisecondsSinceEpoch.toString(),
        accountId: _selectedAccountId!,
        amount: double.parse(_amountController.text.replaceAll('.', '')),
        type: _selectedType,
        description: _descriptionController.text,
        transactionDate: _selectedDate,
        categoryId: _selectedCategoryId, // <-- BARU DISIMPAN
        createdAt: now,
        updatedAt: now,
        pocketId: null,
        transferGroupId: null,
      );

      await _transactionRepo.createTransaction(newTransaction);
      widget.onSaveSuccess();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dicatat!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }
  
  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() { _selectedDate = pickedDate; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    // Jika masih loading, tampilkan spinner
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
            children: <Widget>[
              // === Toggle Tipe Transaksi ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeToggle('Pengeluaran', 'expense', Colors.red),
                  _buildTypeToggle('Pemasukan', 'income', Colors.green),
                ],
              ),
              const SizedBox(height: 20),
              
              // === Dropdown Akun ===
              _buildAccountDropdown(),
              const SizedBox(height: 16),

              // === BARU: Dropdown Kategori ===
              _buildCategoryDropdown(),
              const SizedBox(height: 10),

              // === Pilih Tanggal ===
              GestureDetector(
                onTap: _presentDatePicker,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Waktu',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('d MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 10),

              // === Input Jumlah (Amount) ===
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Masukkan jumlah yang valid.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // === Input Deskripsi ===
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi wajib diisi.';
                  }
                  return null;
                },
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
                        'SIMPAN',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk dropdown akun
  Widget _buildAccountDropdown() {
    if (_accounts.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Akun',
          errorText: 'Buat akun di halaman Akun terlebih dahulu!',
        ),
      );
    }
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Pilih Akun'),
      value: _selectedAccountId,
      items: _accounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Text('${account.bankName} - ${account.name}'),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => _selectedAccountId = newValue),
      validator: (value) => value == null ? 'Pilih akun.' : null,
    );
  }

  // === BARU: Helper widget untuk dropdown kategori ===
  Widget _buildCategoryDropdown() {
    // Tentukan list mana yang akan dipakai
    final currentList = _selectedType == 'expense' ? _expenseCategories : _incomeCategories;

    if (currentList.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Kategori',
          errorText: 'Buat kategori $_selectedType di halaman Akun!',
        ),
      );
    }
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Pilih Kategori'),
      value: _selectedCategoryId,
      items: currentList.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text('${category.iconEmoji ?? ''} ${category.name}'),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => _selectedCategoryId = newValue),
      validator: (value) => value == null ? 'Pilih kategori.' : null,
    );
  }

  // Helper widget untuk toggle tipe
  Widget _buildTypeToggle(String label, String type, Color color) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            // PENTING: Reset pilihan kategori saat tipe berubah
            if (_selectedType == 'expense' && _expenseCategories.isNotEmpty) {
              _selectedCategoryId = _expenseCategories.first.id;
            } else if (_selectedType == 'income' && _incomeCategories.isNotEmpty) {
              _selectedCategoryId = _incomeCategories.first.id;
            } else {
              _selectedCategoryId = null; // Kosongkan jika tidak ada kategori
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.9) : Colors.grey[200],
            border: Border.all(color: isSelected ? color : Colors.grey[400]!),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}