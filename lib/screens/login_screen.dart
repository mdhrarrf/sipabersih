import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import 'register_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _handleLogin() async {
    final authVM = context.read<AuthViewModel>(); // Akses ViewModel

    // Panggil fungsi login di ViewModel
    final success = await authVM.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else if (authVM.errorMessage != null && mounted) {
      // Tampilkan error dari ViewModel
      _showSnackBar(authVM.errorMessage!, AppColors.danger);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch status loading dari ViewModel
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 40),
              Text(
                "Masuk Petugas",
                style: AppStyles.h1.copyWith(
                  fontSize: 28,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sistem Informasi Pengelolaan Air Bersih",
                style: AppStyles.body,
              ),
              const SizedBox(height: 48),

              _buildInputLabel("Alamat Email Instansi"),
              _buildTextField(
                _emailController,
                "petugas@sipabersih.go.id",
                Icons.alternate_email_rounded,
              ),

              const SizedBox(height: 24),
              _buildInputLabel("Kata Sandi"),
              _buildTextField(
                _passwordController,
                "••••••••",
                Icons.lock_outline_rounded,
                isPassword: true,
              ),

              const SizedBox(height: 32),

              // UI Button merespon status loading dari ViewModel
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authVM.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authVM.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Masuk ke Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
              _buildRegisterFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildLogo, _buildInputLabel, _buildTextField, _buildRegisterFooter tetap sama...
  Widget _buildLogo() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 32),
  );
  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 10),
    child: Text(
      label,
      style: AppStyles.caption.copyWith(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: AppColors.background.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildRegisterFooter() => Center(
    child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      ),
      child: RichText(
        text: TextSpan(
          text: "Belum memiliki akun? ",
          style: AppStyles.body,
          children: [
            TextSpan(
              text: "Daftar Petugas",
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
