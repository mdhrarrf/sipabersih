import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/water_viewmodel.dart';
import '../models/water_measure.dart';
import '../services/analysis_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/app_footer.dart'; // IMPORT FOOTER
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

  double? _lat;
  double? _long;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchGPS();
  }

  Future<void> _fetchGPS() async {
    if (!mounted) return;
    setState(() => _isGettingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _long = position.longitude;
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGettingLocation = false);
        _showSnackBar("Gagal mengunci GPS: $e", AppColors.danger);
      }
    }
  }

  void _submitData() async {
    if (_lat == null || _long == null) {
      _showSnackBar(
        "Harap tunggu hingga koordinat GPS terkunci",
        Colors.orange,
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
        latitude: _lat!,
        longitude: _long!,
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
          style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderInfo(),
                    const SizedBox(height: 25),

                    // STATUS GPS
                    _buildLocationCard(),

                    const SizedBox(height: 25),

                    // FORM INPUT
                    _buildFormContainer(),

                    const SizedBox(height: 40),

                    // TOMBOL SUBMIT MEWAH
                    _buildSubmitButton(waterVM),
                  ],
                ),
              ),
            ),

            // FOOTER IDENTITAS
            const AppFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeaderInfo() {
    return Column(
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
          "Gunakan alat sensor IoT yang terkalibrasi. Data akan dikirim secara real-time ke pusat monitoring.",
          style: AppStyles.body.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    final bool isLocked = _lat != null && _long != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusM,
        boxShadow: AppStyles.softShadow,
        border: Border.all(
          color: isLocked
              ? AppColors.success.withOpacity(0.5)
              : AppColors.danger.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isLocked ? AppColors.success : AppColors.danger)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              color: isLocked ? AppColors.success : AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked ? "Koordinat Terkunci" : "Mencari Lokasi...",
                  style: AppStyles.h2.copyWith(
                    fontSize: 13,
                    color: isLocked ? AppColors.success : AppColors.danger,
                  ),
                ),
                Text(
                  isLocked ? "$_lat, $_long" : "Pastikan GPS HP aktif",
                  style: AppStyles.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          if (_isGettingLocation)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (isLocked && !_isGettingLocation)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: _fetchGPS,
            ),
        ],
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
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
            "Derajat Keasaman (pH)",
            "Range: 0 - 14",
            Icons.science_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _tdsController,
            "Zat Terlarut (TDS)",
            "Satuan: ppm",
            Icons.opacity_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _turbidityController,
            "Kekeruhan (Turbidity)",
            "Satuan: NTU",
            Icons.waves_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _tempController,
            "Suhu Air",
            "Satuan: °Celsius",
            Icons.thermostat_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppStyles.h2.copyWith(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyles.caption.copyWith(
          color: AppColors.primaryDark.withOpacity(0.5),
        ),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.accentBlue, size: 20),
        filled: true,
        fillColor: AppColors.lightBlue.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Wajib diisi" : null,
    );
  }

  Widget _buildSubmitButton(WaterViewModel vm) {
    return ElevatedButton(
      onPressed: (vm.isLoading || _isGettingLocation) ? null : _submitData,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusM),
        elevation: 5,
        shadowColor: AppColors.primaryDark.withOpacity(0.5),
      ),
      child: vm.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              "KIRIM DATA KE PUSAT",
              style: AppStyles.h2.copyWith(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
