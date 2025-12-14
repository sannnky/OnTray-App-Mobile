import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('nama') ?? '';
      _alamatController.text = prefs.getString('alamat') ?? '';
    });
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('nama', _namaController.text);
    prefs.setString('alamat', _alamatController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil Berhasil Disimpan!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF3B82F6),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _alamatController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Alamat Lengkap", border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                onPressed: _saveData,
                child: const Text("SIMPAN PROFIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Data ini akan otomatis muncul saat kamu mengisi form langganan.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}