import 'dart:io';
import 'package:flutter/material.dart';
import 'models/detection_model.dart'; // Corrected import
import 'utils/bounding_box_painter.dart';

class ImagePredictPage extends StatefulWidget {
  final File imageFile;
  const ImagePredictPage({required this.imageFile});

  @override
  State<ImagePredictPage> createState() => _ImagePredictPageState();
}

class _ImagePredictPageState extends State<ImagePredictPage> {
  // Use the function directly, or if you want an object, it should be a class
  // that encapsulates the model loading and prediction, not a data model.
  List<DetectionResult> _boxes = []; // Changed to store DetectionResult objects

  @override
  void initState() {
    super.initState();
    initModel();
  }

  Future<void> initModel() async {
    // Call the global function to detect objects
    final results = await detectObjectsFromImage(widget.imageFile);
    setState(() {
      _boxes = results; // Store the actual detection results
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hasil Deteksi")),
      body: Stack(
        children: [
          Image.file(widget.imageFile),
          Positioned.fill(
            child: CustomPaint(
              painter: BoundingBoxPainter(_boxes), // Pass DetectionResult list
            ),
          )
        ],
      ),
    );
  }
}