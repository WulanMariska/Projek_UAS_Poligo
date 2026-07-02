import 'package:supabase_flutter/supabase_flutter.dart';

class PengingatService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> cekReservasiHariIni() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final hariIni = DateTime.now().toIso8601String().split('T')[0];

    final data = await supabase
        .from('reservasi')
        .select('''
          *,
          dokter (
            nama_dokter
          )
        ''')
        .eq('id_pasien', user.id)
        .eq('status_reservasi', 'Aktif')
        .eq('tanggal', hariIni)
        .maybeSingle();

    return data;
  }
}
