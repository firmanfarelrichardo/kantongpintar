// Import package yang kita perlukan
import 'package.flutter/material.dart';
import 'package:kantongpintar/screens/auth/login_screen.dart'; // Arahkan ke Login Screen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini akan dibuat otomatis nanti

void main() async {
  // Ini penting untuk memastikan Firebase siap sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kantong Pintar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // Kita mulai aplikasi dari LoginScreen
      home: LoginScreen(),
    );
  }
}