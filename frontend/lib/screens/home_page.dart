import 'package:flutter/material.dart';
import '../models/user.dart';
import 'camera_page.dart';
import 'generate_page.dart';
import 'history_page.dart';
import 'katalog_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Center(
        child: Text(
          'Welcome, ${widget.user.username}!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      const KatalogPage(),
      CameraPage(), // ini untuk FAB (tidak dipanggil lewat bottom nav)
      const GeneratePage(),
      const HistoryPage(),
    ]);
  }

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DapoerPlan',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.exit_to_app, color: Colors.green),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _pages[0], // Home
          _pages[1], // Katalog
          _pages[3], // Generate
          _pages[4], // History
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => _onTap(0),
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0 ? Colors.green : Colors.black,
              ),
              tooltip: 'Home',
            ),
            IconButton(
              onPressed: () => _onTap(1),
              icon: Icon(
                Icons.book,
                color: _currentIndex == 1 ? Colors.green : Colors.black,
              ),
              tooltip: 'Katalog',
            ),
            const SizedBox(width: 48), // space for FAB
            IconButton(
              onPressed: () => _onTap(2),
              icon: Icon(
                Icons.restaurant_menu,
                color: _currentIndex == 2 ? Colors.green : Colors.black,
              ),
              tooltip: 'Generate',
            ),
            IconButton(
              onPressed: () => _onTap(3),
              icon: Icon(
                Icons.history,
                color: _currentIndex == 3 ? Colors.green : Colors.black,
              ),
              tooltip: 'History',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CameraPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.camera_alt, color: Colors.white),
        tooltip: 'Scan / Deteksi',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
