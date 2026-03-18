import 'package:flutter/material.dart';
// Perbaikan: Gunakan relative import agar konsisten dengan file lain
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
      // 1. Bungkus data ke dalam Model
      final newData = WaterMeasure(
        ph: double.parse(_phController.text),
        tds: double.parse(_tdsController.text),
        turbidity: double.parse(_turbidityController.text),
        temperature: double.parse(_tempController.text),
        timestamp: DateTime.now(),
      );

      // 2. Jalankan Logika Analisis
      final result = AnalysisService.calculateQuality(newData);

      // 3. Simpan ke Riwayat (History)
      HistoryService.addHistory(newData, result);

      // 4. Navigasi ke halaman hasil
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
      appBar: AppBar(title: const Text("Input Data Air")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Parameter Sensor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                _phController,
                "pH Air",
                "6.5 - 8.5",
                Icons.science,
              ),
              _buildTextField(
                _tdsController,
                "TDS (ppm)",
                "< 300",
                Icons.opacity,
              ),
              _buildTextField(
                _turbidityController,
                "Turbidity (NTU)",
                "< 5",
                Icons.waves,
              ),
              _buildTextField(
                _tempController,
                "Suhu (°C)",
                "25 - 30",
                Icons.thermostat,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "PROSES ANALISIS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        // Munculkan keyboard angka
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        // Validasi agar tidak kosong
        validator: (value) {
          if (value == null || value.isEmpty) return "Wajib diisi";
          if (double.tryParse(value) == null) return "Masukkan angka valid";
          return null;
        },
      ),
    );
  }
}
