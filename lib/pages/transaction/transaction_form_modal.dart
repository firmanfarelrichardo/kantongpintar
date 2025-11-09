// lib/pages/transaction/transaction_form_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/transaction.dart';
import '../../services/transaction_service.dart';
import '../../services/pocket_service.dart';

// Modal yang digunakan saat FAB diklik
class TransactionFormModal extends StatefulWidget {
  // Transaksi untuk diedit (saat ini kita fokus ke CREATE, tapi struktur harus ada)
  final Transaction? transactionToEdit; 
  
  const TransactionFormModal({this.transactionToEdit, super.key});

  @override
  State<TransactionFormModal> createState() => _TransactionFormModalState();
}

class _TransactionFormModalState extends State<TransactionFormModal> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  final PocketService _pocketService = PocketService();
  
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense; // Default Pengeluaran
  DateTime _selectedDate = DateTime.now();
  String? _selectedPocketId;
  
  @override
  void initState() {
    super.initState();
    // Mengambil pocket pertama sebagai default
    if (_pocketService.getPockets().isNotEmpty) {
      _selectedPocketId = _pocketService.getPockets().first.id;
    }
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text.replaceAll('.', '').replaceAll(',', '.')),
        type: _selectedType,
        date: _selectedDate,
        pocketId: _selectedPocketId!,
      );
      
      _transactionService.addTransaction(newTransaction);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dicatat!')),
      );
      // Panggil refresh data (walaupun di sini kita tidak punya onSave)
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final pockets = _pocketService.getPockets();
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 30,
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
              // Toggle Pengeluaran/Pendapatan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeToggle('Pengeluaran', TransactionType.expense, kDangerColor),
                  _buildTypeToggle('Pendapatan', TransactionType.income, kPrimaryColor),
                ],
              ),
              const SizedBox(height: 20),
              
              // 1. Pilih Kantong (Dropdown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kantong', hintText: 'Pilih Kantong'),
                value: _selectedPocketId,
                items: pockets.map((pocket) => DropdownMenuItem(value: pocket.id, child: Text(pocket.name))).toList(),
                onChanged: (newValue) => setState(() => _selectedPocketId = newValue),
                validator: (value) => value == null ? 'Pilih kantong.' : null,
              ),
              const SizedBox(height: 10),

              // 2. Waktu (Tanggal)
              GestureDetector(
                onTap: _presentDatePicker,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Waktu',
                    suffixIcon: Icon(Icons.calendar_today, color: kPrimaryColor),
                  ),
                  child: Text(
                    DateFormat('d MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Jumlah
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || double.tryParse(value) == null ? 'Masukkan jumlah yang valid.' : null,
              ),
              const SizedBox(height: 10),

              // 4. Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Deskripsi wajib diisi.' : null,
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitForm,
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              
              // Padding bawah untuk Bottom Nav (di desain ada, tapi di modal tidak perlu)
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Toggle Pengeluaran/Pendapatan
  Widget _buildTypeToggle(String label, TransactionType type, Color color) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.9) : Colors.white,
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.only(
              topLeft: type == TransactionType.expense ? const Radius.circular(8) : Radius.zero,
              bottomLeft: type == TransactionType.expense ? const Radius.circular(8) : Radius.zero,
              topRight: type == TransactionType.income ? const Radius.circular(8) : Radius.zero,
              bottomRight: type == TransactionType.income ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}