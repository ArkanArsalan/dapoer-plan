import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true; // To toggle password visibility

  void _doLogin() async {
    setState(() { _loading = true; _error = null; });
    final resp = await AuthService.login(_emailC.text, _passC.text);
    setState(() => _loading = false);

    if (resp != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: resp.user)),
      );
    } else {
      setState(() => _error = 'Login gagal. Silakan cek email/password.');
    }
  }

  void _skipToHome() {
    final guest = User(id: '0', username: 'Guest', email: 'guest@example.com');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage(user: guest)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green, // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Text at the Top
            const Text(
              'DapoerPlan',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),

            // Email input field with icon
            TextField(
              controller: _emailC,
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: const Icon(Icons.email, color: Colors.green), // Email icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Password input field with icon and toggle visibility
            TextField(
              controller: _passC,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: const Icon(Icons.lock, color: Colors.green), // Lock icon
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; // Toggle password visibility
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 20),

            // Error message
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),

            // Login button styled with rounded corners
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _doLogin,
                    child: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
            const SizedBox(height: 12),

            // Skip to Home button
            TextButton(
              onPressed: _skipToHome,
              child: const Text(
                'Skip to Home',
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(height: 8),

            // Navigate to Register page
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: const Text(
                'Belum punya akun? Register',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
