import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/services/pocket_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';
import 'package:testflutter/models/transaction.dart' as model;

class TransactionFormModal extends StatefulWidget {
  final VoidCallback onSaveSuccess;

  const TransactionFormModal({required this.onSaveSuccess, super.key});

  @override
  State<TransactionFormModal> createState() => _TransactionFormModalState();
}

class _TransactionFormModalState extends State<TransactionFormModal> {
  final _formKey = GlobalKey<FormState>();

  // Repositories
  final _transactionRepo = TransactionRepository();
  final _accountRepo = AccountRepository();
  final _categoryRepo = CategoryRepository();
  final _pocketRepo = PocketRepository();

  // Controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State Variables
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String? _selectedPocketId;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCategoryLocked = false; // State untuk mengunci kategori

  List<Account> _accounts = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  List<Pocket> _pockets = [];

  // Warna Tema
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
        _categoryRepo.getCategoriesByType('income'),
        _pocketRepo.getAllPockets(),
      ]);

      if (mounted) {
        setState(() {
          _accounts = results[0] as List<Account>;
          _expenseCategories = results[1] as List<Category>;
          _incomeCategories = results[2] as List<Category>;
          _pockets = results[3] as List<Pocket>;

          if (_accounts.isNotEmpty) _selectedAccountId = _accounts.first.id;
          // PERBAIKAN: Tidak set default kategori, biarkan user memilih
          // Kategori bisa null untuk transaksi tanpa anggaran
          _selectedCategoryId = null;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // LOGIKA PENTING: Saat Pocket dipilih
  void _onPocketChanged(String? pocketId) {
    setState(() {
      _selectedPocketId = pocketId;

      if (pocketId != null) {
        // Cari data pocket yang dipilih
        final pocket = _pockets.firstWhere((p) => p.id == pocketId);

        // Jika pocket punya kategori khusus
        if (pocket.categoryId != null) {
          _selectedCategoryId = pocket.categoryId;
          _isCategoryLocked = true; // KUNCI DROPDOWN KATEGORI
        } else {
          // Jika pocket umum (tidak ada kategori), jangan dikunci
          _isCategoryLocked = false;
        }
      } else {
        // Jika pocket di-unselect (pilih null), buka kunci
        _isCategoryLocked = false;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final finalDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          now.hour, now.minute, now.second
      );

      final newTransaction = model.Transaction(
        id: now.millisecondsSinceEpoch.toString(),
        accountId: _selectedAccountId!,
        amount: double.parse(_amountController.text.replaceAll('.', '')),
        type: _selectedType,
        description: _descriptionController.text,
        transactionDate: finalDate,
        categoryId: _selectedCategoryId,
        pocketId: _selectedPocketId, // Simpan ID Pocket
        transferGroupId: null,
        createdAt: now,
        updatedAt: now,
      );

      await _transactionRepo.createTransaction(newTransaction);
      widget.onSaveSuccess();
      if (mounted) Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90, // Sedikit lebih tinggi
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

          Text("Tambah Transaksi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
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
                    _buildModernToggle(),
                    const SizedBox(height: 25),

                    const Text("Total Nominal", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _selectedType == 'expense' ? Colors.redAccent : Colors.green
                      ),
                      decoration: InputDecoration(
                        prefixText: "Rp ",
                        prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                        border: InputBorder.none,
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.grey[300]),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),

                    _buildLabel("Sumber Dana / Akun"),
                    _buildDropdown(
                      value: _selectedAccountId,
                      hint: "Pilih Akun",
                      items: _accounts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                      onChanged: (v) => setState(() => _selectedAccountId = v as String?),
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                    const SizedBox(height: 16),

                    // PILIHAN ANGGARAN (POCKET) - HANYA JIKA PENGELUARAN
                    if (_selectedType == 'expense') ...[
                      _buildLabel("Ambil dari Anggaran (Opsional)"),
                      _buildDropdown(
                        value: _selectedPocketId,
                        hint: "Pilih Anggaran (Misal: Uang Makan)",
                        items: [
                          const DropdownMenuItem(value: null, child: Text("Tidak Pakai Anggaran")),
                          ..._pockets.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                        ],
                        onChanged: (v) => _onPocketChanged(v as String?), // Panggil fungsi logika kunci
                        icon: Icons.savings_rounded,
                        isRequired: false, // PERBAIKAN: Anggaran tidak wajib dipilih
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildLabel("Kategori"),
                    // Dropdown Kategori (Bisa Disabled)
                    Opacity(
                      opacity: _isCategoryLocked ? 0.6 : 1.0, // Efek visual jika disabled
                      child: _buildDropdown(
                        value: _selectedCategoryId,
                        hint: "Pilih Kategori",
                        // Jika dikunci, disable onChanged
                        onChanged: _isCategoryLocked ? null : (v) => setState(() => _selectedCategoryId = v as String?),
                        items: [
                          // Tambah opsi "Tanpa Kategori" untuk pengeluaran tanpa anggaran
                          if (_selectedType == 'expense' && !_isCategoryLocked)
                            const DropdownMenuItem(value: null, child: Text("Tanpa Kategori")),
                          ...(_selectedType == 'expense' ? _expenseCategories : _incomeCategories)
                              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                        ],
                        icon: _isCategoryLocked ? Icons.lock_rounded : Icons.category_rounded, // Ganti icon gembok jika dikunci
                        isRequired: _isCategoryLocked, // Hanya wajib jika dikunci (ada anggaran)
                      ),
                    ),
                    // Pesan kecil jika terkunci
                    if (_isCategoryLocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          "*Kategori dikunci sesuai Anggaran yang dipilih",
                          style: TextStyle(fontSize: 11, color: Colors.orange[800], fontStyle: FontStyle.italic),
                        ),
                      ),

                    const SizedBox(height: 16),

                    _buildLabel("Tanggal"),
                    GestureDetector(
                      onTap: _presentDatePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: _primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Catatan (Opsional)"),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: "Contoh: Makan siang...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                        prefixIcon: Icon(Icons.notes_rounded, color: Colors.grey[400]),
                      ),
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
                            : const Text("SIMPAN TRANSAKSI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<Object>>? items,
    required Function(Object?)? onChanged, // Bisa null jika disabled
    required IconData icon,
    bool isRequired = true, // Parameter baru untuk validasi opsional
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onChanged == null ? Colors.grey[200] : Colors.grey[50], // Warna agak gelap jika disabled
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            icon: Icon(icon, color: onChanged == null ? Colors.grey : _primaryColor, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items,
          onChanged: onChanged,
          validator: (v) => isRequired && v == null ? "Wajib dipilih" : null,
        ),
      ),
    );
  }

  Widget _buildModernToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleItem("Pengeluaran", 'expense'),
          _buildToggleItem("Pemasukan", 'income'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, String type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedPocketId = null; // Reset pocket jika ganti tipe
            _isCategoryLocked = false; // Buka kunci kategori
            _selectedCategoryId = null; // Reset kategori, biarkan user pilih
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (type == 'expense' ? Colors.redAccent : Colors.green)
                  : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}