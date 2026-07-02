import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi"), centerTitle: true),

      body: FutureBuilder(
        future: supabase
            .from('reservasi')
            .select('''
              *,
              dokter(nama_dokter)
            ''')
            .eq('id_pasien', supabase.auth.currentUser!.id)
            .order('created_at', ascending: false),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List<dynamic>;

          if (data.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi"));
          }

          return ListView.builder(
            itemCount: data.length,

            itemBuilder: (context, index) {
              final item = data[index];

              return ListTile(
                leading: const Icon(Icons.notifications, color: Colors.blue),

                title: Text("Reservasi ${item['dokter']['nama_dokter']}"),

                subtitle: Text("Tanggal ${item['tanggal']}"),
              );
            },
          );
        },
      ),
    );
  }
}
