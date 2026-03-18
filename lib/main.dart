import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Wajib ada
import 'package:sipabersih/screens/main_navigation.dart';
import 'utils/constants.dart';

void main() {
  // Memastikan plugin database dan sistem flutter siap
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SipabersihApp());
}

class SipabersihApp extends StatelessWidget {
  const SipabersihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPABERSIH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // KUNCI: Set Font Poppins secara global untuk seluruh aplikasi
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorSchemeSeed: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
