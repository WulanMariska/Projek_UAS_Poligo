import 'package:supabase_flutter/supabase_flutter.dart';

class DokterService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getDokter() async {
    final response = await supabase
        .from('dokter')
        .select()
        .order('nama_dokter');

    return List<Map<String, dynamic>>.from(response);
  }
}
