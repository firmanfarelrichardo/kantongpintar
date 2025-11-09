// lib/pages/main_screen.dart

import 'package:flutter/material.dart';
import '../main.dart'; 
import 'home/home_page.dart';        // Halaman Beranda
import 'transaction/transaction_list_page.dart'; // Halaman Transaksi
import 'graph/graph_page.dart';      // Halaman Grafik
import 'account/account_page.dart';  // Halaman Akun
import 'transaction/transaction_form_modal.dart'; // Modal Form

/// Halaman utama yang mengelola BottomNavigationBar.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index halaman yang aktif

  // Daftar semua halaman
  final List<Widget> _pages = [
    const HomePage(), 
    const TransactionListPage(), 
    const GraphPage(), 
    const AccountPage(), 
  ];

  void _onItemTapped(int index) {
    if (index == 2) { // Index 2: Grafik (atau sesuaikan jika kamu ubah urutan)
      // Navigasi yang sama saat tap item
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Navigasi yang sama saat tap item
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  // Fungsi untuk menampilkan modal transaksi
  void _showAddTransactionModal(BuildContext context) {
    // Navigasi ke form transaksi (kita akan buat modal ini di file lain)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (_) {
        return const TransactionFormModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman yang sesuai dengan index BottomNav
      body: _pages[_selectedIndex],
      
      // Floating Action Button (FAB) untuk Tambah Transaksi
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        shape: const CircleBorder(), // Membuat FAB bulat sempurna
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(), // Memberikan cekungan untuk FAB
        notchMargin: 6.0,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Bagian Kiri (Beranda & Transaksi)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(0, 'Beranda', Icons.home_outlined, Icons.home),
                  _buildNavItem(1, 'Transaksi', Icons.list_alt, Icons.list_alt_sharp),
                ],
              ),

              // Spacer untuk FAB
              const SizedBox(width: 40), 

              // Bagian Kanan (Grafik & Akun)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(2, 'Grafik', Icons.bar_chart_outlined, Icons.bar_chart),
                  _buildNavItem(3, 'Akun', Icons.person_outline, Icons.person),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper Widget untuk setiap item navigasi
  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? kPrimaryColor : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        // Padding agar icon dan teks tidak terlalu mepet
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 24,
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}