// lib/pages/transaction/transaction_form_modal.dart
// (100% Siap Pakai - Menggantikan file lama)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';
import 'package:testflutter/models/transaction.dart' as model; // Ubah nama import

/// Modal untuk membuat transaksi baru.
/// Direfactor total untuk menggunakan Repository dan Database SQLite.
class TransactionFormModal extends StatefulWidget {
  /// Callback yang akan dipanggil setelah transaksi berhasil disimpan,
  /// untuk memberi sinyal ke HomePage agar me-refresh datanya.
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
  
  // === 1. Akses ke "Departemen" Data ===
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();

  // === 2. Controller & State Form ===
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'expense'; // Tipe transaksi: 'expense' atau 'income'
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId; // ID Akun yang dipilih

  // === 3. State untuk UI ===
  bool _isLoadingAccounts = true;
  bool _isSaving = false;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    // Saat modal dibuka, segera muat daftar akun
    _loadAccounts();
  }

  /// Memuat daftar akun dari database untuk ditampilkan di Dropdown
  Future<void> _loadAccounts() async {
    try {
      final accounts = await _accountRepo.getAllAccounts();
      setState(() {
        _accounts = accounts;
        // Jika ada akun, pilih akun pertama sebagai default
        if (_accounts.isNotEmpty) {
          _selectedAccountId = _accounts.first.id;
        }
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAccounts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar akun: $e')),
      );
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
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, hentikan
    }
    
    // 2. Validasi tambahan
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus memilih satu akun.')),
      );
      return;
    }

    setState(() {
      _isSaving = true; // Tampilkan loading di tombol
    });

    try {
      // 3. Buat object Transaction baru
      final now = DateTime.now();
      final newTransaction = model.Transaction(
        // Buat ID unik berdasarkan timestamp
        id: now.millisecondsSinceEpoch.toString(),
        // Ambil data dari form
        accountId: _selectedAccountId!,
        amount: double.parse(_amountController.text.replaceAll('.', '')),
        type: _selectedType,
        description: _descriptionController.text,
        transactionDate: _selectedDate,
        // Set timestamp untuk pelacakan
        createdAt: now,
        updatedAt: now,
        // Properti opsional lainnya bisa null
        categoryId: null, 
        pocketId: null,
        transferGroupId: null,
      );

      // 4. Simpan ke Database SQLite
      await _transactionRepo.createTransaction(newTransaction);

      // 5. Beri tahu HomePage untuk refresh
      widget.onSaveSuccess();

      // 6. Tutup modal
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dicatat!')),
        );
      }
    } catch (e) {
      // Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      // Hentikan loading di tombol
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  // Helper untuk memilih tanggal
  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding agar keyboard tidak menutupi form
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
              
              // === Dropdown Akun (BARU) ===
              _buildAccountDropdown(),
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
                  backgroundColor: Colors.deepPurple, // Sesuaikan tema
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                // Nonaktifkan tombol saat sedang menyimpan
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
    if (_isLoadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accounts.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Akun',
          errorText: 'Buat akun di halaman Home terlebih dahulu!',
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

  // Helper widget untuk toggle tipe
  Widget _buildTypeToggle(String label, String type, Color color) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
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