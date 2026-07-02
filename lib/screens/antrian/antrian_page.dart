import 'package:flutter/material.dart';
import '../../services/antrian_service.dart';

class AntrianPage extends StatefulWidget {
  const AntrianPage({super.key});

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  final AntrianService antrianService = AntrianService();

  late Future<Map<String, dynamic>?> futureAntrian;

  @override
  void initState() {
    super.initState();
    futureAntrian = antrianService.getAntrianSaya();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Giliran':
        return Colors.orange;

      case 'Akan Ditangani':
        return Colors.amber;

      case 'Sedang Ditangani':
        return Colors.blue;

      case 'Selesai':
        return Colors.green;

      case 'Dibatalkan':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Antrean Saya"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: futureAntrian,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Belum ada antrean"));
          }

          final antrian = snapshot.data!;

          final dokter = antrian['dokter']?['nama_dokter'] ?? '-';

          final jamBuka = antrian['dokter']?['jam_buka'] ?? '-';

          final jamTutup = antrian['dokter']?['jam_tutup'] ?? '-';

          final nomorAntrean = antrian['nomor_antrean'] ?? '-';

          final status = antrian['status_antrean'] ?? '-';

          final estimasi = antrian['estimasi_menit'].toString();

          final tanggal = antrian['tanggal'] ?? '-';

          final reservasiId = antrian['id'];

          final dokterId = antrian['id_dokter'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  Card(
                    elevation: 2,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        children: [
                          const Text(
                            "Nomor Antrean",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            nomorAntrean,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),

                          const Divider(height: 30),

                          _infoRow("Dokter", dokter),

                          const SizedBox(height: 10),

                          _infoRow(
                            "Jam Praktik",
                            "${jamBuka.toString().substring(0, 5)} - "
                                "${jamTutup.toString().substring(0, 5)}",
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Status",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    status,
                                  ).withOpacity(0.15),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          _infoRow("Estimasi", "$estimasi Menit"),

                          const SizedBox(height: 10),

                          _infoRow("Tanggal", tanggal),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureAntrian = antrianService.getAntrianSaya();
                        });
                      },

                      child: const Text(
                        "Refresh Antrean",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),

                      onPressed: () async {
                        final konfirmasi = await showDialog<bool>(
                          context: context,

                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Batalkan Reservasi"),

                              content: const Text(
                                "Yakin ingin membatalkan reservasi?",
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },

                                  child: const Text("Tidak"),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },

                                  child: const Text("Ya"),
                                ),
                              ],
                            );
                          },
                        );

                        if (konfirmasi == true) {
                          await antrianService.batalkanReservasi(
                            reservasiId,
                            dokterId,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Reservasi berhasil dibatalkan"),
                              ),
                            );

                            setState(() {
                              futureAntrian = antrianService.getAntrianSaya();
                            });
                          }
                        }
                      },

                      child: const Text(
                        "Batalkan Reservasi",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
