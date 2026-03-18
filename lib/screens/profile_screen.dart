import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isProcessLoading = false;

  void _triggerRefresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // Tinggi area biru dikunci untuk menampung semua info identitas
    const double headerContentHeight = 280.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: Future.wait([
          _authService.getProfile(),
          _authService.getTotalMeasures(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isProcessLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profileData = snapshot.data?[0];
          final int totalInput = snapshot.data?[1] ?? 0;
          final String name = profileData?['full_name'] ?? "Petugas Lapangan";
          final String petugasId =
              profileData?['petugas_id'] ?? "SIPA-PRO-OFFICER";

          return Stack(
            children: [
              Column(
                children: [
                  // 1. HEADER TETAP (FIXED) - Judul, Foto, Nama, ID
                  _buildFixedHeader(
                    statusBarHeight + headerContentHeight,
                    name,
                    petugasId,
                  ),

                  // 2. AREA SCROLLABLE - Statistik & Menu
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 25, bottom: 40),
                      child: Column(
                        children: [
                          _buildStatsRow(totalInput), // Mulai scroll dari sini
                          const SizedBox(height: 32),
                          _buildMenuSection(context, name, petugasId),
                          const SizedBox(height: 40),
                          _buildFooterInfo(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Overlay Loading
              if (_isProcessLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
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
          // KUNCI SIMETRI: Membuat semua konten berkumpul di tengah secara vertikal
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Judul (Diposisikan paling atas dalam grup tengah)
            Text(
              "PENGATURAN PROFIL",
              style: AppStyles.h1.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14, // Dikecilkan sedikit agar lebih elegan
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 25), // Jarak proporsional
            // 2. Foto Profil
            Container(
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
            ),

            const SizedBox(height: 15),

            // 3. Nama Petugas
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

            // 4. ID Badge
            Container(
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
            ),

            // Memberikan sedikit offset bawah agar visualnya terlihat pas di mata
            // (karena SafeArea biasanya sudah memakan ruang di atas)
            const SizedBox(height: 10),
          ],
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
            _vDivider(),
            _statTile("Status", "Aktif", Icons.verified_rounded),
            _vDivider(),
            _statTile("Level", "PRO", Icons.star_rounded),
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

  Widget _vDivider() =>
      Container(height: 30, width: 1, color: Colors.grey.shade100);

  Widget _buildMenuSection(BuildContext context, String name, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _groupLabel("KEAMANAN & DATA"),
          _menuWrapper([
            _menuItem(
              Icons.edit_note_rounded,
              "Ubah Nama Profil",
              Colors.blue,
              () => _handleEditName(name),
            ),
            _menuItem(
              Icons.badge_rounded,
              "Kartu ID Digital",
              Colors.teal,
              () => _handleShowIDCard(name, id),
            ),
            _menuItem(
              Icons.vpn_key_rounded,
              "Reset Kata Sandi",
              Colors.orange,
              () => _handlePasswordReset(),
            ),
          ]),
          const SizedBox(height: 24),
          _menuWrapper([
            _menuItem(
              Icons.logout_rounded,
              "Keluar Aplikasi",
              AppColors.danger,
              () => _handleLogout(),
              isLast: true,
            ),
          ]),
        ],
      ),
    );
  }

  // --- LOGIC FUNCTIONS ---

  void _handleEditName(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusM),
        title: const Text("Ubah Nama"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nama Baru"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isProcessLoading = true);
                await _authService.updateProfileName(controller.text.trim());
                setState(() => _isProcessLoading = false);
                _triggerRefresh();
              }
            },
            child: const Text("SIMPAN"),
          ),
        ],
      ),
    );
  }

  void _handleShowIDCard(String name, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("IDENTITAS DIGITAL", style: AppStyles.h2),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          id,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _handlePasswordReset() async {
    final email = _authService.currentUser?.email;
    if (email != null) {
      setState(() => _isProcessLoading = true);
      await _authService.resetPassword(email);
      setState(() => _isProcessLoading = false);
      _showSnackBar(
        "Tautan reset password terkirim ke email.",
        AppColors.success,
      );
    }
  }

  void _handleLogout() async {
    await _authService.signOut();
    if (mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
  }

  // --- HELPERS ---

  Widget _groupLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text,
      style: AppStyles.caption.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark.withOpacity(0.5),
      ),
    ),
  );

  Widget _menuWrapper(List<Widget> children) => Container(
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

  Widget _buildFooterInfo() => Column(
    children: [
      Text(
        "SIPABERSIH PRO v2.9.8",
        style: AppStyles.caption.copyWith(fontSize: 10),
      ),
      const Text(
        "Sistem Informasi Kualitas Air Nasional",
        style: TextStyle(fontSize: 9, color: Colors.grey),
      ),
    ],
  );

  void _showSnackBar(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
}
