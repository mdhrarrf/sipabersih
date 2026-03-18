import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Fungsi Registrasi Petugas + Simpan ke Tabel Profiles
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String petugasId,
  }) async {
    // A. Buat User di Auth Supabase
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final User? user = res.user;

    // B. Jika berhasil, simpan detailnya ke tabel 'profiles'
    if (user != null) {
      await _supabase.from('profiles').insert({
        'id': user.id, // Ambil ID dari Auth
        'full_name': fullName,
        'petugas_id': petugasId,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
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
