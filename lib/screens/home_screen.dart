import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/history_service.dart'; // IMPORT BARU
import 'input_data_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SIPABERSIH',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 25),

            // --- PERBAIKAN DI SINI: Gunakan FutureBuilder ---
            FutureBuilder<HistoryItem?>(
              future: HistoryService.getLastData(), // Memanggil database
              builder: (context, snapshot) {
                // 1. Tampilkan Loading saat database sedang bekerja
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Ambil data dari hasil database (snapshot)
                final lastItem = snapshot.data;
                final Color statusColor =
                    lastItem?.result.color ?? AppColors.primaryBlue;

                // 3. Tampilkan Card Status dengan data yang sudah ada
                return _buildStatusCard(lastItem, statusColor);
              },
            ),

            const SizedBox(height: 30),
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildMenuGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(HistoryItem? lastItem, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Status Air Terakhir",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                lastItem?.result.status ?? "BELUM ADA DATA",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (lastItem != null)
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                "${lastItem.result.score}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildMenuCard(
          "Input Data",
          Icons.add_chart,
          Colors.orange,
          const InputDataScreen(),
        ),
        _buildMenuCard(
          "Riwayat",
          Icons.history,
          Colors.teal,
          const HistoryScreen(),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return InkWell(
      onTap: () async {
        // MENUNGGU USER KEMBALI DARI HALAMAN LAIN
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
        // REFRESH TAMPILAN HOME
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Selamat Datang, Relawan",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        Text(
          "Monitor kualitas air di lokasi bencana hari ini.",
          style: TextStyle(fontSize: 14, color: AppColors.textLight),
        ),
      ],
    );
  }
}
