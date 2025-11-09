// lib/pages/main_screen.dart
// (100% Siap Pakai - Menggantikan file lama)
// Clean Code: Menghapus dependensi service lama.

import 'package:flutter/material.dart';
import 'package:testflutter/pages/account/account_page.dart';
import 'package:testflutter/pages/graph/graph_page.dart';
import 'package:testflutter/pages/home/home_page.dart';

/// Ini adalah widget utama yang memegang navigasi (BottomNavigationBar).
/// Versi baru ini TIDAK LAGI membuat instance PocketService atau TransactionService,
/// karena setiap halaman sekarang akan mengelola datanya sendiri
/// melalui Repository.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Halaman-halaman sekarang dipanggil langsung tanpa parameter service.
  // Ini adalah arsitektur yang jauh lebih bersih (Loose Coupling).
  final List<Widget> _pages = [
    const HomePage(),
    const GraphPage(),
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
      // Kita memindahkan FloatingActionButton ke dalam setiap halaman (misal HomePage)
      // agar setiap halaman bisa punya aksinya sendiri.
      // body: _pages[_selectedIndex], 
      
      // Gunakan IndexedStack agar state setiap halaman (scroll position, dll)
      // tetap terjaga saat berpindah tab.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Graph',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}