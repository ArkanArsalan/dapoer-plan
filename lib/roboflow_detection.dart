import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RoboflowPage extends StatefulWidget {
  @override
  _RoboflowPageState createState() => _RoboflowPageState();
}

class _RoboflowPageState extends State<RoboflowPage> {
  File? _image;
  String _result = "";
  bool _loading = false;

  final String roboflowModel = "ppb_usefulonly";
  final int roboflowVersion = 3;
  final String apiKey = "If8oHI8MB7BvDGtH4Efm";

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _result = "";
      });

      await _uploadImageToRoboflow(imageFile);
    }
  }

  Future<void> _uploadImageToRoboflow(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://detect.roboflow.com/$roboflowModel/$roboflowVersion?api_key=$apiKey',
      ),
    );

    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    setState(() {
      _loading = true;
    });

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          _result = responseBody;
        });
      } else {
        setState(() {
          _result = "Gagal (${response.statusCode}): $responseBody";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Terjadi error: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Deteksi Roboflow")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 200),
            if (_loading)
              CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _result,
                  textAlign: TextAlign.center,
                ),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("Kamera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.image),
                  label: Text("Galeri"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
