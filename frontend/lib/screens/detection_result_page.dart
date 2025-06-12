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
  Map<String, dynamic>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _runDetect();
  }

  Future<void> _runDetect() async {
    final bytes = await widget.image.readAsBytes();
    final base64img = 'data:image/png;base64,${base64Encode(bytes)}';

    final r = await DetectService.detectThumbnail(base64img);

    setState(() {
      _result = r;
      _loading = false;
    });
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
    if (_result == null || _result!.containsKey('error')) {
      final err = _result?['error'] ?? 'Tidak ada hasil';
      return Center(child: Text('Error: $err'));
    }

    return Column(
      children: [
        Image.file(widget.image, height: 200),
        Expanded(
          child: ListView(
            children: _result!.entries.map((e) {
              final v = e.value;
              return ListTile(
                title: Text(e.key),
                trailing: v is num
                    ? Text('${(v * 100).toStringAsFixed(1)}%')
                    : Text(v.toString()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
