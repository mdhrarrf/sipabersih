import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _petugasIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  void _handleRegister() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _petugasIdController.text.isEmpty) {
      _showSnackBar(
        "Harap lengkapi semua formulir pendaftaran",
        AppColors.danger,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        petugasId: _petugasIdController.text.trim(),
      );

      if (mounted) {
        _showSnackBar(
          "Akun Petugas Berhasil Dibuat. Silakan Masuk.",
          AppColors.success,
        );
        Navigator.pop(context); // Kembali ke halaman Login
      }
    } catch (e) {
      String errorMsg = "Terjadi kesalahan sistem";

      if (e.toString().contains("429")) {
        errorMsg =
            "Terlalu banyak permintaan. Silakan tunggu beberapa saat lagi.";
      } else if (e.toString().contains("already registered")) {
        errorMsg = "Email ini sudah terdaftar sebagai petugas.";
      }

      _showSnackBar(errorMsg, AppColors.danger);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 1. Logo Minimalis
              _buildLogo(),

              const SizedBox(height: 32),

              // 2. Judul & Sub-judul
              Text(
                "Pendaftaran Akses",
                style: AppStyles.h1.copyWith(
                  fontSize: 26,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lengkapi data identitas petugas untuk mendapatkan akses ke sistem monitoring.",
                style: AppStyles.body.copyWith(
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // 3. Form Group (Field satu per satu dengan label di atas)
              _buildInputLabel("Nama Lengkap Petugas"),
              _buildTextField(
                controller: _fullNameController,
                hint: "Masukkan nama sesuai identitas",
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 20),

              _buildInputLabel("ID Petugas (SIPA-XXX)"),
              _buildTextField(
                controller: _petugasIdController,
                hint: "Contoh: SIPA-001",
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 20),

              _buildInputLabel("Alamat Email Instansi"),
              _buildTextField(
                controller: _emailController,
                hint: "email@instansi.go.id",
                icon: Icons.alternate_email_rounded,
              ),

              const SizedBox(height: 20),

              _buildInputLabel("Buat Kata Sandi"),
              _buildTextField(
                controller: _passwordController,
                hint: "Minimal 8 karakter",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              // 4. Tombol Aksi (Solid)
              _buildRegisterButton(),

              const SizedBox(height: 32),

              // 5. Footer Navigasi
              _buildLoginFooter(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.person_add_alt_1_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        label,
        style: AppStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      style: AppStyles.body.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryDark.withOpacity(0.5),
          size: 18,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: AppColors.background.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Konfirmasi Pendaftaran",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildLoginFooter() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: "Sudah memiliki akun? ",
            style: AppStyles.body.copyWith(
              color: AppColors.textLight,
              fontSize: 13,
            ),
            children: [
              TextSpan(
                text: "Masuk Disini",
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
}
