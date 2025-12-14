import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List _lunchMenus = [];
  List _dinnerMenus = [];
  bool _isLoading = true;

  // ⚠️ GANTI IP: 10.0.2.2 (Emulator) atau 192.168.x.x (HP Fisik)
  final String apiUrl = "http://10.0.2.2/ontray-web/public/api/menus";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWeeklyMenus();
  }

  // Ambil Data dari Laravel
  Future<void> _fetchWeeklyMenus() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _lunchMenus = data.where((m) => m['jenis_waktu'] == 'lunch').toList();
          _dinnerMenus = data.where((m) => m['jenis_waktu'] == 'dinner').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Jadwal Minggu Ini", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            )
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B6B), // Warna Coral
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "LUNCH (Siang)"),
            Tab(text: "DINNER (Malam)"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMenuList(_lunchMenus),
                _buildMenuList(_dinnerMenus),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderScreen()));
        },
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.card_membership, color: Colors.white),
        label: const Text("Langganan Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMenuList(List menus) {
    if (menus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("Jadwal menu belum tersedia.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final item = menus[index];
        final date = DateTime.parse(item['tanggal']);
        final bool isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KOLOM TANGGAL (KIRI)
            Container(
              width: 65,
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: isToday ? const Color(0xFFFF6B6B) : const Color(0xFF3B82F6)
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'id_ID').format(date).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    DateFormat('EEE', 'id_ID').format(date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                      child: const Text("Hari Ini", style: TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
            
            // KARTU MAKANAN (KANAN)
            Expanded(
              child: Card(
                elevation: 0, // Flat design
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        item['gambar'],
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(
                          height: 130,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_makanan'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['deskripsi'],
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}