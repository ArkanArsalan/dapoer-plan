import 'package:flutter/material.dart';
import 'generate_result_page.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});
  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  void _generate() {
    final inputs = _controllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (inputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambahkan bahan terlebih dahulu')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GenerateResultPage(ingredients: inputs),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Resep')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: _controllers[i],
                      decoration: InputDecoration(
                        labelText: 'Bahan ${i + 1}',
                        suffixIcon: i == _controllers.length - 1
                            ? IconButton(icon: const Icon(Icons.add), onPressed: _addField)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(onPressed: _generate, child: const Text('Generate')),
          ],
        ),
      ),
    );
  }
}
