import 'dart:io';
import 'package:flutter/material.dart';
import '../services/detect_service.dart';

class DetectionResultPage extends StatefulWidget {
  final File image;
  const DetectionResultPage({super.key, required this.image});

  @override
  State<DetectionResultPage> createState() => _DetectionResultState();
}

class _DetectionResultState extends State<DetectionResultPage> {
  Map<String, dynamic>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DetectService.detect(widget.image).then((r) {
      setState(() {
        _result = r;
        _loading = false;
      });
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
    if (_result == null || _result!.isEmpty) {
      return const Center(child: Text('No result or response empty'));
    }
    if (_result!.containsKey('error')) {
      return Center(child: Text('Error: ${_result!['error']}'));
    }
    return Column(
      children: [
        Image.file(widget.image, height: 200),
        Expanded(
          child: ListView(
            children: _result!.entries.map((e) {
              final v = e.value;
              if (v is num) {
                return ListTile(
                  title: Text(e.key),
                  trailing: Text('${(v * 100).toStringAsFixed(1)}%'),
                );
              }
              return ListTile(title: Text(e.key), subtitle: Text(v.toString()));
            }).toList(),
          ),
        ),
      ],
    );
  }
}
