import 'dart:io';
import 'dart:typed_data';
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

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      // Baca file labels dari assets (gunakan rootBundle, bukan File langsung)
      final labelData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      setState(() {});
    } catch (e) {
      print("Gagal memuat model/label: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = 'Memproses...';
      });
      _predict(_image!);
    }
  }

  /// Fungsi untuk resize dan normalisasi gambar menjadi input tensor 4D Float32
  /// Input model diasumsikan ukuran 224x224 dan normalisasi ke 0..1
  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    // Load gambar dari file
    final bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) throw Exception("Gagal decode gambar");

    // Resize ke 224x224
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // Buat tensor input 1x224x224x3 dengan normalisasi (0..1)
    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        var pixel = resized.getPixel(x, y);
        // Ambil RGB dari pixel, normalisasi ke 0..1
        input[0][y][x][0] = (img.getRed(pixel)) / 255.0;
        input[0][y][x][1] = (img.getGreen(pixel)) / 255.0;
        input[0][y][x][2] = (img.getBlue(pixel)) / 255.0;
      }
    }

    return input;
  }

  Future<void> _predict(File imageFile) async {
    try {
      // Preprocess gambar jadi input tensor
      var input = _preprocessImage(imageFile);

      // Buat output buffer untuk hasil prediksi (ukuran sesuai output model)
      // Asumsi output model 1 x N labels dengan tipe float32
      var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      // Run model
      _interpreter.run(input, output);

      // Ambil prediksi tertinggi
      List<double> scores = List<double>.from(output[0]);
      int maxIndex = 0;
      double maxScore = scores[0];
      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      setState(() {
        _result = 'Prediksi: ${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(2)}%)';
      });
    } catch (e) {
      setState(() {
        _result = 'Gagal prediksi: $e';
      });
      print('Error saat prediksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Klasifikasi Gambar TFLite')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Container(height: 200, child: Icon(Icons.image, size: 100)),
            SizedBox(height: 16),
            Text(_result, style: TextStyle(fontSize: 18)),
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

extension ListReshape<T> on List<T> {
  List<List<T>> reshape(List<int> dims) {
    if (dims.length != 2) throw Exception("Reshape hanya untuk 2 dimensi");

    int rows = dims[0];
    int cols = dims[1];

    if (rows * cols != this.length) throw Exception("Ukuran reshape tidak cocok");

    List<List<T>> reshaped = [];

    for (int i = 0; i < rows; i++) {
      reshaped.add(this.sublist(i * cols, i * cols + cols));
    }
    return reshaped;
  }
}
