// lib/pages/main_screen.dart
// (100% Siap Pakai - Menambahkan kembali GraphPage ke 4 tab)

import 'package:flutter/material.dart';
import 'package:testflutter/pages/account/account_page.dart';
import 'package:testflutter/pages/home/home_page.dart';
import 'package:testflutter/pages/transaction/transaction_list_page.dart';
// BARU: Import halaman grafik
import 'package:testflutter/pages/graph/graph_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // === UPDATE DAFTAR HALAMAN (4 HALAMAN) ===
  final List<Widget> _pages = [
    const HomePage(),
    const TransactionListPage(),
    const GraphPage(), // Halaman Grafik ditambahkan di sini
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // === UPDATE LABEL NAVIGASI (4 TOMBOL) ===
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transaksi',
          ),
          // BARU: Tombol navigasi untuk Grafik
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Grafik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // PENTING: Untuk 4 item, kita set properti ini
        // agar semua label terlihat dan warnanya konsisten.
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple, // Sesuaikan dengan tema
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}