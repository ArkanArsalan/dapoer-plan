import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Delay 2 detik lalu navigate ke LoginPage
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Atur warna background sesuai tema
      body: Center(
        child: Image.asset(
          'assets/logo.png',  // Pastikan ini sesuai dengan pubspec.yaml
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
