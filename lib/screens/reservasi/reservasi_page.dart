import 'package:flutter/material.dart';
import '../../services/dokter_service.dart';
import '../../services/reservasi_service.dart';

class ReservasiPage extends StatefulWidget {
  const ReservasiPage({super.key});

  @override
  State<ReservasiPage> createState() => _ReservasiPageState();
}

class _ReservasiPageState extends State<ReservasiPage> {
  String? selectedDokter;

  int? selectedDokterId;

  String tipeAntrean = "Normal";

  DateTime? selectedDate;

  bool sudahLoadDokter = false;

  final DokterService dokterService = DokterService();
  final ReservasiService reservasiService = ReservasiService();

  List<Map<String, dynamic>> dokterList = [];

  Future<void> loadDokter() async {
    final data = await dokterService.getDokter();

    if (mounted) {
      setState(() {
        dokterList = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadDokter();
  }

  Future<void> pilihTanggal() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dokterDariHome =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (!sudahLoadDokter && dokterDariHome != null) {
      selectedDokter = dokterDariHome;
      sudahLoadDokter = true;
    }

    if (selectedDokterId == null && selectedDokter != null) {
      try {
        final dokterDipilih = dokterList.firstWhere(
          (dokter) => dokter['nama_dokter'] == selectedDokter,
        );

        selectedDokterId = dokterDipilih['id'];
      } catch (_) {}
    }

    Map<String, dynamic>? dokterDipilih;

    if (selectedDokter != null) {
      try {
        dokterDipilih = dokterList.firstWhere(
          (dokter) => dokter['nama_dokter'] == selectedDokter,
        );
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(title: const Text("Reservasi Dokter"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Pilih Dokter",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedDokter,

              decoration: const InputDecoration(border: OutlineInputBorder()),

              hint: const Text("Pilih Dokter"),

              items: dokterList.map((dokter) {
                return DropdownMenuItem<String>(
                  value: dokter['nama_dokter'],

                  child: Text(dokter['nama_dokter']),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedDokter = value;

                  final dokterDipilih = dokterList.firstWhere(
                    (dokter) => dokter['nama_dokter'] == value,
                  );

                  selectedDokterId = dokterDipilih['id'];
                });
              },
            ),

            if (dokterDipilih != null) ...[
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        dokterDipilih['nama_dokter'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Jam Praktik : "
                        "${dokterDipilih['jam_buka'].toString().substring(0, 5)}"
                        " - "
                        "${dokterDipilih['jam_tutup'].toString().substring(0, 5)}",
                      ),

                      const SizedBox(height: 5),

                      Text("Kuota Tersisa : ${dokterDipilih['kuota']}"),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 25),

            const Text(
              "Pilih Tanggal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            InkWell(
              onTap: pilihTanggal,

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: Colors.grey.shade400),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),

                    const SizedBox(width: 10),

                    Text(
                      selectedDate == null
                          ? "Pilih tanggal reservasi"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Tipe Antrean",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            RadioListTile(
              value: "Normal",
              groupValue: tipeAntrean,

              title: const Text("Antrean Umum (A001, A002, A003...)"),

              onChanged: (value) {
                setState(() {
                  tipeAntrean = value.toString();
                });
              },
            ),

            RadioListTile(
              value: "Prioritas",
              groupValue: tipeAntrean,

              title: const Text("Antrean Prioritas (P001, P002, P003...)"),

              onChanged: (value) {
                setState(() {
                  tipeAntrean = value.toString();
                });
              },
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () async {
                  try {
                    if (selectedDokterId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih dokter terlebih dahulu'),
                        ),
                      );
                      return;
                    }

                    if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih tanggal terlebih dahulu'),
                        ),
                      );
                      return;
                    }

                    await reservasiService.buatReservasi(
                      idDokter: selectedDokterId!,
                      tanggal: selectedDate!,
                      tipeAntrean: tipeAntrean,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reservasi berhasil dibuat'),
                        ),
                      );

                      Navigator.pushReplacementNamed(context, '/antrian');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },

                child: const Text(
                  "Buat Reservasi",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
