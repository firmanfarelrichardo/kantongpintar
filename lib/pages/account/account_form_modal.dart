// lib/pages/account/account_form_modal.dart
// (100% Siap Pakai - FILE BARU)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/services/account_repository.dart';

/// Modal untuk membuat Akun (Rekening) baru.
class AccountFormModal extends StatefulWidget {
  /// Callback untuk me-refresh HomePage setelah berhasil menyimpan.
  final VoidCallback onSaveSuccess;

  const AccountFormModal({
    required this.onSaveSuccess,
    super.key,
  });

  @override
  State<AccountFormModal> createState() => _AccountFormModalState();
}

class _AccountFormModalState extends State<AccountFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _accountRepo = AccountRepository();

  // Controller untuk form input
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  /// Fungsi untuk memvalidasi dan menyimpan akun baru ke database
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form tidak valid
    }

    setState(() {
      _isSaving = true; // Tampilkan loading
    });

    try {
      final now = DateTime.now();
      // Ganti koma dengan titik untuk parsing double
      final balanceText = _initialBalanceController.text.replaceAll(',', '.');
      
      final newAccount = Account(
        id: now.millisecondsSinceEpoch.toString(), // ID unik
        name: _nameController.text,
        bankName: _bankNameController.text,
        initialBalance: double.tryParse(balanceText) ?? 0.0,
        createdAt: now,
        updatedAt: now,
        iconPath: null, // TODO: Bisa ditambahkan fitur pilih ikon nanti
      );

      // Simpan ke database SQLite
      await _accountRepo.createAccount(newAccount);

      // Panggil callback untuk refresh HomePage
      widget.onSaveSuccess();

      // Tutup modal
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun baru berhasil dibuat!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan akun: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Text(
                'Tambah Akun Baru',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // === Input Nama Akun ===
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Akun',
                  hintText: 'Misal: Rekening Gaji, Dompet OVO',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama akun wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // === Input Nama Bank/Lembaga ===
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Bank / Lembaga',
                  hintText: 'Misal: BCA, OVO, Tunai',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama bank wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // === Input Saldo Awal ===
              TextFormField(
                controller: _initialBalanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo Awal (Rp)',
                  hintText: '0',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Mengizinkan angka dan satu koma/titik
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+([,\.]\d{0,2})?')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Saldo awal wajib diisi (masukkan 0 jika kosong).';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Masukkan angka yang valid.';
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
                        'SIMPAN AKUN',
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