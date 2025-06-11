import 'package:flutter/material.dart';
import '../models/user.dart';
import 'camera_page.dart';
import 'generate_page.dart';
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

  // Daftar halaman untuk tiap tab
  late final List<Widget> _pages = [
    Center(child: Text('Welcome, ${widget.user.username}!')),
    CameraPage(),
    GeneratePage(),
  ];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dapoer Plan'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.exit_to_app)),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Generate'),
        ],
      ),
    );
  }
}
