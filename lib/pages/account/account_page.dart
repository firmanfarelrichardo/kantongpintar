// lib/pages/account/account_page.dart
// (REDESIGN: Daftar Kartu Aset)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/main.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart'; // Untuk hitung saldo real
import 'package:testflutter/pages/account/account_form_modal.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoading = true;
  List<Account> _accounts = [];
  Map<String, double> _accountBalances = {};
  double _totalAsset = 0.0;

  final _accountRepo = AccountRepository();
  final _trxRepo = TransactionRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final accounts = await _accountRepo.getAllAccounts();
      final transactions = await _trxRepo.getAllTransactions();

      // Hitung saldo aktual per akun (Saldo Awal + Income - Expense)
      Map<String, double> balances = {};
      double total = 0.0;

      for (var acc in accounts) {
        double bal = acc.initialBalance;
        // Cari transaksi milik akun ini
        final accTrx = transactions.where((t) => t.accountId == acc.id);
        for (var t in accTrx) {
          if (t.type == 'income') bal += t.amount;
          if (t.type == 'expense') bal -= t.amount;
        }
        balances[acc.id] = bal;
        total += bal;
      }

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _accountBalances = balances;
          _totalAsset = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AccountFormModal(onSaveSuccess: _loadData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      // Floating Button Tambah Akun
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountModal,
        backgroundColor: kPrimaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // === HEADER TOTAL ASSET ===
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: kBackgroundColor,
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  'All Accounts',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_totalAsset),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // === LIST AKUN ===
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final acc = _accounts[index];
                final balance = _accountBalances[acc.id] ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kSecondaryColor, // Background biru muda
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: kPrimaryColor, size: 28),
                    ),
                    title: Text(
                      acc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Balance: ${currencyFormat.format(balance)}',
                        style: TextStyle(
                          color: balance >= 0 ? kSuccessColor : kDangerColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.more_horiz, color: Colors.grey),
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