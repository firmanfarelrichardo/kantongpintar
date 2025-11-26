import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:testflutter/pages/main_screen.dart';
import 'package:testflutter/providers/home_provider.dart';

// === KONFIGURASI WARNA TEMA ===
const Color kPrimaryColor = Color(0xFF2A2A72);
const Color kSecondaryColor = Color(0xFFE1F5FE);
const Color kBackgroundColor = Color(0xFFF8F9FE);
const Color kTextColor = Color(0xFF424242);
const Color kDangerColor = Color(0xFFEF5350);
const Color kSuccessColor = Color(0xFF66BB6A);

// === FUNGSI UTAMA (INI YANG HILANG DI TEMPATMU) ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp(
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
          ),
        ),
        home: const MainScreen(), // Ini memanggil file main_screen.dart
      ),
    );
  }
}