// lib/pages/account/account_page.dart
// (100% Siap Pakai - Menambahkan tombol Kelola Kategori)

import 'package:flutter/material.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/pages/account/account_form_modal.dart';
import 'package:testflutter/pages/category/category_management_modal.dart'; // BARU
import '../../main.dart'; // Untuk konstanta warna

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // === 1. State ===
  bool _isLoading = true;
  List<Account> _accounts = [];
  final AccountRepository _accountRepo = AccountRepository();

  // === 2. Lifecycle ===
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // === 3. Data Loading ===
  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final accounts = await _accountRepo.getAllAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar akun: $e')),
        );
      }
    }
  }

  // === 4. Modal Helpers ===
  
  /// Menampilkan modal untuk menambah akun baru
  void _showAddAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return AccountFormModal(
          onSaveSuccess: _loadData, // Callback untuk me-refresh halaman ini
        );
      },
    );
  }
  
  /// BARU: Menampilkan modal untuk mengelola kategori
  void _showCategoryManagementModal() {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Gunakan 90% tinggi layar
      heightFactor: 0.9,
      builder: (ctx) {
        return const CategoryManagementModal();
      },
    );
  }

  // === 5. Build Method ===
  @override
  Widget build(BuildContext context) {
    Widget header = Stack(
      children: [
        Container(height: 220, width: double.infinity, decoration: BoxDecoration(color: kLightColor.withOpacity(0.5))),
        Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.2), shape: BoxShape.circle))),
        Positioned(top: 30, left: 50, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.4), shape: BoxShape.circle))),
        
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: kPrimaryColor),
                ),
                const SizedBox(height: 10),
                const Text('Pengguna Kantong Pintar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor)),
              ],
            ),
          ),
        ),
      ],
    );
    
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 20),
            
            // === Bagian Akun Dinamis ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Manajemen Akun', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
            ),
            _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                : _buildAccountSection(),
            
            const Divider(height: 30, indent: 16, endIndent: 16),
            
            // === Bagian Opsi Statis (DIUPDATE) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Pengaturan', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
            ),
            
            // BARU: Tombol Kelola Kategori
            _buildStaticOption(
              'Kelola Kategori', 
              Icons.category,
              onTap: _showCategoryManagementModal,
            ),
            
            _buildStaticOption('Bantuan Masalah', Icons.help_outline),
            _buildStaticOption('Keamanan', Icons.lock_outline),
            _buildStaticOption('Keluar', Icons.logout, isDestructive: true),
            
            const SizedBox(height: 80), // Padding untuk Bottom Nav
          ],
        ),
      ),
    );
  }

  // === 6. Helper Widgets ===

  Widget _buildAccountSection() {
    // ... (Kode sama persis seperti langkah sebelumnya)
    return Column(
      children: [
        if (_accounts.isNotEmpty)
          ..._accounts.map((account) => _buildAccountTile(account)),
        if (_accounts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Center(child: Text('Kamu belum memiliki akun.')),
          ),
        _buildStaticOption(
          'Tambah Akun Baru...', 
          Icons.add_circle, 
          onTap: _showAddAccountModal,
          isAddNew: true,
        ),
      ],
    );
  }

  Widget _buildAccountTile(Account account) {
    // ... (Kode sama persis seperti langkah sebelumnya)
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: const Icon(Icons.account_balance_wallet, color: kPrimaryColor),
          title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(account.bankName),
          trailing: Text(
            'Rp ${account.initialBalance.toStringAsFixed(0)}',
            style: const TextStyle(color: kTextColor, fontSize: 12),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildStaticOption(String title, IconData icon, {bool isDestructive = false, VoidCallback? onTap, bool isAddNew = false}) {
    // ... (Kode sama persis seperti langkah sebelumnya)
    final color = isDestructive ? kDangerColor : (isAddNew ? Colors.deepPurple : kTextColor);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title, 
            style: TextStyle(color: color, fontWeight: isAddNew ? FontWeight.bold : FontWeight.w500),
          ),
          trailing: (isDestructive || isAddNew || (onTap != null)) ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }
}