import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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

  // bounding box
  Rect? _boundingBox;

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      // ✅ Tambahkan log info tensor input/output
      print("✅ Model loaded!");
      print("Input tensor shape: ${_interpreter.getInputTensor(0).shape}");
      print("Input tensor type: ${_interpreter.getInputTensor(0).type}");
      print("Output tensor shape: ${_interpreter.getOutputTensor(0).shape}");
      print("Output tensor type: ${_interpreter.getOutputTensor(0).type}");


      final labelData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      setState(() {
        _result = "Gagal memuat model/label: $e";
      });
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
        _result = 'Memproses...';
        _boundingBox = null;
        _isLoading = true;
      });

      await _predict(_image!);

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Gagal decode gambar");

    img.Image resized = img.copyResize(image, width: 640, height: 640);

    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        640,
        (_) => List.generate(
          640,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = pixel.b / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.r / 255.0;

      }
    }


    return input;
  }

  Future<void> _predict(File imageFile) async {
    try {
      var input = _preprocessImage(imageFile);

      // Output harus sesuai dengan bentuk model: [1, 102, 8400]
      var output = List.generate(
        1,
        (_) => List.generate(
          102,
          (_) => List.filled(8400, 0.0),
        ),
      );

      // Jalankan inference
      _interpreter.run(input, output);

      // Fungsi untuk transpose output ke bentuk [8400][102]
      List<List<double>> transposeOutput(List<List<List<double>>> output) {
        List<List<double>> transposed = List.generate(
          8400,
          (_) => List.filled(102, 0.0),
        );

        for (int i = 0; i < 102; i++) {
          for (int j = 0; j < 8400; j++) {
            transposed[j][i] = output[0][i][j];
          }
        }
        return transposed;
      }

      // Transpose output supaya lebih mudah diproses per deteksi
      var outputTransposed = transposeOutput(output);

      // Contoh debug, ambil confidence (index 4) dari 20 deteksi pertama
      print("Output sample confidence (index 4): ${outputTransposed.take(20).map((e) => e[4]).toList()}");

      List<Map<String, dynamic>> detections = [];
      double confidenceThreshold = 0.01;

      for (int i = 0; i < 8400; i++) {
        double confidence = outputTransposed[i][4]; // objectness score

        if (confidence > confidenceThreshold) {
          // Ambil class scores mulai index 5 sampai 101 (total 97 class)
          List<double> classScores = outputTransposed[i].sublist(5, 102);

          double maxScore = classScores.reduce((a, b) => a > b ? a : b);
          int classIndex = classScores.indexOf(maxScore);

          double finalScore = confidence * maxScore;

          if (finalScore > confidenceThreshold) {
            double cx = outputTransposed[i][0];
            double cy = outputTransposed[i][1];
            double w = outputTransposed[i][2];
            double h = outputTransposed[i][3];

            detections.add({
              'bbox': [cx, cy, w, h],
              'confidence': confidence,
              'classIndex': classIndex,
              'score': finalScore,
            });
          }
        }
      }

      print("Detections count: ${detections.length}");

      if (detections.isNotEmpty) {
        var best = detections.reduce((a, b) => a['score'] > b['score'] ? a : b);
        String label = _labels[best['classIndex']];
        double score = best['score'] * 100;

        double cx = best['bbox'][0];
        double cy = best['bbox'][1];
        double w = best['bbox'][2];
        double h = best['bbox'][3];

        // Konversi bounding box dari piksel ke proporsi (0..1)
        double left = (cx - w / 2) / 640;
        double top = (cy - h / 2) / 640;
        double width = w / 640;
        double height = h / 640;

        setState(() {
          _result = 'Deteksi: $label (${score.toStringAsFixed(2)}%)';
          _boundingBox = Rect.fromLTWH(left, top, width, height);
        });
      } else {
        setState(() {
          _result = 'Tidak ada objek terdeteksi.';
          _boundingBox = null;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Gagal prediksi: $e';
        _boundingBox = null;
      });
    }
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_image!, fit: BoxFit.cover),
                        if (_boundingBox != null)
                          Positioned(
                            left: _boundingBox!.left * MediaQuery.of(context).size.width,
                            top: _boundingBox!.top * MediaQuery.of(context).size.width,
                            width: _boundingBox!.width * MediaQuery.of(context).size.width,
                            height: _boundingBox!.height * MediaQuery.of(context).size.width,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(height: 200, child: Icon(Icons.image, size: 100)),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Text(_result, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera),
              label: Text("Ambil dari Kamera"),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text("Pilih dari Galeri"),
            ),
          ],
        ),
      ),
    );
  }
}
