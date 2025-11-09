// lib/main.dart (UPDATE TEMA)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart'; 
import 'pages/main_screen.dart'; // Menggunakan MainScreen baru untuk BottomNav

/// Warna tema: Hijau Mint/Tosca (Warna utama desain).
const Color kPrimaryColor = Color(0xFF4CAF50); // Hijau Mint/Tosca (diubah dari Biru Tua)
/// Warna aksen yang lebih terang untuk background dan bubble.
const Color kLightColor = Color(0xFFB9F6CA); 
// Tambahan: warna aksen untuk pemasukan (dipakai di beberapa widget).
const Color kAccentColor = Color(0xFF66BB6A);
/// Warna bahaya: Merah (untuk pengeluaran/keluar).
const Color kDangerColor = Color(0xFFD32F2F); 
/// Warna teks utama.
const Color kTextColor = Color(0xFF333333);

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, 
      builder: (context) => const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true, // rekomendasi untuk DevicePreview
      locale: DevicePreview.locale(context), 
      builder: DevicePreview.appBuilder, 
      
      debugShowCheckedModeBanner: false, 
      title: 'Kantong Pintar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: kTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: kTextColor),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(), 
    );
  }
}