import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/services/account_repository.dart';

class AccountFormModal extends StatefulWidget {
  final VoidCallback onSaveSuccess;

  const AccountFormModal({required this.onSaveSuccess, super.key});

  @override
  State<AccountFormModal> createState() => _AccountFormModalState();
}

class _AccountFormModalState extends State<AccountFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _accountRepo = AccountRepository();

  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  bool _isSaving = false;
  final Color _primaryColor = const Color(0xFF2A2A72);

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final balanceText = _initialBalanceController.text.replaceAll('.', '');

      final newAccount = Account(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        bankName: _bankNameController.text,
        initialBalance: double.tryParse(balanceText) ?? 0.0,
        createdAt: now,
        updatedAt: now,
      );

      await _accountRepo.createAccount(newAccount);
      widget.onSaveSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),

          Text("Tambah Akun Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Nama Akun (Dompet)"),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(hint: "Misal: Dompet Pribadi, Tabungan", icon: Icons.account_balance_wallet_outlined),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Jenis Bank / Lembaga"),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: _inputDecoration(hint: "Misal: BCA, OVO, Tunai", icon: Icons.account_balance_outlined),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Saldo Awal (Rp)"),
                    TextFormField(
                      controller: _initialBalanceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
                      decoration: _inputDecoration(hint: "0", icon: Icons.attach_money),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                            : const Text("SIMPAN AKUN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: _primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}