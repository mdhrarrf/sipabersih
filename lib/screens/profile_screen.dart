import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double fixedHeaderHeight = 260.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService().getProfile(), // Ambil data dari Supabase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Data dari database
          final profileData = snapshot.data;
          final String name = profileData?['full_name'] ?? "Petugas";
          final String petugasId =
              profileData?['petugas_id'] ?? "ID Tidak Ditemukan";

          return Stack(
            children: [
              _buildHeroBackground(statusBarHeight + fixedHeaderHeight),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildTopBar(),

                      // Data Nama & ID Sekarang Dinamis
                      _buildProfileHeader(name, petugasId),

                      const SizedBox(height: 40),
                      _buildMenuSection(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Header Background Tetap Sama (Style Luxury Blue)
  Widget _buildHeroBackground(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        "PROFIL PETUGAS",
        style: AppStyles.h1.copyWith(
          color: Colors.white,
          fontSize: 18,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String id) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.lightBlue,
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name, // NAMA DINAMIS
          style: AppStyles.h1.copyWith(color: Colors.white, fontSize: 20),
        ),
        Text(
          "ID: $id", // ID PETUGAS DINAMIS
          style: AppStyles.caption.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.radiusL,
          boxShadow: AppStyles.softShadow,
        ),
        child: Column(
          children: [
            _buildProfileItem(
              Icons.edit_note_rounded,
              "Informasi Akun",
              Colors.blue,
              () {},
            ),
            _buildProfileItem(
              Icons.security_rounded,
              "Keamanan & PIN",
              Colors.orange,
              () {},
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 30, thickness: 0.5),
            ),
            _buildProfileItem(
              Icons.logout_rounded,
              "Keluar Aplikasi",
              AppColors.danger,
              () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: AppStyles.h2.copyWith(
          fontSize: 14,
          color: isLast ? AppColors.danger : AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
