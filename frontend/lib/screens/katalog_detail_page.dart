import 'package:flutter/material.dart';

class KatalogDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const KatalogDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['title'] ?? 'Detail Resep')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe['title'] ?? 'Tanpa Judul',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                (recipe['ingredients'] ?? 'Tidak ada bahan')
                    .toString()
                    .replaceAll('--', '\n'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                (recipe['steps'] ?? 'Tidak ada langkah-langkah')
                    .toString()
                    .replaceAll('--', '\n'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
