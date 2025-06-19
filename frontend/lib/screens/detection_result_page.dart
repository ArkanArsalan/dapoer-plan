import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/detect_service.dart';
import '../services/generate_service.dart'; // Import the GenerateService
import '../services/history_service.dart';


class DetectionResultPage extends StatefulWidget {
  final File image;
  const DetectionResultPage({Key? key, required this.image}) : super(key: key);

  @override
  State<DetectionResultPage> createState() => _DetectionResultState();
}

class _DetectionResultState extends State<DetectionResultPage> {
  // Original state for detection
  List<String> _detectedIngredients = []; // Changed from String? to List<String>
  bool _loadingDetection = true; // Renamed for clarity
  String? _detectionError; // Renamed for clarity

  // New state for recipe generation
  String? _generatedRecipe;
  bool _generatingRecipe = false;
  String? _recipeError;

  @override
  void initState() {
    super.initState();
    _runDetect();
  }

  /// Runs the object detection service.
  /// Parses the detection result into a list of strings for ingredients.
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
        // Assuming 'result' can be a List<dynamic> or a String representation of a list
        List<String> parsedIngredients = [];
        if (res['result'] is List) {
          parsedIngredients = List<String>.from(res['result']);
        } else if (res['result'] is String) {
          // Attempt to parse string like "[item1, item2]" or "item1, item2"
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

 // ... bagian atas tetap sama

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
      appBar: AppBar(title: const Text('Detection Result')),
      body: _loadingDetection
          ? const Center(child: CircularProgressIndicator())
          : _buildResultUI(),
    );
  }

  /// Builds the UI to display detection results and the recipe generation option.
  Widget _buildResultUI() {
    if (_detectionError != null) {
      return Center(child: Text(_detectionError!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the detected image
          Center(
            child: Image.file(
              widget.image,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),

          // Display detected ingredients
          const Text(
            'Bahan-bahan Terdeteksi:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          _detectedIngredients.isEmpty
              ? const Text('Tidak ada bahan terdeteksi.', style: TextStyle(fontSize: 16))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _detectedIngredients
                .map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text('- $ingredient', style: const TextStyle(fontSize: 16)),
            ))
                .toList(),
          ),
          const SizedBox(height: 24),

          // Button to generate recipe
          Center(
            child: ElevatedButton.icon(
              onPressed: _generatingRecipe || _detectedIngredients.isEmpty
                  ? null // Disable button while generating or if no ingredients
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
            Text(
              _generatedRecipe!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}