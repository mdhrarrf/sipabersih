import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import '../widgets/app_footer.dart'; // Import Footer
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
    // Sinkronisasi data profil dari Cloud saat halaman dibuka
    Future.microtask(() => context.read<AuthViewModel>().fetchFullProfile());
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final profile = authVM.userProfile;

    final String name = profile?['full_name'] ?? "Petugas Lapangan";
    final String petugasId = profile?['petugas_id'] ?? "SIPA-PRO-OFFICER";

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 280.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. HEADER TETAP (FIXED) - Identitas Petugas
              _buildFixedHeader(
                statusBarHeight + headerHeight,
                name,
                petugasId,
              ),

              // 2. AREA SCROLLABLE - Menu & Pengaturan
              Expanded(
                child: authVM.isLoading && profile == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            _buildStatsRow(authVM.totalMeasures),
                            const SizedBox(height: 32),
                            _buildMenuSection(context, authVM, name),

                            // 3. FOOTER IDENTITAS REUSABLE
                            const AppFooter(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // Overlay Loading saat proses Update/Logout
          if (authVM.isLoading && profile != null)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildFixedHeader(double height, String name, String id) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildIdBadge(id),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    AuthViewModel vm,
    String currentName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuCard([
            _menuItem(
              Icons.edit_note_rounded,
              "Ubah Nama Profil",
              Colors.blue,
              () => _showEditDialog(context, vm, currentName),
            ),
            _menuItem(
              Icons.badge_rounded,
              "Kartu Identitas Digital",
              Colors.teal,
              () {},
            ),
            _menuItem(
              Icons.lock_reset_rounded,
              "Keamanan & PIN",
              Colors.orange,
              () {},
            ),
          ]),
          const SizedBox(height: 20),
          _buildMenuCard([
            _menuItem(
              Icons.logout_rounded,
              "Keluar Aplikasi",
              AppColors.danger,
              () async {
                await vm.logout();
                if (mounted) {
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
          ]),
        ],
      ),
    );
  }

  // --- UI HELPERS (Luxury Styling) ---

  Widget _buildAvatarMewah() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const CircleAvatar(
        radius: 45,
        backgroundColor: AppColors.lightBlue,
        child: Icon(
          Icons.person_rounded,
          size: 50,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildIdBadge(String id) {
    return Container(
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
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatsRow(int total) {
    return Padding(
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
            Container(height: 30, width: 1, color: Colors.grey.shade100),
            _statTile("Status", "Aktif", Icons.verified_rounded),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 20),
        const SizedBox(height: 8),
        Text(value, style: AppStyles.h2.copyWith(fontSize: 14)),
        Text(label, style: AppStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusM,
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
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
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Colors.grey,
          ),
        ),
        if (!isLast) const Divider(height: 0, thickness: 0.3, indent: 60),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    AuthViewModel vm,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusM),
        title: const Text("Ubah Nama"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Nama Lengkap Baru",
            border: OutlineInputBorder(),
          ),
        ),
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
