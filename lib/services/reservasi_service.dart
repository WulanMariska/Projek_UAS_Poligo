import 'package:supabase_flutter/supabase_flutter.dart';

class ReservasiService {
  final supabase = Supabase.instance.client;

  Future<String> generateNomorAntrean(String tipeAntrean) async {
    final prefix = tipeAntrean == "Prioritas" ? "P" : "A";

    final data = await supabase.from('reservasi').select('nomor_antrean');

    int nomorTerbesar = 0;

    for (final item in data) {
      final nomor = item['nomor_antrean'];

      if (nomor != null && nomor.toString().startsWith(prefix)) {
        final angka = int.tryParse(nomor.toString().substring(1));

        if (angka != null && angka > nomorTerbesar) {
          nomorTerbesar = angka;
        }
      }
    }

    final nomorBaru = nomorTerbesar + 1;

    return "$prefix${nomorBaru.toString().padLeft(3, '0')}";
  }

  Future<void> buatReservasi({
    required int idDokter,
    required DateTime tanggal,
    required String tipeAntrean,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    // CEK APAKAH MASIH PUNYA RESERVASI AKTIF
    final reservasiAktif = await supabase
        .from('reservasi')
        .select()
        .eq('id_pasien', user.id)
        .eq('status_reservasi', 'Aktif');

    if (reservasiAktif.isNotEmpty) {
      throw Exception(
        'Anda masih memiliki reservasi aktif. Batalkan atau selesaikan terlebih dahulu.',
      );
    }

    final nomorAntrean = await generateNomorAntrean(tipeAntrean);

    final dokter = await supabase
        .from('dokter')
        .select('kuota')
        .eq('id', idDokter)
        .single();

    int kuotaSekarang = dokter['kuota'];

    if (kuotaSekarang <= 0) {
      throw Exception('Kuota dokter sudah penuh');
    }

    await supabase.from('reservasi').insert({
      'id_pasien': user.id,
      'id_dokter': idDokter,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'nomor_antrean': nomorAntrean,
      'tipe_antrean': tipeAntrean,
      'status_reservasi': 'Aktif',
      'status_antrean': 'Menunggu Giliran',
      'estimasi_menit': 0,
    });

    await supabase
        .from('dokter')
        .update({'kuota': kuotaSekarang - 1})
        .eq('id', idDokter);

    if (kuotaSekarang - 1 <= 0) {
      await supabase
          .from('dokter')
          .update({'status': 'Tutup'})
          .eq('id', idDokter);
    }
  }
}
