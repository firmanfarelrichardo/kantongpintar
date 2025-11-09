// lib/pages/home/pocket_creation_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/pocket.dart';
import '../../services/pocket_service.dart';

class PocketCreationModal extends StatefulWidget {
  const PocketCreationModal({super.key});

  @override
  State<PocketCreationModal> createState() => _PocketCreationModalState();
}

class _PocketCreationModalState extends State<PocketCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  
  String? _selectedType;
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _pocketTypes = ['Tabungan', 'Harian', 'Investasi', 'Lainnya'];
  final PocketService _pocketService = PocketService();

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
      
      final newPocket = Pocket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType!,
        initialBalance: double.parse(_initialBalanceController.text.replaceAll('.', '').replaceAll(',', '.')),
        dateCreated: _selectedDate,
      );
      
      _pocketService.addPocket(newPocket);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kantong berhasil dibuat!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
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
              const Text(
                'Buat Kantong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const Divider(height: 30),
              
              // 1. Nama Kantong
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kantong'),
                validator: (value) => value == null || value.isEmpty ? 'Nama kantong wajib diisi.' : null,
              ),
              const SizedBox(height: 10),

              // 2. Jenis Kantong (Dropdown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Jenis Kantong'),
                value: _selectedType,
                hint: const Text('Pilih Jenis Kantong'),
                items: _pocketTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (newValue) => setState(() => _selectedType = newValue),
                validator: (value) => value == null ? 'Pilih jenis kantong.' : null,
              ),
              const SizedBox(height: 10),

              // 3. Waktu (Tanggal)
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

              // 4. Saldo Awal
              TextFormField(
                controller: _initialBalanceController,
                decoration: const InputDecoration(labelText: 'Saldo Awal (Rp)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || double.tryParse(value) == null ? 'Masukkan saldo awal yang valid.' : null,
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
                child: const Text('SIMPAN', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}