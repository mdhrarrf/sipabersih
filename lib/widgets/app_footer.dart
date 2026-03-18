import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/constants.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data secara reaktif dari SettingsViewModel
    final settingsVM = context.watch<SettingsViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Garis Pemisah Minimalis
          Container(
            width: 30,
            height: 1.5,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Nama Aplikasi & Versi
          Text(
            "${settingsVM.appName} ${settingsVM.appVersion}",
            style: AppStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),

          // 3. Nama Instansi / Organisasi
          Text(
            settingsVM.orgName.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 8),

          // 4. Build ID (Penting untuk audit teknis)
          Text(
            "ID: ${settingsVM.buildNumber}",
            style: TextStyle(
              fontSize: 7,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
