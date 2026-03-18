import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsViewModel extends ChangeNotifier {
  // 1. Data Metadata Aplikasi
  final String _appVersion = "v3.8.2";
  final String _buildNumber = "20241025.01";
  final String _orgName = "Badan Nasional Penanggulangan Bencana";
  final String _appName = "SIPABERSIH PRO";

  // 2. State Status Sistem
  bool _isServerOnline = true;
  DateTime _lastSyncTime = DateTime.now();

  // Getters
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  String get orgName => _orgName;
  String get appName => _appName;
  bool get isServerOnline => _isServerOnline;
  DateTime get lastSyncTime => _lastSyncTime;

  // Fungsi untuk mengecek kesehatan koneksi (Health Check)
  Future<void> checkServerStatus() async {
    try {
      // Mencoba ping sederhana ke Supabase
      await Supabase.instance.client.from('profiles').select('id').limit(1);
      _isServerOnline = true;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _isServerOnline = false;
    }
    notifyListeners();
  }

  // Fungsi untuk update manual jika dibutuhkan
  void updateSyncTime() {
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }
}
