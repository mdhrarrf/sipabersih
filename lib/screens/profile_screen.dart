import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Logika Tinggi yang Dikunci (Sama dengan HomeScreen tapi lebih tinggi sedikit untuk Profil)
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double fixedHeaderHeight =
        260.0; // Ditinggikan agar pas membungkus foto & nama

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 2. BACKGROUND BIRU (Lengkungan yang Stay & Simetris)
          _buildHeroBackground(statusBarHeight + fixedHeaderHeight),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTopBar(), // Tulisan PROFIL PETUGAS
                  // 3. Header Profil (Tetap berada di dalam area Biru)
                  _buildProfileHeader(),

                  const SizedBox(height: 40),

                  // 4. Menu Section (Berada di area putih/background)
                  _buildMenuSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Lengkungan Simetris (Identik dengan HomeScreen)
  Widget _buildHeroBackground(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32), // Lengkungan yang konsisten
        ),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          "Relawan Siaga 01",
          style: AppStyles.h1.copyWith(color: Colors.white, fontSize: 20),
        ),
        Text(
          "ID: SIPA-BNPB-2024",
          style: AppStyles.caption.copyWith(
            color: Colors.white70,
            letterSpacing: 1,
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
            ),
            _buildProfileItem(
              Icons.security_rounded,
              "Keamanan & PIN",
              Colors.orange,
            ),
            _buildProfileItem(
              Icons.history_rounded,
              "Aktivitas Saya",
              Colors.teal,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 30, thickness: 0.5),
            ),
            _buildProfileItem(
              Icons.info_outline_rounded,
              "Tentang Sipabersih",
              Colors.indigo,
            ),
            _buildProfileItem(
              Icons.logout_rounded,
              "Keluar Aplikasi",
              AppColors.danger,
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
    Color color, {
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
      onTap: () {},
    );
  }
}
