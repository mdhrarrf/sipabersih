import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header Dinamis (Gaya Industrial Modern)
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Pusat Bantuan",
                style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // 2. Konten Bantuan
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Layanan Darurat"),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    "BNPB (Bencana)",
                    "117",
                    Icons.warning_amber_rounded,
                    AppColors.danger,
                    "tel:117",
                  ),
                  _buildContactCard(
                    context,
                    "SAR Nasional",
                    "115",
                    Icons.health_and_safety_rounded,
                    Colors.orange,
                    "tel:115",
                  ),
                  _buildContactCard(
                    context,
                    "Layanan Kesehatan",
                    "119",
                    Icons.local_hospital_rounded,
                    Colors.red,
                    "tel:119",
                  ),
                  _buildContactCard(
                    context,
                    "Admin SIPABERSIH (WA)",
                    "+6281234567890",
                    Icons.chat_bubble_outline_rounded,
                    Colors.green,
                    "https://wa.me/6281234567890",
                  ),

                  const SizedBox(height: 35),
                  _buildSectionHeader("Informasi & FAQ"),
                  const SizedBox(height: 12),
                  _buildFAQTile(
                    context,
                    "Bagaimana cara kalibrasi sensor?",
                    "Gunakan cairan buffer pH 7.0 dan pastikan probe sensor bersih sebelum digunakan di lokasi bencana.",
                  ),
                  _buildFAQTile(
                    context,
                    "Arti status 'PERLU FILTRASI'?",
                    "Kualitas air menurun akibat zat terlarut atau kekeruhan. Wajib melalui proses penyaringan fisik sebelum dikonsumsi.",
                  ),
                  _buildFAQTile(
                    context,
                    "Keamanan Data Pengukuran?",
                    "Seluruh riwayat data disimpan secara permanen di database lokal HP Anda dan dapat diekspor menjadi laporan PDF.",
                  ),

                  const SizedBox(height: 35),
                  _buildSectionHeader("Instruksi Lapangan"),
                  const SizedBox(height: 16),
                  _buildInstructionCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppStyles.h2.copyWith(color: AppColors.primaryDark, fontSize: 16),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String url,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusM,
        boxShadow: AppStyles.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: AppStyles.h2.copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: AppStyles.caption),
        trailing: const Icon(
          Icons.open_in_new_rounded,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () => _launchUrl(url),
      ),
    );
  }

  Widget _buildFAQTile(BuildContext context, String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: AppStyles.h2.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        iconColor: AppColors.accentBlue,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              answer,
              style: AppStyles.body.copyWith(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: AppStyles.radiusL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Tips Pengukuran",
                style: AppStyles.h2.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Untuk akurasi maksimal, lakukan pembilasan probe sensor dengan air bersih setiap kali berganti lokasi sumber air di area bencana.",
            style: AppStyles.body.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
