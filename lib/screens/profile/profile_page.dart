import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nama = "-";
  String email = "-";
  String noHp = "-";

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final data = await Supabase.instance.client
          .from('pasien')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        nama = data['nama_lengkap'] ?? "-";
        email = data['email'] ?? "-";
        noHp = data['no_hp'] ?? "-";
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(title: const Text("Profil Saya"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFEAF3FF),
              child: Icon(Icons.person, size: 60, color: Color(0xFF1E88E5)),
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    _item("Nama", nama),

                    const Divider(),

                    _item("Email", email),

                    const Divider(),

                    _item("No HP", noHp),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: logout,

                icon: const Icon(Icons.logout),

                label: const Text("Logout", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
