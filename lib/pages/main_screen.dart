// lib/pages/main_screen.dart
// (100% Siap Pakai - Menggantikan GraphPage dengan TransactionListPage)

import 'package:flutter/material.dart';
import 'package:testflutter/pages/account/account_page.dart';
// Hapus import GraphPage
// import 'package:testflutter/pages/graph/graph_page.dart'; 
import 'package:testflutter/pages/home/home_page.dart';
// BARU: Import halaman daftar transaksi
import 'package:testflutter/pages/transaction/transaction_list_page.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // === UPDATE DAFTAR HALAMAN ===
  final List<Widget> _pages = [
    const HomePage(),
    const TransactionListPage(), // Menggantikan GraphPage
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
      // === UPDATE LABEL NAVIGASI ===
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), // Ganti ikon
            label: 'Transaksi', // Ganti label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}