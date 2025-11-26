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

  // Warna Tema
  final Color _primaryColor = const Color(0xFF2A2A72);
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CategoryManagementModal(),
    ).then((_) => _loadData());
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await _categoryRepo.deleteCategory(category.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori "${category.name}" dihapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal hapus. Kategori sedang dipakai transaksi.')),
      );
    }
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Apakah Anda yakin ingin menghapus "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCategory(category);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Kelola Kategori'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
          bottom: TabBar(
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: _primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Pengeluaran"),
              Tab(text: "Pemasukan"),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCategoryModal,
          backgroundColor: const Color(0xFF009FFD),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),

        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildCategoryList(_expenseCategories, Colors.redAccent),
            _buildCategoryList(_incomeCategories, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, Color themeColor) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("Belum ada kategori", style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildModernCard(category, themeColor);
      },
    );
  }

  Widget _buildModernCard(Category category, Color color) {
    // PANGGIL FUNGSI PINTAR UNTUK CARI ICON
    final IconData smartIcon = _getSmartIcon(category.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Padding sedikit diperbesar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Radius lebih bulat
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // WADAH ICON YANG LEBIH BAGUS
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Background transparan sesuai tema
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            // GUNAKAN ICON MATERIAL, BUKAN TEXT LAGI
            child: Icon(smartIcon, color: color, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),

          IconButton(
            onPressed: () => _confirmDelete(category),
            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[300]),
            tooltip: "Hapus",
          )
        ],
      ),
    );
  }

  // === FUNGSI BARU: PENDETEKSI ICON PINTAR ===
  IconData _getSmartIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    // Mapping manual nama kategori ke Icon Material
    if (name.contains('makan') || name.contains('food') || name.contains('minum')) {
      return Icons.restaurant_rounded;
    }
    if (name.contains('belanja') || name.contains('shop') || name.contains('mart')) {
      return Icons.shopping_cart_rounded;
    }
    if (name.contains('transport') || name.contains('jalan') || name.contains('bensin') || name.contains('ojek')) {
      return Icons.directions_car_rounded;
    }
    if (name.contains('tagihan') || name.contains('listrik') || name.contains('air') || name.contains('internet')) {
      return Icons.receipt_long_rounded;
    }
    if (name.contains('kesehatan') || name.contains('obat') || name.contains('dokter')) {
      return Icons.local_hospital_rounded;
    }
    if (name.contains('pendidikan') || name.contains('buku') || name.contains('kuliah')) {
      return Icons.school_rounded;
    }
    if (name.contains('hiburan') || name.contains('nonton') || name.contains('game')) {
      return Icons.movie_creation_rounded;
    }
    if (name.contains('gaji') || name.contains('bonus')) {
      return Icons.monetization_on_rounded;
    }
    if (name.contains('investasi') || name.contains('saham')) {
      return Icons.trending_up_rounded;
    }
    if (name.contains('kos') || name.contains('rumah')) {
      return Icons.home_rounded;
    }

    // Default Icon jika tidak ada yang cocok
    return Icons.category_rounded;
  }
}