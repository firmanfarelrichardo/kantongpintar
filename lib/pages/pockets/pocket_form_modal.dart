import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/services/pocket_repository.dart';

class PocketFormModal extends StatefulWidget {
  final VoidCallback onSaveSuccess;
  final Pocket? pocketToEdit; // Parameter tambahan untuk Edit

  const PocketFormModal({required this.onSaveSuccess, this.pocketToEdit, super.key});

  @override
  State<PocketFormModal> createState() => _PocketFormModalState();
}

class _PocketFormModalState extends State<PocketFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _pocketRepo = PocketRepository();
  final _accountRepo = AccountRepository();
  final _categoryRepo = CategoryRepository();

  final _nameController = TextEditingController();
  final _budgetAmountController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedAccountId;
  String? _selectedCategoryId;

  List<Account> _accounts = [];
  List<Category> _expenseCategories = [];

  final Color _primaryColor = const Color(0xFF2A2A72);

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _categoryRepo.getCategoriesByType('expense'),
      ]);

      if (mounted) {
        setState(() {
          _accounts = results[0] as List<Account>;
          _expenseCategories = results[1] as List<Category>;

          // LOGIKA EDIT: Jika ada data edit, isi form
          if (widget.pocketToEdit != null) {
            final p = widget.pocketToEdit!;
            _nameController.text = p.name;
            _budgetAmountController.text = p.budgetedAmount.toStringAsFixed(0);
            _selectedAccountId = p.accountId;
            _selectedCategoryId = p.categoryId;
          } else {
            // Mode Tambah Baru
            if (_accounts.isNotEmpty) _selectedAccountId = _accounts.first.id;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final budgetAmount = double.parse(_budgetAmountController.text.replaceAll('.', ''));

      // Jika Edit, pakai ID lama. Jika Baru, buat ID baru.
      final id = widget.pocketToEdit?.id ?? now.millisecondsSinceEpoch.toString();
      final createdAt = widget.pocketToEdit?.createdAt ?? now;

      final newPocket = Pocket(
        id: id,
        name: _nameController.text,
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId,
        budgetedAmount: budgetAmount,
        createdAt: createdAt,
        updatedAt: now,
      );

      // Repository sudah support 'replace' (insert OR update), jadi aman pakai createPocket
      // Atau panggil updatePocket untuk lebih eksplisit jika ada method-nya
      if (widget.pocketToEdit != null) {
        await _pocketRepo.updatePocket(newPocket);
      } else {
        await _pocketRepo.createPocket(newPocket);
      }

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
    final isEdit = widget.pocketToEdit != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),

          Text(isEdit ? "Edit Anggaran" : "Buat Anggaran Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Nama Anggaran"),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(hint: "Misal: Uang Makan, Transport", icon: Icons.label_outline),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Batas Anggaran (Rp)"),
                    TextFormField(
                      controller: _budgetAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
                      decoration: _inputDecoration(hint: "0", icon: Icons.attach_money),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Sumber Dana"),
                    _buildDropdown(
                        value: _selectedAccountId,
                        items: _accounts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                        onChanged: (v) => setState(() => _selectedAccountId = v as String?),
                        icon: Icons.account_balance_wallet_outlined,
                        hint: "Pilih Akun"
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Kategori Khusus (Opsional)"),
                    _buildDropdown(
                        value: _selectedCategoryId,
                        items: [
                          const DropdownMenuItem(value: null, child: Text("Semua Kategori")),
                          ..._expenseCategories.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                        ],
                        onChanged: (v) => setState(() => _selectedCategoryId = v as String?),
                        icon: Icons.category_outlined,
                        hint: "Pilih Kategori"
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
                            : Text(isEdit ? "UPDATE ANGGARAN" : "SIMPAN ANGGARAN", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ... (Widget helper _buildLabel, _inputDecoration, _buildDropdown tetap sama)
  // Copy paste helper widgets dari kode sebelumnya di sini jika perlu, atau biarkan jika tidak berubah.
  // Agar lengkap saya sertakan:
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

  Widget _buildDropdown({required String? value, required List<DropdownMenuItem<Object>> items, required Function(Object?) onChanged, required IconData icon, required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            icon: Icon(icon, color: _primaryColor),
            border: InputBorder.none,
          ),
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}