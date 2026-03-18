// lib/screens/input_data_screen.dart
import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../services/analysis_service.dart'; // Import service baru
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

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newData = WaterMeasure(
        ph: double.parse(_phController.text),
        tds: double.parse(_tdsController.text),
        turbidity: double.parse(_turbidityController.text),
        temperature: double.parse(_tempController.text),
        timestamp: DateTime.now(),
      );

      // JALANKAN ANALISIS
      final result = AnalysisService.calculateQuality(newData);

      // DEBUG: Cetak hasil di console
      print("Status: ${result.status}, Skor: ${result.score}");

      // STEP BERIKUTNYA: Pindah ke halaman hasil (Step 4)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hasil: ${result.status}"), backgroundColor: result.color),
      );
      
      Navigator.pop(context);
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
              const Text("Parameter Sensor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(_phController, "pH Air", "6.5 - 8.5", Icons.science),
              _buildTextField(_tdsController, "TDS (ppm)", "< 300", Icons.opacity),
              _buildTextField(_turbidityController, "Turbidity (NTU)", "< 5", Icons.waves),
              _buildTextField(_tempController, "Suhu (°C)", "25 - 30", Icons.thermostat),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("PROSES ANALISIS", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0), // PERBAIKAN DI SINI
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? "Wajib diisi" : null,
      ),
    );
  }
}