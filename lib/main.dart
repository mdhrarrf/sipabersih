import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'viewmodels/auth_viewmodel.dart'; // Import viewmodel
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_KEY');

  runApp(
    // Daftarkan semua ViewModel di sini
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: const SipabersihApp(),
    ),
  );
}

class SipabersihApp extends StatelessWidget {
  const SipabersihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPABERSIH PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // (Theme settings Anda tetap sama)
      ),
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginScreen()
          : const MainNavigation(),
    );
  }
}
