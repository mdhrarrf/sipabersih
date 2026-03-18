import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Fungsi Registrasi Petugas + Simpan ke Tabel Profiles
  // lib/services/auth_service.dart

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String petugasId,
  }) async {
    // Database Trigger membutuhkan data ini di dalam user_metadata
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'petugas_id': petugasId},
    );
  }

  // Fungsi Login & SignOut tetap sama seperti sebelumnya...
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async => await _supabase.auth.signOut();
  User? get currentUser => _supabase.auth.currentUser;

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    // Mengambil satu baris data dari tabel 'profiles' yang ID-nya cocok
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }
}
