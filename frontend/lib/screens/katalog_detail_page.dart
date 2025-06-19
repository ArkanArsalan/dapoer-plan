import 'package:flutter/material.dart';

class KatalogDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const KatalogDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = (recipe['title'] as String?) ?? 'Tanpa Judul';
    final ingredients = (recipe['ingredients'] as String?) ?? 'Tidak ada bahan';
    final steps = (recipe['steps'] as String?) ?? 'Tidak ada langkah-langkah';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                ingredients.replaceAll('--', '\n'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                steps.replaceAll('--', '\n'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
