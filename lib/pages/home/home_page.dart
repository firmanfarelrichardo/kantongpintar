// lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/pocket_service.dart';
import 'pocket_creation_modal.dart'; // Modal untuk buat kantong

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PocketService _pocketService = PocketService();
  
  // Fungsi untuk menampilkan modal Buat Kantong (image_ccba6f.png)
  void _showCreatePocketModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (_) {
        // Kita gunakan modal yang akan kita buat sebentar lagi
        return const PocketCreationModal(); 
      },
    ).then((_) {
      // Refresh halaman setelah modal ditutup (jika ada penambahan kantong)
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalBalance = _pocketService.getInitialTotalBalance();
    final pockets = _pocketService.getPockets();
    
    // Header dengan bubble circle
    Widget header = Stack(
      children: [
        // Background dengan bubble circle (Minimalisir hardcoding)
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kLightColor.withOpacity(0.5),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
        Positioned(
          top: -50,
          left: -50,
          child: Container(width: 150, height: 150, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.2), shape: BoxShape.circle)),
        ),
        Positioned(
          top: 30,
          left: 50,
          child: Container(width: 80, height: 80, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.4), shape: BoxShape.circle)),
        ),
        
        // Konten utama Header
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beranda',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor),
              ),
              const SizedBox(height: 10),
              
              // Kartu Ringkasan (image_ccb6eb.png)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow('Pendapatan hari ini', 'Rp.', 'Pendapatan bulan ini', 'Rp.'),
                      const Divider(height: 20),
                      _buildSummaryRow('Pengeluaran hari ini', 'Rp.', 'Pengeluaran hari ini', 'Rp.'),
                      const Divider(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTotalItem(Icons.account_balance_wallet, 'Total Saldo', 'Rp. ${totalBalance.toStringAsFixed(2)}'),
                          _buildTotalItem(Icons.wallet_travel, 'Kantong', '${pockets.length} Kantong'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0), // Menyembunyikan AppBar standar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 20),
            
            // Bagian Kantong
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kantong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
                  ),
                  const SizedBox(height: 10),
                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // List Kantong yang sudah ada
                      ...pockets.map((pocket) => _buildPocketCard(pocket.name, 'Rp. ${pocket.initialBalance.toStringAsFixed(0)}')).toList(),
                      
                      // Tombol Buat Kantong
                      GestureDetector(
                        onTap: _showCreatePocketModal,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: kPrimaryColor),
                              SizedBox(height: 5),
                              Text('Buat Kantong', style: TextStyle(fontSize: 14, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding untuk Bottom Nav
          ],
        ),
      ),
    );
  }

  // Helper Row Ringkasan
  Widget _buildSummaryRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildSummaryItem(label1, value1)),
        Expanded(child: _buildSummaryItem(label2, value2)),
      ],
    );
  }

  // Helper Item Ringkasan
  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextColor)),
      ],
    );
  }
  
  // Helper Item Total Saldo/Kantong
  Widget _buildTotalItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: kPrimaryColor, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextColor)),
          ],
        )
      ],
    );
  }

  // Helper Card Kantong
  Widget _buildPocketCard(String name, String balance) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColor)),
            const SizedBox(height: 5),
            Text(balance, style: const TextStyle(fontSize: 12, color: kPrimaryColor)),
          ],
        ),
      ),
    );
  }
}