import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'home_page.dart';

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

  void _doLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
    // Dummy user untuk skip login
    final guest = User(id: '0', username: 'Guest', email: 'guest@example.com');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage(user: guest)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(
            controller: _emailC,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passC,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _doLogin, child: const Text('Login')),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _skipToHome,
            child: const Text('Skip to Home'),
          ),
        ]),
      ),
    );
  }
}
