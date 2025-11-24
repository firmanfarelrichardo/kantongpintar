import 'package:flutter/material.dart';
import 'package:testflutter/main.dart'; // Mengambil warna tema
import 'package:testflutter/models/category.dart';
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/pages/category/category_management_modal.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryRepository _categoryRepo = CategoryRepository();

  // State Data
  bool _isLoading = true;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        _categoryRepo.getCategoriesByType('expense'),
        _categoryRepo.getCategoriesByType('income'),
      ]);

      if (mounted) {
        setState(() {
          _expenseCategories = results[0];
          _incomeCategories = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Menampilkan modal tambah kategori
  void _showAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const CategoryManagementModal(),
    ).then((_) => _loadData()); // Refresh setelah tutup modal
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryRepo.deleteCategory(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori dihapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal hapus. Mungkin sedang dipakai transaksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryModal,
        backgroundColor: kPrimaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 80), // Space untuk FAB
        children: [
          _buildSectionHeader('Income categories'),
          ..._incomeCategories.map((c) => _buildCategoryItem(c, Colors.blue)),

          const SizedBox(height: 20),

          _buildSectionHeader('Expense categories'),
          ..._expenseCategories.map((c) => _buildCategoryItem(c, Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            category.iconEmoji ?? category.name[0].toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500, color: kTextColor),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.grey),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Hapus ${category.name}?'),
                content: const Text('Yakin ingin menghapus kategori ini?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteCategory(category.id);
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}