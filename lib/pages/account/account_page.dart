import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';
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

  // DEFINISI WARNA LOKAL (Agar tidak error)
  final Color _primaryColor = const Color(0xFF2A2A72);
  final Color _backgroundColor = const Color(0xFFF8F9FE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _accountRepo.getAllAccounts();
      final transactions = await _trxRepo.getAllTransactions();

      Map<String, double> balances = {};
      double total = 0.0;

      for (var acc in accounts) {
        double bal = acc.initialBalance;
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
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountModal,
        backgroundColor: const Color(0xFF009FFD),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // HEADER TOTAL ASSET
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                const Text(
                  'Total Aset Bersih',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_totalAsset),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // LIST AKUN
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
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_balance_wallet_rounded, color: _primaryColor, size: 24),
                    ),
                    title: Text(
                      acc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      acc.bankName,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Saldo',
                          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(balance),
                          style: TextStyle(
                            color: balance >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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