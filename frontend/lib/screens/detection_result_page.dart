import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/detect_service.dart';
import '../services/generate_service.dart';
import '../services/history_service.dart';

class DetectionResultPage extends StatefulWidget {
  final File image;
  const DetectionResultPage({Key? key, required this.image}) : super(key: key);

  @override
  State<DetectionResultPage> createState() => _DetectionResultState();
}

class _DetectionResultState extends State<DetectionResultPage> {
  List<String> _detectedIngredients = [];
  bool _loadingDetection = true;
  String? _detectionError;
  String? _generatedRecipe;
  bool _generatingRecipe = false;
  String? _recipeError;

  @override
  void initState() {
    super.initState();
    _runDetect();
  }

  Future<void> _runDetect() async {
    try {
      final bytes = await widget.image.readAsBytes();
      final base64img = 'data:image/png;base64,${base64Encode(bytes)}';
      final res = await DetectService.detectThumbnail(base64img);

      if (res.containsKey('error')) {
        setState(() {
          _detectionError = res['error'];
          _loadingDetection = false;
        });
      } else if (res.containsKey('result')) {
        List<String> parsedIngredients = [];
        if (res['result'] is List) {
          parsedIngredients = List<String>.from(res['result']);
        } else if (res['result'] is String) {
          String resultString = res['result'].toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .trim();
          parsedIngredients = resultString.split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else {
          _detectionError = 'Format hasil deteksi tidak terduga.';
        }

        setState(() {
          _detectedIngredients = parsedIngredients;
          _loadingDetection = false;
        });
      } else {
        setState(() {
          _detectionError = 'Respons tak terduga dari server';
          _loadingDetection = false;
        });
      }
    } catch (e) {
      setState(() {
        _detectionError = 'Error: $e';
        _loadingDetection = false;
      });
    }
  }

  Future<void> _generateRecipe() async {
    if (_detectedIngredients.isEmpty) {
      setState(() {
        _recipeError = 'Tidak ada bahan terdeteksi untuk membuat resep.';
      });
      return;
    }

    setState(() {
      _generatingRecipe = true;
      _recipeError = null;
      _generatedRecipe = null;
    });

    try {
      final recipe = await GenerateService.generate(_detectedIngredients);
      setState(() {
        _generatedRecipe = recipe;
      });

      await HistoryService.addHistory(_detectedIngredients.join(', '), recipe);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil disimpan ke history')),
        );
      }
    } catch (e) {
      setState(() {
        _recipeError = 'Gagal membuat resep: $e';
      });
    } finally {
      setState(() {
        _generatingRecipe = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Deteksi Resep')),
      body: _loadingDetection
          ? const Center(child: CircularProgressIndicator())
          : _buildResultUI(),
    );
  }

  Widget _buildResultUI() {
    if (_detectionError != null) {
      return Center(child: Text(_detectionError!, style: TextStyle(color: Colors.red, fontSize: 18)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the detected image with shadow
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 6),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.image,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Display detected ingredients with better layout
          const Text(
            'Bahan-bahan Terdeteksi:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          _detectedIngredients.isEmpty
              ? const Text('Tidak ada bahan terdeteksi.', style: TextStyle(fontSize: 16))
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _detectedIngredients
                      .map((ingredient) => Chip(
                            label: Text(ingredient, style: const TextStyle(fontSize: 14)),
                            backgroundColor: Colors.green.shade100,
                          ))
                      .toList(),
                ),
          const SizedBox(height: 24),

          // Button to generate recipe
          Center(
            child: ElevatedButton.icon(
              onPressed: _generatingRecipe || _detectedIngredients.isEmpty
                  ? null
                  : _generateRecipe,
              icon: _generatingRecipe
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.menu_book),
              label: Text(_generatingRecipe ? 'Membuat Resep...' : 'Buat Resep'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Display generated recipe or error
          if (_recipeError != null)
            Text(
              _recipeError!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          if (_generatedRecipe != null) ...[
            const Text(
              'Resep yang Dihasilkan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Format the recipe with line breaks and headers
            _formatRecipe(_generatedRecipe!),
          ],
        ],
      ),
    );
  }

  Widget _formatRecipe(String recipe) {
    final RegExp regExp = RegExp(r'(#+)\s*(.*)');
    final lines = recipe.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final match = regExp.firstMatch(line);
        if (match != null) {
          final level = match.group(1)!.length;
          final text = match.group(2)!;
          if (level == 1) {
            return Text(
              text.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            );
          } else if (level == 2) {
            return Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            );
          } else if (level == 3) {
            return Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            );
          } else {
            return Text(text, style: const TextStyle(fontSize: 16));
          }
        } else {
          return Text(line, style: const TextStyle(fontSize: 16));
        }
      }).toList(),
    );
  }
}
