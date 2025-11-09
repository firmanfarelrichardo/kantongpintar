// lib/pages/transaction/transaction_list_page.dart

import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/transaction_service.dart';
import '../../services/pocket_service.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart'; // <-- perlu untuk TransactionType

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final TransactionService _transactionService = TransactionService();
  final PocketService _pocketService = PocketService();

  @override
  Widget build(BuildContext context) {
    final transactions = _transactionService.getTransactions();
    
    // Header dengan bubble circle
    Widget header = Stack(
      children: [
        Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: kLightColor.withOpacity(0.5))),
        Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.2), shape: BoxShape.circle))),
        Positioned(top: 30, left: 50, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.4), shape: BoxShape.circle))),
        
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transaksi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor)),
              const SizedBox(height: 20),
              
              // Kolom Cari Transaksi
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Transaksi',
                  suffixIcon: const Icon(Icons.search, color: kPrimaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        children: [
          header,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 80), // Padding bawah untuk Bottom Nav
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                final pocket = _pocketService.getPocketById(t.pocketId);
                
                final bool isIncome = t.type == TransactionType.income;
                final Color amountColor = isIncome ? kPrimaryColor : kDangerColor;
                final String sign = isIncome ? '+' : '-';
                
                final formattedAmount = NumberFormat.currency(
                  locale: 'id_ID', 
                  symbol: 'Rp ', 
                  decimalDigits: 0,
                ).format(t.amount);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? kPrimaryColor.withOpacity(0.1) : kDangerColor.withOpacity(0.1),
                    child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: amountColor, size: 20),
                  ),
                  title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${DateFormat('EEEE, d MMMM yyyy').format(t.date)}\n${pocket?.name ?? "Kantong Tidak Dikenal"}', 
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '$sign $formattedAmount',
                    style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}