import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/report_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/app_footer.dart'; // IMPORT FOOTER

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Riwayat Analisis",
          style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: "Ekspor PDF",
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sedang mengambil data pusat...")),
              );

              final results = await Future.wait([
                HistoryService.getHistory(),
                AuthService().getProfile(),
              ]);

              final List<HistoryItem> history = results[0] as List<HistoryItem>;
              final Map<String, dynamic>? profile =
                  results[1] as Map<String, dynamic>?;

              if (history.isNotEmpty && profile != null) {
                if (context.mounted) {
                  await ReportService.generatePdfReport(
                    history: history,
                    officerName: profile['full_name'] ?? "Petugas Lapangan",
                    officerId: profile['petugas_id'] ?? "SIPA-PRO",
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Gagal cetak: Riwayat kosong atau profil tidak terbaca",
                      ),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<List<HistoryItem>>(
        stream: HistoryService.getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan cloud: ${snapshot.error}",
                style: AppStyles.body,
              ),
            );
          }

          final history = snapshot.data ?? [];

          // Jika Kosong, tampilkan Empty State + Footer
          if (history.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  _buildEmptyState(),
                  const SizedBox(height: 100),
                  const AppFooter(),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            // TAMBAHKAN +1 UNTUK FOOTER
            itemCount: history.length + 1,
            itemBuilder: (context, index) {
              // LOGIKA FOOTER DI AKHIR LIST
              if (index == history.length) {
                return const AppFooter();
              }

              final item = history[index];
              return _buildHistoryItem(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              size: 80,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Riwayat Kosong",
            style: AppStyles.h1.copyWith(
              fontSize: 20,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Data pengukuran cloud akan muncul di sini.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(item.measure.id.toString()),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _showConfirmDelete(context),
        onDismissed: (direction) async {
          if (item.measure.id != null) {
            await HistoryService.deleteHistory(item.measure.id!);
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.9),
            borderRadius: AppStyles.radiusM,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppStyles.radiusM,
            boxShadow: AppStyles.softShadow,
          ),
          child: Row(
            children: [
              _buildMiniScore(item),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statusBadge(item),
                        Text(
                          "${item.measure.timestamp.toString().substring(11, 16)} WIB",
                          style: AppStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "pH: ${item.measure.ph}  •  TDS: ${item.measure.tds.toInt()} ppm",
                      style: AppStyles.h2.copyWith(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tanggal: ${item.measure.timestamp.toString().substring(0, 10)}",
                      style: AppStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniScore(HistoryItem item) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 52,
          width: 52,
          child: CircularProgressIndicator(
            value: item.result.score / 100,
            strokeWidth: 4,
            backgroundColor: AppColors.lightBlue,
            color: item.result.color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          "${item.result.score}",
          style: AppStyles.h2.copyWith(fontSize: 14, color: item.result.color),
        ),
      ],
    );
  }

  Widget _statusBadge(HistoryItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: item.result.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.result.status,
        style: TextStyle(
          color: item.result.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusM),
        title: Text("Hapus Riwayat?", style: AppStyles.h2),
        content: const Text(
          "Data ini akan dihapus permanen dari sistem pusat (Cloud).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("BATAL", style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "HAPUS",
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
