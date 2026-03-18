import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/water_viewmodel.dart';
import '../models/water_measure.dart';
import '../services/analysis_service.dart';
import '../services/location_service.dart'; // Import Service Lokasi
import '../utils/constants.dart';
import 'result_screen.dart';

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

  // VARIABEL LOKASI BARU
  double? _lat;
  double? _long;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchGPS(); // Ambil GPS otomatis saat halaman dibuka
  }

  // Fungsi ambil GPS
  Future<void> _fetchGPS() async {
    setState(() => _isGettingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _lat = position.latitude;
        _long = position.longitude;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() => _isGettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengunci GPS: $e"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _submitData() async {
    // DEBUGGING: Cek di console
    print("DEBUG LOKASI: Lat: $_lat, Long: $_long");

    if (_lat == null || _long == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("GPS belum terkunci!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final waterVM = context.read<WaterViewModel>();

      final newData = WaterMeasure(
        ph: double.parse(_phController.text),
        tds: double.parse(_tdsController.text),
        turbidity: double.parse(_turbidityController.text),
        temperature: double.parse(_tempController.text),
        latitude: _lat!, // SERTAKAN LATITUDE
        longitude: _long!, // SERTAKAN LONGITUDE
        timestamp: DateTime.now(),
      );

      final result = AnalysisService.calculateQuality(newData);
      final success = await waterVM.saveMeasure(newData, result);

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultScreen(measure: newData, result: result),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final waterVM = context.watch<WaterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Pengukuran Lapangan",
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 25),

              // WIDGET STATUS LOKASI NYATA
              _buildLocationCard(),

              const SizedBox(height: 25),
              _buildFormContainer(),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: (waterVM.isLoading || _isGettingLocation)
                    ? null
                    : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.radiusM,
                  ),
                ),
                child: waterVM.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "PROSES ANALISIS SEKARANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  // WIDGET BARU: STATUS KOORDINAT GPS
  Widget _buildLocationCard() {
    final bool isLocked = _lat != null && _long != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.success.withOpacity(0.05)
            : AppColors.danger.withOpacity(0.05),
        borderRadius: AppStyles.radiusM,
        border: Border.all(
          color: isLocked ? AppColors.success : AppColors.danger,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
            color: isLocked ? AppColors.success : AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked ? "Koordinat Terkunci" : "Sedang Melacak Posisi...",
                  style: AppStyles.h2.copyWith(
                    fontSize: 13,
                    color: isLocked ? AppColors.success : AppColors.danger,
                  ),
                ),
                if (isLocked)
                  Text(
                    "$_lat, $_long",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (!isLocked)
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (isLocked)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: _fetchGPS,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Parameter Air",
        style: AppStyles.h1.copyWith(
          fontSize: 22,
          color: AppColors.primaryDark,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "Lengkapi data parameter air sesuai hasil pembacaan sensor di titik lokasi ini.",
        style: AppStyles.body,
      ),
    ],
  );

  Widget _buildFormContainer() => Container(
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
          "6.5 - 8.5",
          Icons.science_rounded,
        ),
        _buildTextField(
          _tdsController,
          "TDS (ppm)",
          "< 300",
          Icons.opacity_rounded,
        ),
        _buildTextField(
          _turbidityController,
          "Turbidity (NTU)",
          "< 5",
          Icons.waves_rounded,
        ),
        _buildTextField(
          _tempController,
          "Suhu (°C)",
          "25 - 30",
          Icons.thermostat_rounded,
        ),
      ],
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          hintText: hint,
          filled: true,
          fillColor: AppColors.lightBlue.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Wajib diisi" : null,
      ),
    );
  }
}
