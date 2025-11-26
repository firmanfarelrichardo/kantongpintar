import 'package:flutter/material.dart';
import 'package:testflutter/pages/account/account_page.dart';
import 'package:testflutter/pages/category/category_page.dart';
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

  final List<Widget> _pages = [
    const HomePage(),
    const GraphPage(),
    const PocketManagementPage(),
    const AccountPage(),
    const CategoryPage(),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2A2A72),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Analisis'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Anggaran'),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'Akun'),
            BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: 'Kategori'),
          ],
        ),
      ),
    );
  }
}