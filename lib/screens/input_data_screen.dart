import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../services/history_service.dart';
import '../models/water_measure.dart';
import '../services/analysis_service.dart';
import '../utils/constants.dart';

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({super.key});

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  final _tdsController = TextEditingController();
  final _turbidityController = TextEditingController();
  final _tempController = TextEditingController();

  // --- TAMBAHKAN DEKLARASI INI ---
  bool _isLoading = false;

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      // Aktifkan Loading
      setState(() => _isLoading = true);

      try {
        final newData = WaterMeasure(
          ph: double.parse(_phController.text),
          tds: double.parse(_tdsController.text),
          turbidity: double.parse(_turbidityController.text),
          temperature: double.parse(_tempController.text),
          timestamp: DateTime.now(),
        );

        final result = AnalysisService.calculateQuality(newData);

        // KIRIM KE SUPABASE (CLOUD)
        await HistoryService.addHistory(newData, result);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResultScreen(measure: newData, result: result),
            ),
          );
        }
      } catch (e) {
        // Tampilkan pesan jika internet bermasalah atau gagal simpan
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal Simpan: $e"),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      } finally {
        // Matikan Loading apa pun hasilnya
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Input Data Air",
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppStyles.radiusL,
                  boxShadow: AppStyles.softShadow,
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      _phController,
                      "pH Air",
                      "Contoh: 7.0",
                      Icons.science_rounded,
                    ),
                    _buildTextField(
                      _tdsController,
                      "TDS (ppm)",
                      "Contoh: 150",
                      Icons.opacity_rounded,
                    ),
                    _buildTextField(
                      _turbidityController,
                      "Turbidity (NTU)",
                      "Contoh: 3.5",
                      Icons.waves_rounded,
                    ),
                    _buildTextField(
                      _tempController,
                      "Suhu (°C)",
                      "Contoh: 27.5",
                      Icons.thermostat_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // TOMBOL DENGAN INDIKATOR LOADING
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _submitData, // Disable tombol saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.radiusM,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "PROSES ANALISIS SEKARANG",
                        style: AppStyles.h2.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi helper _buildTextField dan _buildHeaderInfo tetap sama seperti sebelumnya...
  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Data Parameter",
          style: AppStyles.h1.copyWith(
            fontSize: 24,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Masukkan hasil pembacaan sensor IoT untuk mendapatkan analisis kualitas air.",
          style: AppStyles.body,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.accentBlue),
          hintText: hint,
          filled: true,
          fillColor: AppColors.lightBlue.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Wajib diisi" : null,
      ),
    );
  }
}
