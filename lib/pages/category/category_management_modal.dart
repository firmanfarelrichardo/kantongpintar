import 'package:flutter/material.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/services/category_repository.dart';

class CategoryManagementModal extends StatefulWidget {
  const CategoryManagementModal({super.key});

  @override
  State<CategoryManagementModal> createState() => _CategoryManagementModalState();
}

class _CategoryManagementModalState extends State<CategoryManagementModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryRepo = CategoryRepository();

  String _selectedType = 'expense';
  bool _isSaving = false;
  final Color _primaryColor = const Color(0xFF2A2A72);

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final newCategory = Category(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        createdAt: now,
        updatedAt: now,
      );

      await _categoryRepo.createCategory(newCategory);
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
      // Tinggi menyesuaikan konten keyboard
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView( // Agar bisa discroll saat keyboard muncul
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),

              Text("Tambah Kategori", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const SizedBox(height: 20),

              // Toggle Tipe
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildToggleItem("Pengeluaran", "expense"),
                    _buildToggleItem("Pemasukan", "income"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Input Nama
              const Text("Nama Kategori", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: "Misal: Cicilan, Investasi",
                  prefixIcon: Icon(Icons.label_outline, color: _primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("SIMPAN KATEGORI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, String type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? (type == 'expense' ? Colors.red : Colors.green) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}