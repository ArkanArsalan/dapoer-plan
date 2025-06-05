import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection_model.dart';
import '../utils/bounding_box_painter.dart'; // Pastikan ini ada
// import '../utils/image_utils.dart'; // Ini tidak lagi digunakan secara langsung, bisa dihapus jika tidak ada pemakaian lain

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  List<DetectionResult> _results = [];
  bool _isLoadingPrediction = false; // Tambahkan state loading

  @override
  void initState() {
    super.initState();
    print("DEBUG: HomeScreen initState dipanggil.");
    // Memuat label di awal, meskipun detectObjectsFromImage juga akan memuat jika kosong
    // Ini memastikan label siap lebih awal.
    loadLabels().then((_) {
      print("DEBUG: Labels dipastikan sudah dimuat di HomeScreen.");
    }).catchError((e) {
      print("ERROR: Gagal memuat labels di HomeScreen initState: $e");
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    print("DEBUG: _pickImage dipanggil dari sumber: $source");
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      final imageFile = File(picked.path);
      print("DEBUG: Gambar dipilih: ${imageFile.path}");

      setState(() {
        _image = imageFile;
        _results = []; // Bersihkan hasil sebelumnya
        _isLoadingPrediction = true; // Set loading state
      });

      try {
        print("DEBUG: Memulai deteksi objek...");
        final results = await detectObjectsFromImage(imageFile);
        print("DEBUG: Deteksi objek selesai. Jumlah hasil: ${results.length}");
        setState(() {
          _results = results;
        });
      } catch (e, stackTrace) {
        print("ERROR: Gagal mendeteksi objek: $e");
        print("STACK: $stackTrace");
        // Tampilkan pesan error di UI jika perlu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendeteksi objek: $e")),
        );
      } finally {
        setState(() {
          _isLoadingPrediction = false; // Reset loading state
        });
        print("DEBUG: _pickImage selesai.");
      }
    } else {
      print("DEBUG: Pemilihan gambar dibatalkan.");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: HomeScreen build dipanggil.");
    return Scaffold(
      appBar: AppBar(title: const Text("Deteksi Objek")),
      body: Column(
        children: [
          // Tampilkan loading indicator atau gambar kosong jika belum ada gambar
          if (_image != null)
            Expanded(
              child: Stack(
                children: [
                  Image.file(_image!),
                  if (_isLoadingPrediction)
                    const Center(
                      child: CircularProgressIndicator(), // Indikator loading saat prediksi
                    )
                  else // Tampilkan bounding box hanya jika tidak loading
                    CustomPaint(
                      painter: BoundingBoxPainter(_results),
                      child: Container(), // CustomPaint membutuhkan child
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 100, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("Pilih gambar untuk deteksi", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingPrediction ? null : () => _pickImage(ImageSource.camera), // Disable saat loading
                    icon: const Icon(Icons.camera),
                    label: const Text("Kamera"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingPrediction ? null : () => _pickImage(ImageSource.gallery), // Disable saat loading
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galeri"),
                  ),
                ),
              ],
            ),
          ),
          if (_results.isNotEmpty && !_isLoadingPrediction)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Jumlah deteksi: ${_results.length}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          if (_isLoadingPrediction)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Mendeteksi objek...", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }
}