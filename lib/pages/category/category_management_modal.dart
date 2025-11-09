// lib/pages/category/category_management_modal.dart
// (100% Siap Pakai - FILE BARU)

import 'package:flutter/material.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/services/category_repository.dart';

/// Modal untuk membuat, melihat, dan menghapus Kategori.
class CategoryManagementModal extends StatefulWidget {
  const CategoryManagementModal({super.key});

  @override
  State<CategoryManagementModal> createState() => _CategoryManagementModalState();
}

class _CategoryManagementModalState extends State<CategoryManagementModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryRepo = CategoryRepository();

  String _selectedType = 'expense'; // Default 'expense'
  bool _isSaving = false;

  // State untuk daftar kategori
  late Future<List<Category>> _expenseCategoriesFuture;
  late Future<List<Category>> _incomeCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Memuat (atau me-refresh) daftar kategori dari database
  void _loadCategories() {
    _expenseCategoriesFuture = _categoryRepo.getCategoriesByType('expense');
    _incomeCategoriesFuture = _categoryRepo.getCategoriesByType('income');
    setState(() {}); // Memperbarui UI untuk FutureBuilder
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Menyimpan kategori baru ke database
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
        iconEmoji: null, // TODO: Tambahkan emoji picker nanti
        parentId: null,
      );

      await _categoryRepo.createCategory(newCategory);

      // Reset form dan refresh list
      _nameController.clear();
      _loadCategories();

      if (mounted) {
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
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  /// Menghapus kategori
  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryRepo.deleteCategory(id);
      _loadCategories(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori dihapus.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
        bottom: 20 + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kelola Kategori',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          
          // === Form Tambah Kategori ===
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Kategori Baru'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                    DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isSaving ? null : _submitForm,
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('TAMBAH'),
          ),
          const Divider(height: 30),

          // === Daftar Kategori ===
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildCategoryList('Pengeluaran', _expenseCategoriesFuture),
                _buildCategoryList('Pemasukan', _incomeCategoriesFuture),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk membangun list kategori
  Widget _buildCategoryList(String title, Future<List<Category>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        FutureBuilder<List<Category>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Belum ada kategori.', style: TextStyle(color: Colors.grey));
            }
            
            final categories = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  dense: true,
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _deleteCategory(category.id),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}