import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil daftar riwayat dari service
    final List<HistoryItem> history = HistoryService.getHistory();

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Analisis")),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryCard(item);
              },
            ),
    );
  }

  // Tampilan jika data masih kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text(
            "Belum ada riwayat data.",
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Tampilan Kartu Riwayat
  Widget _buildHistoryCard(HistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: item.result.color,
          radius: 25,
          child: Text(
            "${item.result.score}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          item.result.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item.result.color,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            "pH: ${item.measure.ph.toStringAsFixed(1)} | TDS: ${item.measure.tds.toInt()} ppm\n"
            "Waktu: ${item.measure.timestamp.toString().substring(0, 16)}",
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
