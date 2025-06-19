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
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          'Recipe Detail',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),

              // Ingredients Section
              const Text(
                'Ingredients:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ingredients.replaceAll('--', '\n'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Steps Section
              const Text(
                'Steps:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                steps.replaceAll('--', '\n'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
