import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math'; // Untuk fungsi min/max di NMS

class ImagePredictPage extends StatefulWidget {
  @override
  _ImagePredictPageState createState() => _ImagePredictPageState();
}

class _ImagePredictPageState extends State<ImagePredictPage> {
  final picker = ImagePicker();
  File? _image;
  String _result = 'Belum ada prediksi.';
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;
  bool _isLoading = false;

  // Bounding box for drawing
  Rect? _boundingBox;
  String? _detectedLabel;
  double? _detectedScore;

  // Model parameters (Based on your YOLOv8 export to TFLite)
  final int _inputImageSize = 640;
  final int _outputNumBoxes = 8400; // Number of detection proposals
  final int _numAttributesPerBox = 102;
  final int _numClassScores = 97; // This should match _labels.length

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print("DEBUG: ✅ Model loaded successfully!");

      // Log input/output tensor details to confirm expectations
      print("DEBUG: Input tensor shape: ${_interpreter.getInputTensor(0).shape}");
      print("DEBUG: Input tensor type: ${_interpreter.getInputTensor(0).type}");
      print("DEBUG: Output tensor shape: ${_interpreter.getOutputTensor(0).shape}");
      print("DEBUG: Output tensor type: ${_interpreter.getOutputTensor(0).type}");

      final labelData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      // Check if numClassScores matches labels length
      if (_labels.length != _numClassScores) {
        print("WARNING: Label count (${_labels.length}) does not match expected class score count (${_numClassScores}). "
            "Please check your labels.txt file and model configuration.");
      } else {
        print("DEBUG: Labels loaded. Total classes: ${_labels.length}");
      }

      setState(() {
        _isModelLoaded = true;
      });
    } catch (e, stackTrace) {
      setState(() {
        _result = "Gagal memuat model/label: $e";
        _isModelLoaded = false;
      });
      print("ERROR: Failed to load model or labels: $e");
      print("STACK: $stackTrace");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_isModelLoaded) {
      setState(() {
        _result = 'Model belum siap, mohon tunggu.';
      });
      return;
    }

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = 'Memproses gambar...';
        _boundingBox = null;
        _detectedLabel = null;
        _detectedScore = null;
        _isLoading = true;
      });

      await _predict(_image!);

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    print("DEBUG: Starting image preprocessing...");
    final bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes); // Decodes to RGB
    if (image == null) {
      print("ERROR: Failed to decode image from bytes.");
      throw Exception("Gagal decode gambar");
    }

    // Resize image to model's expected input size
    img.Image resized = img.copyResize(image, width: _inputImageSize, height: _inputImageSize);
    print("DEBUG: Image resized to ${_inputImageSize}x${_inputImageSize}.");

    // Initialize input tensor for the model [1, 640, 640, 3]
    List<List<List<List<double>>>> input = List.generate(
      1, // Batch size
      (_) => List.generate(
        _inputImageSize, // Height
        (_) => List.generate(
          _inputImageSize, // Width
          (_) => List.filled(3, 0.0), // Channels (RGB)
        ),
      ),
    );

    for (int y = 0; y < _inputImageSize; y++) {
      for (int x = 0; x < _inputImageSize; x++) {
        final pixel = resized.getPixel(x, y);
        // Normalize pixel values from [0, 255] to [0, 1]
        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }
    print("DEBUG: Image preprocessing complete. Normalized to [0, 1] RGB.");
    return input;
  }

  Future<void> _predict(File imageFile) async {
    print("DEBUG: Starting prediction process...");
    setState(() {
      _result = 'Memproses prediksi...';
      _boundingBox = null;
      _detectedLabel = null;
      _detectedScore = null;
    });

    try {
      var input = _preprocessImage(imageFile);

      // Initialize raw output buffer based on model's expected output shape
      var rawOutput = List.generate(
        1, // Batch size
        (_) => List.generate(
          _numAttributesPerBox, // 102 attributes per box
          (_) => List.filled(_outputNumBoxes, 0.0), // 8400 boxes
        ),
      );

      print("DEBUG: Running interpreter with input and rawOutput buffer.");
      _interpreter.run(input, rawOutput);
      print("DEBUG: Interpreter finished. Raw output shape: ${rawOutput.length}x${rawOutput[0].length}x${rawOutput[0][0].length}");

      // Transpose raw output from [1, attributes, boxes] to [boxes, attributes]
      List<List<double>> outputTransposed = List.generate(
        _outputNumBoxes, // 8400 boxes
        (i) => List.generate(_numAttributesPerBox, (j) => rawOutput[0][j][i]), // 102 attributes
      );
      print("DEBUG: Output transposed to ${_outputNumBoxes}x${_numAttributesPerBox}.");

      List<Map<String, dynamic>> detections = [];
      double confidenceThreshold = 0.25;
      print("DEBUG: Using confidence threshold: $confidenceThreshold");

      for (int i = 0; i < _outputNumBoxes; i++) {
        if (outputTransposed[i].length < 5) {
          continue;
        }

        double objectness = outputTransposed[i][4]; // Objectness score

        if (objectness > confidenceThreshold) {
          if (outputTransposed[i].length < 5 + _numClassScores) {
            print("WARNING: Box $i objectness OK, but not enough class scores. Expected 5+${_numClassScores} attributes, got ${outputTransposed[i].length}. Skipping.");
            continue;
          }

          List<double> classScores = outputTransposed[i].sublist(5, 5 + _numClassScores); // Get class scores
          double maxClassScore = 0.0;
          int classIndex = -1;

          if (classScores.isNotEmpty) {
            maxClassScore = classScores.reduce((a, b) => a > b ? a : b);
            classIndex = classScores.indexOf(maxClassScore);
          } else {
            print("WARNING: Box $i has no class scores, skipping.");
            continue;
          }

          double finalScore = objectness * maxClassScore; // Combine objectness and class score

          if (finalScore > confidenceThreshold) {
            double cx = outputTransposed[i][0];
            double cy = outputTransposed[i][1];
            double w = outputTransposed[i][2];
            double h = outputTransposed[i][3];

            detections.add({
              'bbox': [cx, cy, w, h], // Raw bbox from model
              'objectness': objectness,
              'classIndex': classIndex,
              'score': finalScore, // Combined score
            });
          }
        }
      }

      print("DEBUG: Initial detections found (before NMS): ${detections.length}");

      detections.sort((a, b) => b['score'].compareTo(a['score'])); // Sort by score descending

      List<Map<String, dynamic>> nmsDetections = [];
      double nmsIouThreshold = 0.45;

      while (detections.isNotEmpty) {
        Map<String, dynamic> best = detections.removeAt(0); // Take the best detection
        nmsDetections.add(best);

        detections.removeWhere((other) {
          double iou = _calculateIoU(best['bbox'], other['bbox']);
          return iou > nmsIouThreshold;
        });
      }
      print("DEBUG: Detections after NMS: ${nmsDetections.length}");

      if (nmsDetections.isNotEmpty) {
        var best = nmsDetections.reduce((a, b) => a['score'] > b['score'] ? a : b);

        String label = _labels[best['classIndex']];
        double score = best['score'] * 100;

        double cx = best['bbox'][0];
        double cy = best['bbox'][1];
        double w = best['bbox'][2];
        double h = best['bbox'][3];

        double left = (cx - w / 2) / _inputImageSize;
        double top = (cy - h / 2) / _inputImageSize;
        double width = w / _inputImageSize;
        double height = h / _inputImageSize;

        left = left.clamp(0.0, 1.0);
        top = top.clamp(0.0, 1.0);
        width = width.clamp(0.0, 1.0 - left);
        height = height.clamp(0.0, 1.0 - top);

        setState(() {
          _result = 'Deteksi: $label (${score.toStringAsFixed(2)}%)';
          _boundingBox = Rect.fromLTWH(left, top, width, height);
          _detectedLabel = label;
          _detectedScore = score;
        });
        print("DEBUG: Final detection result: Label: $label, Score: ${score.toStringAsFixed(2)}%, Bbox: $_boundingBox");
      } else {
        setState(() {
          _result = 'Tidak ada objek terdeteksi dengan ambang batas ${confidenceThreshold.toStringAsFixed(2)}.';
          _boundingBox = null;
          _detectedLabel = null;
          _detectedScore = null;
        });
        print("DEBUG: No objects detected after NMS.");
      }
    } catch (e, stackTrace) {
      setState(() {
        _result = 'Gagal prediksi: $e';
        _boundingBox = null;
        _detectedLabel = null;
        _detectedScore = null;
      });
      print("ERROR: Prediction failed: $e");
      print("STACK: $stackTrace");
    } finally {
      setState(() {
        _isLoading = false; // Ensure loading state is reset
      });
      print("DEBUG: Prediction process finished.");
    }
  }

  double _calculateIoU(List<double> box1, List<double> box2) {
    double box1_x1 = box1[0] - box1[2] / 2;
    double box1_y1 = box1[1] - box1[3] / 2;
    double box1_x2 = box1[0] + box1[2] / 2;
    double box1_y2 = box1[1] + box1[3] / 2;

    double box2_x1 = box2[0] - box2[2] / 2;
    double box2_y1 = box2[1] - box2[3] / 2;
    double box2_x2 = box2[0] + box2[2] / 2;
    double box2_y2 = box2[1] + box2[3] / 2;

    double xA = max(box1_x1, box2_x1);
    double yA = max(box1_y1, box2_y1);
    double xB = min(box1_x2, box2_x2);
    double yB = min(box1_y2, box2_y2);

    double interArea = max(0.0, xB - xA) * max(0.0, yB - yA);

    double box1Area = (box1_x2 - box1_x1) * (box1_y2 - box1_y1);
    double box2Area = (box2_x2 - box2_x1) * (box2_y2 - box2_y1);

    double iou = interArea / (box1Area + box2Area - interArea);
    return iou;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deteksi Objek YOLO TFLite')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_image!, fit: BoxFit.cover),
                            if (_boundingBox != null && _detectedLabel != null && _detectedScore != null)
                              Positioned(
                                left: _boundingBox!.left * constraints.maxWidth,
                                top: _boundingBox!.top * constraints.maxHeight,
                                width: _boundingBox!.width * constraints.maxWidth,
                                height: _boundingBox!.height * constraints.maxHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 2),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: FittedBox(
                                      child: Container(
                                        color: Colors.red,
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        child: Text(
                                          '${_detectedLabel!} (${_detectedScore!.toStringAsFixed(1)}%)',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.image, size: 100, color: Colors.grey[400])),
                  ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Text(
                    _result,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera),
              label: Text("Ambil dari Kamera"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text("Pilih dari Galeri"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),
          ],
        ),
      ),
    );
  }
}
