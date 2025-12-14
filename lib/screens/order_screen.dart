import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  
  String? _paketDipilih;
  String? _waktuDipilih;
  int _totalHarga = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load Data User dari Profil
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('nama') ?? '';
      _alamatController.text = prefs.getString('alamat') ?? '';
    });
  }

  // Hitung Harga Paket
  void _hitungHarga() {
    int basePrice = 0;
    
    if (_paketDipilih == 'trial') basePrice = 75000;
    if (_paketDipilih == 'weekly') basePrice = 150000;
    if (_paketDipilih == 'monthly') basePrice = 500000;

    // Jika pilih Lunch+Dinner (both), harga dikali 2 (diskon dikit logicnya bisa ditambah)
    if (_waktuDipilih == 'both') basePrice = basePrice * 2;

    setState(() {
      _totalHarga = basePrice;
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_totalHarga == 0) return;

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/ontray-web/public/api/subscribe"),
        body: {
          'nama': _namaController.text,
          'alamat': _alamatController.text,
          'paket': _paketDipilih,
          'waktu': _waktuDipilih,
          'harga': _totalHarga.toString(),
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Langganan Berhasil! Silakan cek menu Status.")),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Gagal order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan koneksi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Langganan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Data Penerima", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Alamat Pengiriman", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Alamat wajib diisi" : null,
              ),
              
              const SizedBox(height: 30),
              const Text("Pilihan Paket", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Durasi Langganan", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'trial', child: Text("Trial (3 Hari) - Rp 75k")),
                  DropdownMenuItem(value: 'weekly', child: Text("Weekly (7 Hari) - Rp 150k")),
                  DropdownMenuItem(value: 'monthly', child: Text("Monthly (30 Hari) - Rp 500k")),
                ],
                onChanged: (val) {
                  _paketDipilih = val;
                  _hitungHarga();
                },
                validator: (v) => v == null ? "Pilih durasi paket" : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Waktu Makan", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'lunch', child: Text("Lunch Only (Siang)")),
                  DropdownMenuItem(value: 'dinner', child: Text("Dinner Only (Malam)")),
                  DropdownMenuItem(value: 'both', child: Text("Lunch + Dinner (Lengkap)")),
                ],
                onChanged: (val) {
                  _waktuDipilih = val;
                  _hitungHarga();
                },
                validator: (v) => v == null ? "Pilih waktu makan" : null,
              ),

              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Tagihan:", style: TextStyle(fontSize: 16)),
                    Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_totalHarga),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                  onPressed: _submitOrder,
                  child: const Text("BAYAR & AKTIFKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}