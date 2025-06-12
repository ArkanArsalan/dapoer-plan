import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/detect_service.dart';

class DetectionResultPage extends StatefulWidget {
  final File image;
  const DetectionResultPage({Key? key, required this.image}) : super(key: key);

  @override
  State<DetectionResultPage> createState() => _DetectionResultState();
}

class _DetectionResultState extends State<DetectionResultPage> {
  String? _resultText;
  bool _loading = true;
  String? _error;

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
          _error = res['error'];
          _loading = false;
        });
      } else if (res.containsKey('result')) {
        setState(() {
          _resultText = res['result']?.toString();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Respons tak terduga dari server';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildResultUI(),
    );
  }

  Widget _buildResultUI() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Image.file(widget.image, height: 200),
          const SizedBox(height: 16),
          const Text(
            'Detected Ingredients:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _resultText ?? 'No result',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
