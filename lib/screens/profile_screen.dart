import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profil Petugas"),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            "Relawan Siaga",
            style: AppStyles.h1.copyWith(color: Colors.white, fontSize: 20),
          ),
          Text(
            "ID Petugas: SIPA-2024-001",
            style: AppStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildProfileItem(Icons.edit_outlined, "Ubah Profil"),
          _buildProfileItem(Icons.security_outlined, "Keamanan Akun"),
          _buildProfileItem(Icons.language_outlined, "Bahasa"),
          const Divider(height: 40),
          _buildProfileItem(Icons.info_outline, "Tentang Aplikasi"),
          _buildProfileItem(Icons.logout, "Keluar", isDanger: true),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title, {
    bool isDanger = false,
  }) {
    final color = isDanger ? AppColors.danger : AppColors.primaryDark;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: AppStyles.h2.copyWith(fontSize: 14, color: color),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }
}
