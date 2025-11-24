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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      final newCategory = Category(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        createdAt: now,
        updatedAt: now,
        iconEmoji: null,
        parentId: null,
      );

      await _categoryRepo.createCategory(newCategory);
      _nameController.clear();

      if (mounted) {
        Navigator.pop(context); // Tutup modal setelah simpan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori baru disimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Padding agar modal menyesuaikan dengan keyboard
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // PENTING: Agar tinggi modal menyesuaikan isi
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tambah Kategori Baru',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipe',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
              DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
            ],
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isSaving ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }
}