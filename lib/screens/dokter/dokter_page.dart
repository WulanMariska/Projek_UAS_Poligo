import 'package:flutter/material.dart';
import '../../services/dokter_service.dart';

class DokterPage extends StatefulWidget {
  const DokterPage({super.key});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  final DokterService dokterService = DokterService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(title: const Text("Dokter"), centerTitle: true),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dokterService.getDokter(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data dokter"));
          }

          final dokterList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: dokterList.length,

            itemBuilder: (context, index) {
              final dokter = dokterList[index];

              return _doctorCard(
                context,
                dokter['nama_dokter'] ?? '-',
                dokter['spesialis'] ?? '-',
                dokter['status'] ?? 'Tutup',
                dokter['kuota'].toString(),
                dokter['jam_buka'] ?? '-',
                dokter['jam_tutup'] ?? '-',
              );
            },
          );
        },
      ),
    );
  }

  static Widget _doctorCard(
    BuildContext context,
    String nama,
    String spesialis,
    String status,
    String kuota,
    String jamBuka,
    String jamTutup,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFEAF3FF),

              child: Icon(Icons.person, color: Color(0xFF1E88E5), size: 30),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  Text(spesialis),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Text("Status: "),

                      Text(
                        status,
                        style: TextStyle(
                          color: status == "Buka" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Text("Kuota: $kuota"),

                  const SizedBox(height: 5),

                  Text(
                    "Jam Praktik: ${jamBuka.substring(0, 5)} - ${jamTutup.substring(0, 5)}",
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 110,
              height: 40,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reservasi', arguments: nama);
                },

                child: const Text("Reservasi", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
