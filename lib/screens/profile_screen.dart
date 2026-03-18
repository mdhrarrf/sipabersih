import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data profil saat halaman pertama kali dibuka
    Future.microtask(() => context.read<AuthViewModel>().fetchFullProfile());
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>(); // Pantau perubahan data
    final profile = authVM.userProfile;

    final String name = profile?['full_name'] ?? "Petugas Lapangan";
    final String petugasId = profile?['petugas_id'] ?? "SIPA-PRO-OFFICER";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Fixed Header (Simetris & Terpusat)
              _buildFixedHeader(
                MediaQuery.of(context).padding.top + 280,
                name,
                petugasId,
              ),

              // 2. Scrollable Area
              Expanded(
                child: authVM.isLoading && profile == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 25, bottom: 40),
                        child: Column(
                          children: [
                            _buildStatsRow(authVM.totalMeasures),
                            const SizedBox(height: 32),
                            _buildMenuSection(context, authVM),
                            const SizedBox(height: 40),
                            _buildFooterInfo(),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // Overlay Loading saat update nama/logout
          if (authVM.isLoading && profile != null)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Widget _buildFixedHeader, _buildStatsRow, _buildFooterInfo tetap memakai style simetris Anda...
  Widget _buildFixedHeader(double height, String name, String id) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PENGATURAN PROFIL",
              style: AppStyles.h1.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 25),
            _buildAvatarMewah(),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: AppStyles.h1.copyWith(color: Colors.white, fontSize: 22),
              ),
            ),
            const SizedBox(height: 8),
            _buildIdBadge(id),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuCard([
            _menuItem(
              Icons.edit_note_rounded,
              "Ubah Nama Profil",
              Colors.blue,
              () => _showEditDialog(context, vm, vm.userProfile?['full_name']),
            ),
            _menuItem(
              Icons.logout_rounded,
              "Keluar Aplikasi",
              AppColors.danger,
              () async {
                await vm.logout();
                if (mounted)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
              },
              isLast: true,
            ),
          ]),
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildAvatarMewah() => Container(
    padding: const EdgeInsets.all(4),
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: const CircleAvatar(
      radius: 45,
      backgroundColor: AppColors.lightBlue,
      child: Icon(Icons.person_rounded, size: 50, color: AppColors.primaryDark),
    ),
  );
  Widget _buildIdBadge(String id) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      id,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  Widget _buildStatsRow(int total) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusM,
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statTile("Total Data", "$total", Icons.bar_chart_rounded),
          _statTile("Status", "Aktif", Icons.verified_rounded),
        ],
      ),
    ),
  );
  Widget _statTile(String label, String value, IconData icon) => Column(
    children: [
      Icon(icon, color: AppColors.accentBlue, size: 20),
      const SizedBox(height: 8),
      Text(value, style: AppStyles.h2.copyWith(fontSize: 14)),
      Text(label, style: AppStyles.caption.copyWith(fontSize: 10)),
    ],
  );
  Widget _buildMenuCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: AppStyles.radiusM,
      boxShadow: AppStyles.softShadow,
    ),
    child: Column(children: children),
  );
  Widget _menuItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool isLast = false,
  }) => ListTile(
    onTap: onTap,
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
    title: Text(
      title,
      style: AppStyles.h2.copyWith(
        fontSize: 14,
        color: isLast ? AppColors.danger : AppColors.textDark,
      ),
    ),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
  );
  Widget _buildFooterInfo() => Column(
    children: [
      Text(
        "SIPABERSIH PRO v3.0.0 (MVVM)",
        style: AppStyles.caption.copyWith(fontSize: 10),
      ),
      const Text(
        "Sistem Informasi Kualitas Air Nasional",
        style: TextStyle(fontSize: 9, color: Colors.grey),
      ),
    ],
  );

  void _showEditDialog(
    BuildContext context,
    AuthViewModel vm,
    String? currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ubah Nama"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              vm.updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
