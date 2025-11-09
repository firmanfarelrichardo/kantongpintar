// lib/widgets/transaction_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import '../services/pocket_service.dart';

/// Widget Form untuk input data transaksi baru (CREATE) atau edit (UPDATE).
/// Dibuat sebagai StatefulWidget karena mengelola input data form.
class TransactionForm extends StatefulWidget {
  final Transaction? transactionToEdit; // Jika ada, mode UPDATE. Jika null, mode CREATE.
  final VoidCallback onSave; // Callback untuk me-refresh halaman utama setelah simpan

  const TransactionForm({
    Key? key,
    this.transactionToEdit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _service = TransactionService();
  final PocketService _pocketService = PocketService();

  // Controller untuk input form
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // State variabel
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedPocketId;

  @override
  void initState() {
    super.initState();
    // Jika ada data yang akan diedit (mode UPDATE), isi form dengan data lama
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _descriptionController.text = t.description;
      _amountController.text = t.amount.toStringAsFixed(2);
      _selectedType = t.type;
      _selectedDate = t.date;
      _selectedPocketId = t.pocketId;
    } else {
      final pockets = _pocketService.getPockets();
      if (pockets.isNotEmpty) {
        _selectedPocketId = pockets.first.id;
      }
    }
  }

  // =======================================================
  // FUNGSI: Simpan Data (CREATE atau UPDATE)
  // =======================================================
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Simpan nilai form

      if (_selectedPocketId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kantong terlebih dahulu.')),
        );
        return;
      }

      final double amount = double.parse(_amountController.text);
      
      // CREATE: Jika tidak ada transactionToEdit
      if (widget.transactionToEdit == null) {
        final newTransaction = Transaction(
          // Comments: Menetapkan ID unik menggunakan timestamp
          id: DateTime.now().millisecondsSinceEpoch.toString(), 
          description: _descriptionController.text,
          amount: amount,
          type: _selectedType,
          date: _selectedDate,
          pocketId: _selectedPocketId!, // penting: wajib dikirim
        );
        _service.addTransaction(newTransaction);
      } 
      // UPDATE: Jika ada transactionToEdit
      else {
        final updatedTransaction = widget.transactionToEdit!.copyWith(
          description: _descriptionController.text,
          amount: amount,
          type: _selectedType,
          date: _selectedDate,
          pocketId: _selectedPocketId!, // ikut diperbarui jika berubah
        );
        _service.updateTransaction(updatedTransaction);
      }

      // 1. Panggil callback untuk me-refresh list di HomePage
      widget.onSave(); 
      // 2. Tutup Modal Bottom Sheet
      Navigator.of(context).pop(); 
    }
  }

  // =======================================================
  // FUNGSI: Memilih Tanggal
  // =======================================================
  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  
  // Pastikan controller di-dispose setelah selesai untuk Clean Code
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Judul Form
    final title = widget.transactionToEdit == null ? 'Tambah Transaksi Baru' : 'Edit Transaksi';

    // Padding agar form tidak tertutup keyboard saat di-scroll
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 20 + bottomPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const Divider(),
              
              // 1. Input Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi Transaksi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              // 2. Input Jumlah (Amount)
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                // Hanya mengizinkan angka dan titik
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Masukkan jumlah yang valid (angka positif).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // 3. Pilihan Tipe Transaksi (Income/Expense)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tipe Transaksi:', style: TextStyle(fontSize: 16)),
                  DropdownButton<TransactionType>(
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: TransactionType.income,
                        child: Text('Pemasukan', style: TextStyle(color: kAccentColor)),
                      ),
                      DropdownMenuItem(
                        value: TransactionType.expense,
                        child: Text('Pengeluaran', style: TextStyle(color: kDangerColor)),
                      ),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3b. Pilih Kantong
              DropdownButtonFormField<String>(
                value: _selectedPocketId,
                decoration: const InputDecoration(labelText: 'Kantong'),
                items: _pocketService
                    .getPockets()
                    .map((p) => DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPocketId = value),
                validator: (value) =>
                    value == null ? 'Pilih kantong terlebih dahulu.' : null,
              ),

              // 4. Input Tanggal
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        // Format tampilan tanggal
                        'Tanggal: ${DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate)}',
                      ),
                    ),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: const Text(
                        'Pilih Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Tombol Simpan (CREATE/UPDATE)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitForm,
                child: Text(
                  widget.transactionToEdit == null ? 'SIMPAN TRANSAKSI' : 'UPDATE TRANSAKSI',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}