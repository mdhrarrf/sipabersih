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

  // Controller untuk menangkap input user
  final _phController = TextEditingController();
  final _tdsController = TextEditingController();
  final _turbidityController = TextEditingController();
  final _tempController = TextEditingController();

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newData = WaterMeasure(
        ph: double.parse(_phController.text),
        tds: double.parse(_tdsController.text),
        turbidity: double.parse(_turbidityController.text),
        temperature: double.parse(_tempController.text),
        timestamp: DateTime.now(),
      );

      final result = AnalysisService.calculateQuality(newData);
      HistoryService.addHistory(newData, result);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(measure: newData, result: result),
        ),
      );
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 30),

              // Kartu Group Input Bernuansa Biru
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

              // Tombol Submit Biru Aksi
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.radiusM,
                  ),
                  elevation: 8,
                  shadowColor: AppColors.accentBlue.withOpacity(0.4),
                ),
                child: Text(
                  "PROSES ANALISIS SEKARANG",
                  style: AppStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

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
          "Masukkan hasil pembacaan sensor IoT untuk mendapatkan analisis kualitas air secara akurat.",
          style: AppStyles.body.copyWith(color: AppColors.textLight),
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
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppStyles.h2.copyWith(fontSize: 16, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppStyles.caption.copyWith(
            color: AppColors.primaryDark.withOpacity(0.6),
          ),
          hintText: hint,
          hintStyle: AppStyles.caption.copyWith(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12, left: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlue, // Biru Muda Soft
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          filled: true,
          fillColor: AppColors.lightBlue.withOpacity(
            0.3,
          ), // Background input biru transparan
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Tanpa garis kaku
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.accentBlue,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Wajib diisi";
          if (double.tryParse(value) == null) return "Gunakan angka valid";
          return null;
        },
      ),
    );
  }
}
