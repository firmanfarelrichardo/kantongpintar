import 'package:flutter/material.dart';
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

  bool _isLoading = true;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  // DEFINISI WARNA LOKAL
  final Color _backgroundColor = const Color(0xFFF8F9FE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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

  void _showAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const CategoryManagementModal(),
    ).then((_) => _loadData());
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryRepo.deleteCategory(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal hapus. Kategori sedang dipakai transaksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Kategori'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryModal,
        backgroundColor: const Color(0xFF009FFD),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _buildSectionHeader('Kategori Pemasukan', Colors.green),
          ..._incomeCategories.map((c) => _buildCategoryItem(c, Colors.green)),

          const SizedBox(height: 20),

          _buildSectionHeader('Kategori Pengeluaran', Colors.redAccent),
          ..._expenseCategories.map((c) => _buildCategoryItem(c, Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            category.iconEmoji ?? category.name[0].toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF424242)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[400]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hapus Kategori?'),
                content: Text('Yakin ingin menghapus "${category.name}"?'),
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