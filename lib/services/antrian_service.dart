import 'package:supabase_flutter/supabase_flutter.dart';

class AntrianService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getAntrianSaya() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('USER BELUM LOGIN');
      return null;
    }

    print('USER LOGIN: ${user.id}');

    final data = await supabase
        .from('reservasi')
        .select('''
          *,
          dokter (
            nama_dokter,
            jam_buka,
            jam_tutup
          )
        ''')
        .eq('id_pasien', user.id)
        .eq('status_reservasi', 'Aktif')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    print('DATA ANTREAN: $data');

    return data;
  }

  Future<void> batalkanReservasi(int reservasiId, int dokterId) async {
    try {
      print('====== CANCEL ======');
      print('reservasiId : $reservasiId');
      print('dokterId    : $dokterId');

      final reservasi = await supabase
          .from('reservasi')
          .select()
          .eq('id', reservasiId)
          .single();

      print('DATA RESERVASI : $reservasi');

      if (reservasi['status_reservasi'] == 'Dibatalkan') {
        print('RESERVASI SUDAH DIBATALKAN');
        return;
      }

      final dokter = await supabase
          .from('dokter')
          .select()
          .eq('id', dokterId)
          .single();

      print('DATA DOKTER : $dokter');

      final int kuotaSekarang = dokter['kuota'] ?? 0;

      await supabase
          .from('reservasi')
          .update({
            'status_reservasi': 'Dibatalkan',
            'status_antrean': 'Dibatalkan',
          })
          .eq('id', reservasiId);

      print('STATUS RESERVASI BERHASIL DIUBAH');

      await supabase
          .from('dokter')
          .update({'kuota': kuotaSekarang + 1, 'status': 'Buka'})
          .eq('id', dokterId);

      print('KUOTA DOKTER BERHASIL DIKEMBALIKAN');
    } catch (e) {
      print('ERROR BATAL RESERVASI: $e');
      rethrow;
    }
  }
}
