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
          // 1. Header Dinamis
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Pusat Bantuan & SOP",
                style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // 2. Konten Utama
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN 1: KONTAK DARURAT ---
                  _buildSectionHeader("Kontak Darurat & Lapangan"),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    "Pusdalops BNPB",
                    "117",
                    Icons.warning_amber_rounded,
                    AppColors.danger,
                    "tel:117",
                  ),
                  _buildContactCard(
                    context,
                    "Layanan Medik (Kemenkes)",
                    "119",
                    Icons.local_hospital_rounded,
                    Colors.red,
                    "tel:119",
                  ),
                  _buildContactCard(
                    context,
                    "Technical Support (Admin)",
                    "WhatsApp",
                    Icons.chat_bubble_outline_rounded,
                    Colors.green,
                    "https://wa.me/6281234567890",
                  ),

                  const SizedBox(height: 35),

                  // --- BAGIAN 2: SOP PENGGUNAAN APLIKASI ---
                  _buildSectionHeader("SOP Penggunaan Aplikasi"),
                  const SizedBox(height: 12),
                  _buildInstructionCard(
                    title: "Alur Kerja Petugas",
                    color: AppColors.primaryDark,
                    steps: [
                      "Pastikan GPS pada perangkat sudah aktif dan akurat.",
                      "Bilas probe sensor dengan air bersih sebelum pencelupan.",
                      "Gunakan menu 'Input Data' untuk memulai proses.",
                      "Tunggu hingga indikator lokasi berwarna hijau (Locked).",
                      "Simpan data untuk sinkronisasi otomatis ke server pusat.",
                    ],
                  ),

                  const SizedBox(height: 35),

                  // --- BAGIAN 3: MITIGASI KRISIS AIR ---
                  _buildSectionHeader("Prosedur Mitigasi Krisis Air"),
                  const SizedBox(height: 12),
                  _buildMitigationCard(),

                  const SizedBox(height: 35),

                  // --- BAGIAN 4: FAQ TEKNIS ---
                  _buildSectionHeader("Informasi Teknis & FAQ"),
                  const SizedBox(height: 12),
                  _buildFAQTile(
                    context,
                    "Cara Kalibrasi TDS & pH?",
                    "Gunakan cairan kalibrasi standar (pH 7.0 & TDS 1382ppm). Celupkan probe, tahan tombol kalibrasi pada alat IoT hingga angka stabil, lalu cocokan dengan nilai pada botol kalibrasi.",
                  ),
                  _buildFAQTile(
                    context,
                    "Arti Status 'PERLU FILTRASI'?",
                    "Air secara kimiawi aman namun memiliki tingkat kekeruhan (Turbidity) tinggi. Disarankan menggunakan saringan pasir lambat atau filter karbon aktif sebelum dikonsumsi.",
                  ),
                  _buildFAQTile(
                    context,
                    "Mengapa Lokasi Gagal Terkunci?",
                    "Pastikan Anda berada di area terbuka (Open Space). Bangunan beton tebal atau cuaca ekstrem dapat menghalangi sinyal satelit GPS.",
                  ),
                  _buildFAQTile(
                    context,
                    "Data Tidak Muncul di Riwayat?",
                    "Pastikan koneksi internet stabil. Jika offline, data akan disimpan sementara di memori cache dan akan diunggah saat sinyal tersedia.",
                  ),

                  const SizedBox(height: 40),
                  _buildAppFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

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
        onTap: () => _launchUrl(url),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: AppStyles.h2.copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: AppStyles.caption),
        trailing: const Icon(
          Icons.open_in_new_rounded,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInstructionCard({
    required String title,
    required Color color,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusL,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_rounded, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppStyles.h2.copyWith(fontSize: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.key + 1}. ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppStyles.body.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMitigationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: AppStyles.radiusL,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Tindakan Mitigasi Cepat",
                style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _mitigationItem(
            "Jika status TIDAK LAYAK: Segera pasang garis pembatas di area sumber air agar tidak digunakan warga.",
          ),
          _mitigationItem(
            "Jika status PERLU FILTER: Bagikan instruksi perebusan air minimal 10 menit setelah filtrasi fisik.",
          ),
          _mitigationItem(
            "Lakukan pengambilan sampel 100 meter dari titik terdampak untuk mencari zona air aman.",
          ),
        ],
      ),
    );
  }

  Widget _mitigationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.white24, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
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
          style: AppStyles.h2.copyWith(fontSize: 14, color: AppColors.textDark),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              answer,
              style: AppStyles.body.copyWith(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            "SIPABERSIH PRO v3.5.0",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            "Badan Nasional Penanggulangan Bencana",
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
