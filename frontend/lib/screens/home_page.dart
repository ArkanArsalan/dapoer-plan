import 'package:flutter/material.dart';
import '../models/user.dart';
import 'camera_page.dart';
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

  final _pages = [
    Center(child: Text('Welcome, ${''}!')), // index 0 kosong
    // index 1 untuk camera_page
  ];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
    if (idx == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CameraPage()));
    }
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[0],
      appBar: AppBar(
        title: const Text('Homepage'),
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.exit_to_app))],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
        ],
      ),
    );
  }
}
