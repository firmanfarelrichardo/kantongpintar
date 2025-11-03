import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Keuangan"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Nanti di sini fungsi untuk logout
            },
          )
        ],
      ),
      body: Center(
        child: Text("Ini adalah Halaman Home/Dashboard"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nanti ini akan ke halaman 'add_transaction_screen.dart'
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }
}