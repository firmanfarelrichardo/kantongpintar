// lib/widgets/transaction_card.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../main.dart'; // Akses ke konstanta warna
import 'package:intl/intl.dart'; // Untuk format angka dan tanggal (pastikan sudah di-import di pubspec.yaml)

/// Widget yang menampilkan detail satu baris transaksi (Reusable).
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final Function(String) onDelete;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menentukan warna berdasarkan tipe transaksi
    final Color amountColor = 
        transaction.type == TransactionType.income ? kAccentColor : kDangerColor;
    
    // Comments: Format angka menjadi mata uang dengan titik sebagai pemisah ribuan
    final formattedAmount = NumberFormat.currency(
      locale: 'id_ID', // Lokasi Indonesia
      symbol: 'Rp ', 
      decimalDigits: 2,
    ).format(transaction.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2,
      child: ListTile(
        // =======================================================
        // Bagian Kiri: Ikon Tipe Transaksi
        // =======================================================
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(
            transaction.type == TransactionType.income 
                ? Icons.arrow_downward 
                : Icons.arrow_upward,
            color: amountColor,
            size: 20,
          ),
        ),
        
        // =======================================================
        // Bagian Tengah: Deskripsi dan Tanggal
        // =======================================================
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(transaction.date), // Format Tanggal
        ),
        
        // =======================================================
        // Bagian Kanan: Jumlah dan Aksi (Update & Delete)
        // =======================================================
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Penting agar Row tidak mengambil semua lebar
          children: [
            // Jumlah Transaksi
            Text(
              formattedAmount,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Tombol Edit (UPDATE)
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
              onPressed: onEdit, // Dipanggil saat tombol edit ditekan
            ),

            // Tombol Hapus (DELETE)
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: kDangerColor),
              // Konfirmasi sebelum menghapus (Praktik profesional)
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper Method: Dialog Konfirmasi Hapus
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah kamu yakin ingin menghapus transaksi ini?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Tutup dialog
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              onDelete(transaction.id); // Panggil fungsi DELETE
              Navigator.of(ctx).pop(); // Tutup dialog
            },
            child: const Text('Hapus', style: TextStyle(color: kDangerColor)),
          ),
        ],
      ),
    );
  }
}