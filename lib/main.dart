import 'package:flutter/material.dart';
import 'image_predict_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFLite Image Classifier',
      debugShowCheckedModeBanner: false,
      home: ImagePredictPage(),
    );
  }
}
