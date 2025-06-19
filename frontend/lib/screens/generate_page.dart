import 'package:flutter/material.dart';
import 'generate_result_page.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});
  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  // Add new input field for ingredients
  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  // Generate the recipe with the provided ingredients
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title with instructions
            Text(
              'Masukkan Bahan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan bahan-bahan yang ada. Tekan "+" untuk menambah bahan.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Input fields for ingredients
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _controllers[i],
                      decoration: InputDecoration(
                        labelText: 'Bahan ${i + 1}',
                        labelStyle: TextStyle(color: Colors.green),
                        hintText: 'Contoh: Tomat, Ayam, Gula',
                        hintStyle: const TextStyle(color: Colors.black45),
                        suffixIcon: i == _controllers.length - 1
                            ? IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: _addField,
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Generate Button
            ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: const Text(
                'Generate Resep',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
