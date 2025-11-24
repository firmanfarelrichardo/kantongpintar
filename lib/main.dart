import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/services.dart';
// 1. Tambahkan import ini untuk inisialisasi tanggal
import 'package:intl/date_symbol_data_local.dart';
import 'package:testflutter/pages/main_screen.dart';

// === KONFIGURASI WARNA TEMA (Putih & Biru Muda) ===
const Color kPrimaryColor = Color(0xFF29B6F6); // Biru Muda Cerah
const Color kSecondaryColor = Color(0xFFE1F5FE); // Biru Sangat Muda
const Color kBackgroundColor = Colors.white; // Putih bersih
const Color kTextColor = Color(0xFF424242); // Abu-abu gelap
const Color kDangerColor = Color(0xFFEF5350); // Merah lembut
const Color kSuccessColor = Color(0xFF66BB6A); // Hijau lembut

const Color kLightColor = kSecondaryColor;

// 2. Ubah void main() menjadi async
void main() async {
  // 3. Pastikan binding terinisialisasi karena main() bersifat async
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Inisialisasi data formatting untuk locale Indonesia ('id_ID')
  // Ini yang MEMPERBAIKI error "Locale data has not been initialized"
  await initializeDateFormatting('id_ID', null);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

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
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Kantong Pintar',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',

        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
          primary: kPrimaryColor,
          surface: kBackgroundColor,
        ),

        scaffoldBackgroundColor: kBackgroundColor,

        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          foregroundColor: kTextColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kTextColor),
          titleTextStyle: TextStyle(
            color: kTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const MainScreen(),
    );
  }
}