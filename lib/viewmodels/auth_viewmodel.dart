import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  int _totalMeasures = 0;

  // Getter
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;
  int get totalMeasures => _totalMeasures;

  // 1. Logika Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // 2. Logika Ambil Profil Lengkap (Data Nyata)
  Future<void> fetchFullProfile() async {
    _setLoading(true);
    try {
      // Mengambil profile dan total input secara paralel (lebih cepat)
      final results = await Future.wait([
        _authService.getProfile(),
        _authService.getTotalMeasures(),
      ]);
      _userProfile = results[0] as Map<String, dynamic>?;
      _totalMeasures = results[1] as int;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  // 3. Logika Update Nama
  Future<void> updateName(String newName) async {
    _setLoading(true);
    try {
      await _authService.updateProfileName(newName);
      await fetchFullProfile(); // Refresh data setelah update
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  // 4. Logika Logout
  Future<void> logout() async {
    await _authService.signOut();
    _userProfile = null;
    notifyListeners();
  }

  // Helper untuk set loading dan beritahu UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
