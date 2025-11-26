import 'package:flutter/material.dart';
import 'package:testflutter/services/database_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PROFIL SECTION
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 30, color: Color(0xFF2A2A72)),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pengguna", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Free Plan", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text("Umum", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),

          // MENU ITEMS
          _buildSettingTile(
              icon: Icons.category_rounded,
              title: "Kelola Kategori",
              onTap: () {
                // Opsional: Bisa navigasi ke halaman Kategori jika mau dipindah ke sini
              }
          ),
          _buildSettingTile(
              icon: Icons.notifications_active_rounded,
              title: "Notifikasi",
              onTap: () {}
          ),
          _buildSettingTile(
              icon: Icons.lock_outline_rounded,
              title: "Keamanan",
              onTap: () {}
          ),

          const SizedBox(height: 20),
          const Text("Lainnya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),

          _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: "Tentang Aplikasi",
              onTap: () {}
          ),

          // TOMBOL RESET DATA (HATI-HATI)
          _buildSettingTile(
              icon: Icons.delete_forever_rounded,
              title: "Reset Semua Data",
              color: Colors.red,
              onTap: () => _confirmReset(context)
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, VoidCallback? onTap, Color color = const Color(0xFF2A2A72)}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Semua Data?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan. Semua riwayat transaksi akan hilang."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              // TODO: Panggil fungsi clear database (harus dibuat di service)
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur reset belum diaktifkan demi keamanan.")));
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}