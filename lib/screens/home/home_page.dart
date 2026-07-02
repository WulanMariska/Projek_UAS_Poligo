import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/dokter_service.dart';
import '../../services/pengingat_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PengingatService pengingatService = PengingatService();

  bool sudahTampilPengingat = false;
  String namaPasien = "Pengguna";

  String searchQuery = '';

  final DokterService dokterService = DokterService();
  @override
  void initState() {
    super.initState();
    getDataPasien();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cekPengingatHariIni();
    });
  }

  Future<void> getDataPasien() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final data = await Supabase.instance.client
          .from('pasien')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          namaPasien = data['nama_lengkap'] ?? 'Pengguna';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> cekPengingatHariIni() async {
    if (sudahTampilPengingat) return;

    final reservasi = await pengingatService.cekReservasiHariIni();

    if (reservasi == null) return;

    sudahTampilPengingat = true;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("🔔 Jadwal Reservasi Hari Ini"),
          content: Text(
            "Anda memiliki jadwal reservasi hari ini\n\n"
            "Dokter : ${reservasi['dokter']['nama_dokter']}\n"
            "Nomor Antrean : ${reservasi['nomor_antrean']}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, $namaPasien 👋",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifikasi');
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications, size: 30),

                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ), // <-- INI YANG KURANG

              const SizedBox(height: 20),

              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },

                decoration: InputDecoration(
                  hintText: "Cari dokter...",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "POLIGO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Reservasi Dokter Jadi Lebih Mudah",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Menu Utama",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/dokter');
                    },
                    child: _menuItem(Icons.medical_services, "Dokter"),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/reservasi');
                    },
                    child: _menuItem(Icons.calendar_month, "Reservasi"),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/antrian');
                    },
                    child: _menuItem(Icons.confirmation_number, "Antrean"),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: _menuItem(Icons.person, "Profil"),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daftar Dokter",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: dokterService.getDokter(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Belum ada data dokter");
                  }

                  final dokterList = snapshot.data!;

                  final filteredDokter = dokterList.where((dokter) {
                    final nama = dokter['nama_dokter'].toString().toLowerCase();

                    return nama.contains(searchQuery);
                  }).toList();

                  return Column(
                    children: filteredDokter.map((dokter) {
                      return _doctorCard(
                        context,
                        dokter['nama_dokter'] ?? '-',
                        dokter['spesialis'] ?? '-',
                        dokter['status'] ?? 'Tutup',
                        dokter['kuota'].toString(),
                        dokter['jam_buka'] ?? '-',
                        dokter['jam_tutup'] ?? '-',
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _menuItem(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFFEAF3FF),
          child: Icon(icon, color: const Color(0xFF1E88E5)),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
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
              child: Icon(Icons.person, size: 32, color: Color(0xFF1E88E5)),
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

                  const SizedBox(height: 4),

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
