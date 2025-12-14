import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Map<String, dynamic>? _statusData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final namaUser = prefs.getString('nama');

    if (namaUser != null) {
      try {
        final response = await http.get(Uri.parse("http://10.0.2.2/ontray-web/public/api/status?nama=$namaUser"));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          setState(() {
            _statusData = json['data'];
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lacak Pesanan")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _statusData == null 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_meals, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Belum ada langganan aktif.", style: TextStyle(color: Colors.grey)),
                  TextButton(onPressed: _fetchStatus, child: const Text("Refresh"))
                ],
              ),
            )
          : _buildStatusDetail(),
    );
  }

  Widget _buildStatusDetail() {
    String status = _statusData!['status_pengiriman']; // menunggu, dimasak, diantar, selesai
    
    return RefreshIndicator(
      onRefresh: _fetchStatus,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                const Text("STATUS HARI INI", style: TextStyle(color: Colors.grey, letterSpacing: 2, fontSize: 12)),
                const SizedBox(height: 10),
                Text(
                  status.toUpperCase(), 
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))
                ),
                const Divider(height: 40),
                _buildStep("Menunggu Konfirmasi", Icons.hourglass_top, ['menunggu', 'dimasak', 'diantar', 'selesai'].contains(status)),
                _buildStep("Sedang Dimasak", Icons.soup_kitchen, ['dimasak', 'diantar', 'selesai'].contains(status)),
                _buildStep("Dalam Pengiriman", Icons.delivery_dining, ['diantar', 'selesai'].contains(status)),
                _buildStep("Sampai / Selesai", Icons.check_circle, ['selesai'].contains(status)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Note: Status akan diupdate oleh Admin setiap hari.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12))
        ],
      ),
    );
  }

  Widget _buildStep(String label, IconData icon, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: isActive ? const Color(0xFFFF6B6B) : Colors.grey[300], size: 32),
          const SizedBox(width: 15),
          Text(
            label, 
            style: TextStyle(
              fontSize: 16, 
              color: isActive ? Colors.black87 : Colors.grey, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal
            )
          )
        ],
      ),
    );
  }
}