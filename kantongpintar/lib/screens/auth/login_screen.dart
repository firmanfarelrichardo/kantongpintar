import 'package:flutter/material.dart';
import 'package:kantongpintar/screens/home/home_screen.dart'; // Arahkan ke Home Screen

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login - Kantong Pintar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selamat Datang",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              
              // Nanti ini akan jadi TextField
              Text("Tempat untuk Email"),
              SizedBox(height: 10),
              Text("Tempat untuk Password"),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  // Untuk sekarang, kita langsung lompat ke Home Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text("Login (Demo)"),
              ),
              TextButton(
                onPressed: () {
                  // Nanti ini akan ke halaman registrasi
                },
                child: Text("Belum punya akun? Registrasi"),
              )
            ],
          ),
        ),
      ),
    );
  }
}