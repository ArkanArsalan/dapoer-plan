import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';


class DetectionResult {
  final int classId;
  final double score;
  final Rect rect;
  String? className;

  DetectionResult({
    required this.classId,
    required this.score,
    required this.rect,
    this.className,
  });
}

List<String> _classLabels = [];

Future<void> loadLabels() async {
  if (_classLabels.isNotEmpty) {
    print("DEBUG: Labels sudah dimuat sebelumnya, skip.");
    return;
  }
  print("DEBUG: Memuat labels dari assets/labels.txt...");
  try {
    final String labelsData = await rootBundle.loadString('assets/labels.txt');
    _classLabels = labelsData
        .split('\n')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();
    print("DEBUG: Labels berhasil dimuat. Total kelas: ${_classLabels.length}.");
  } catch (e, stackTrace) {
    print("ERROR: Gagal memuat labels: $e");
    print("STACK: $stackTrace");
    _classLabels = [];
    throw Exception("Gagal memuat file labels.txt: $e");
  }
}

Future<List<DetectionResult>> detectObjectsFromImage(File imageFile) async {
  print("DEBUG: detectObjectsFromImage dipanggil.");
  await loadLabels();

  img.Image? image;
  try {
    print("DEBUG: Mendecode gambar dari file: ${imageFile.path}");
    final bytes = await imageFile.readAsBytes();
    image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception("Gagal mendecode gambar.");
    }
    print("DEBUG: Gambar berhasil didecode. Ukuran asli: ${image.width}x${image.height}");
  } catch (e, stackTrace) {
    print("ERROR: Gagal mendecode atau membaca file gambar: $e");
    print("STACK: $stackTrace");
    throw Exception("Gagal memproses gambar: $e");
  }

  print("DEBUG: Mengubah ukuran gambar ke 640x640.");
  final resized = img.copyResize(image!, width: 640, height: 640);
  print("DEBUG: Gambar berhasil diubah ukuran.");

  // --- KOREKSI KRUSIAL: Mempersiapkan input tensor dalam format BCHW ([1, 3, 640, 640]) ---
  print("DEBUG: Mempersiapkan input tensor (Float32List) dalam format BCHW [1, 3, 640, 640]...");
  final inputBytes = Float32List(1 * 3 * 640 * 640); // Ukuran total sama, urutan berbeda
  
  // Mengisi data piksel ke Float32List dalam urutan BCHW (Channels-first)
  // Loop melalui channels, lalu height, lalu width
  int pixelIndex = 0;
  for (int c = 0; c < 3; c++) { // Loop channels (0=R, 1=G, 2=B)
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        final pixel = resized.getPixel(x, y);
        if (c == 0) { // Red channel
          inputBytes[pixelIndex] = pixel.r / 255.0;
        } else if (c == 1) { // Green channel
          inputBytes[pixelIndex] = pixel.g / 255.0;
        } else { // Blue channel
          inputBytes[pixelIndex] = pixel.b / 255.0;
        }
        pixelIndex++;
      }
    }
  }
  final input = [inputBytes];
  print("DEBUG: Input tensor siap (format BCHW).");
  // --- AKHIR KOREKSI KRUSIAL ---

  Interpreter? interpreter;
  List<int> expectedShape = [1, 102, 8400];
  final int expectedTypeAsInt = 1; // 1 untuk float32

  try {
    print("DEBUG: Memuat model TFLite dari assets/model.tflite...");
    interpreter = await Interpreter.fromAsset('assets/model3.tflite');
    print("DEBUG: Model TFLite berhasil dimuat.");

    final outputTensor = interpreter.getOutputTensor(0);
    print("DEBUG: Model Output Tensor - Shape: ${outputTensor.shape}, Type: ${outputTensor.type}");
    print("DEBUG: Actual Output Tensor Type (index): ${outputTensor.type.index}");

    if (outputTensor.shape.length != 3 ||
        outputTensor.shape[0] != expectedShape[0] ||
        outputTensor.shape[1] != expectedShape[1] ||
        outputTensor.shape[2] != expectedShape[2]) {
      print("ERROR: Output tensor shape model tidak sesuai ekspektasi.");
      print("ERROR: Expected: $expectedShape, Actual: ${outputTensor.shape}");
      throw Exception("Output tensor shape model tidak cocok.");
    }

    if (outputTensor.type.index != expectedTypeAsInt) {
      print("ERROR: Output tensor type model tidak sesuai ekspektasi.");
      print("ERROR: Expected type (as int): $expectedTypeAsInt, Actual type (as int): ${outputTensor.type.index}");
      print("INFO: Actual TfLiteType object is: ${outputTensor.type}");
      throw Exception("Output tensor type model tidak cocok.");
    } else {
      print("DEBUG: Output tensor type model sesuai ekspektasi (berdasarkan integer index): ${outputTensor.type}");
    }
  } catch (e, stackTrace) {
    print("ERROR: Gagal memuat atau menginisialisasi Interpreter: $e");
    print("STACK: $stackTrace");
    throw Exception("Gagal memuat model.tflite: $e");
  }

  print("DEBUG: Mempersiapkan output tensor (Float32List)...");
  final outputBytes = Float32List(1 * 102 * 8400);
  final output = [outputBytes];
  print("DEBUG: Output tensor siap.");

  try {
    print("DEBUG: Menjalankan inference model...");
    interpreter!.run(input, output);
    print("DEBUG: Inference model selesai.");
  } catch (e, stackTrace) {
    print("ERROR: Gagal menjalankan inference model (interpreter.run): $e");
    print("STACK: $stackTrace");
    throw Exception("Gagal menjalankan prediksi model: $e");
  } finally {
    if (interpreter != null) {
      interpreter.close();
      print("DEBUG: Interpreter ditutup.");
    }
  }

  final List<DetectionResult> results = [];
  print("DEBUG: Memulai post-processing hasil deteksi...");

  const int NUM_DETECTIONS = 8400;
  const int NUM_ATTRIBUTES_PER_BOX = 102;
  const int BBOX_ATTRIBUTES = 4;
  const int OBJECTNESS_SCORE_IDX = 4;
  const int CLASS_SCORES_START_IDX = 5;
  final int NUM_CLASSES = NUM_ATTRIBUTES_PER_BOX - BBOX_ATTRIBUTES - 1;

  if (NUM_CLASSES != _classLabels.length) {
    print("WARNING: Jumlah kelas yang diharapkan ($NUM_CLASSES) tidak sesuai dengan jumlah label (${_classLabels.length}).");
  }

  double confidenceThreshold = 0.25;
  print("DEBUG: Ambang batas keyakinan (confidence threshold): $confidenceThreshold");

  for (int i = 0; i < NUM_DETECTIONS; i++) {
    double objectness = outputBytes[OBJECTNESS_SCORE_IDX * NUM_DETECTIONS + i];

    if (objectness > confidenceThreshold) {
      final x_center = outputBytes[0 * NUM_DETECTIONS + i];
      final y_center = outputBytes[1 * NUM_DETECTIONS + i];
      final width = outputBytes[2 * NUM_DETECTIONS + i];
      final height = outputBytes[3 * NUM_DETECTIONS + i];

      double maxScore = 0.0;
      int classId = -1;
      for (int j = 0; j < NUM_CLASSES; j++) {
        final score = outputBytes[(CLASS_SCORES_START_IDX + j) * NUM_DETECTIONS + i];
        if (score > maxScore) {
          maxScore = score;
          classId = j;
        }
      }

      double finalScore = objectness * maxScore;
      if (finalScore > confidenceThreshold) {
        final left = x_center - (width / 2);
        final top = y_center - (height / 2);

        String? className;
        if (classId != -1 && classId < _classLabels.length) {
          className = _classLabels[classId];
        } else {
          className = "Unknown Class ($classId)";
          print("WARNING: Class ID $classId out of bounds for labels length ${_classLabels.length}.");
        }

        results.add(DetectionResult(
          classId: classId,
          score: finalScore,
          rect: Rect.fromLTWH(left, top, width, height),
          className: className,
        ));
      }
    }
  }

  print("DEBUG: Post-processing selesai. Jumlah deteksi awal: ${results.length}");
  return results;
}