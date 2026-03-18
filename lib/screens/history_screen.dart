import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Riwayat Analisis",
          style: AppStyles.h2.copyWith(color: Colors.white),
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
              final history = await HistoryService.getHistory();
              if (history.isNotEmpty) {
                await ReportService.generatePdfReport(history);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Belum ada data untuk diekspor"),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: HistoryService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan: ${snapshot.error}",
                style: AppStyles.body,
              ),
            );
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) return _buildEmptyState();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: history.length,
            itemBuilder: (context, index) =>
                _buildHistoryItem(context, history[index]),
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
            "Belum Ada Riwayat",
            style: AppStyles.h1.copyWith(
              fontSize: 20,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Data yang Anda proses akan muncul di sini.",
            style: AppStyles.body,
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
              // 1. Mini Progress Indicator (Modern Visual)
              Stack(
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
                    style: AppStyles.h2.copyWith(
                      fontSize: 14,
                      color: item.result.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // 2. Info Detail & Badge Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statusBadge(item), // Badge Hijau/Kuning/Merah
                        Text(
                          item.measure.timestamp.toString().substring(11, 16) +
                              " WIB",
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
                        fontSize: 15,
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
        content: Text(
          "Data ini akan dihapus permanen dari memori HP Anda.",
          style: AppStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "BATAL",
              style: AppStyles.h2.copyWith(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "HAPUS",
              style: AppStyles.h2.copyWith(
                fontSize: 13,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
