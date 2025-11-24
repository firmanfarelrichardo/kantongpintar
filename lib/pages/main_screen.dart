// lib/pages/main_screen.dart
// (Redesign: 5 Tabs Navigasi)

import 'package:flutter/material.dart';
import 'package:testflutter/pages/account/account_page.dart';
import 'package:testflutter/pages/category/category_page.dart'; // Halaman Baru
import 'package:testflutter/pages/graph/graph_page.dart';
import 'package:testflutter/pages/home/home_page.dart';
import 'package:testflutter/pages/pockets/pocket_management_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Urutan Tab sesuai screenshot:
  // 1. Records (Home)
  // 2. Analysis (Grafik)
  // 3. Budgets (Pockets)
  // 4. Accounts (Akun)
  // 5. Categories (Kategori)
  final List<Widget> _pages = [
    const HomePage(),             // Records
    const GraphPage(),            // Analysis
    const PocketManagementPage(), // Budgets
    const AccountPage(),          // Accounts
    const CategoryPage(),         // Categories
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Wajib fixed untuk 5 item
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), // Atau bar_chart
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Accounts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.label),
              label: 'Categories',
            ),
          ],
        ),
      ),
    );
  }
}