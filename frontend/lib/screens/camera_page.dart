import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'detection_result_page.dart';

class CameraPage extends StatefulWidget {
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initialize;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      _controller = CameraController(cameras.first, ResolutionPreset.medium);
      _initialize = _controller.initialize();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    await _initialize;
    XFile file = await _controller.takePicture();
    _goToResult(File(file.path));
  }

  Future<void> _select() async {
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) _goToResult(File(file.path));
  }

  void _goToResult(File file) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetectionResultPage(image: file)));
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: FutureBuilder(
        future: _initialize,
        builder: (_, snap) => snap.connectionState == ConnectionState.done
          ? Column(children: [
              Expanded(child: CameraPreview(_controller)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(onPressed: _select, icon: const Icon(Icons.photo)),
                FloatingActionButton(onPressed: _capture, child: const Icon(Icons.camera)),
              ]),
            ])
          : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
