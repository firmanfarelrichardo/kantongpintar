// lib/pages/account/account_page.dart

import 'package:flutter/material.dart';
import '../../main.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Header dengan bubble circle dan Profile
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
                // Foto Profil
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/profile_placeholder.jpg'), // Ganti dengan aset gambar kamu
                  child: const Text('R.A', style: TextStyle(fontSize: 24, color: kPrimaryColor)),
                ),
                const SizedBox(height: 10),
                const Text('Ramadhani Ahmad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor)),
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
          children: [
            header,
            const SizedBox(height: 20),
            
            // Menu Opsi
            _buildAccountOption('Edit Profil', Icons.person),
            _buildAccountOption('Bantuan Masalah', Icons.help_outline),
            _buildAccountOption('Keamanan', Icons.lock_outline),
            // Opsi Keluar (Merah)
            _buildAccountOption('Keluar', Icons.logout, isDestructive: true),
            
            const SizedBox(height: 80), // Padding untuk Bottom Nav
          ],
        ),
      ),
    );
  }
  
  // Helper Widget untuk setiap opsi di halaman Akun
  Widget _buildAccountOption(String title, IconData icon, {bool isDestructive = false}) {
    final color = isDestructive ? kDangerColor : kTextColor;
    
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
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          trailing: isDestructive ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            // Logika navigasi/aksi akan ditambahkan di sini
          },
        ),
      ),
    );
  }
}