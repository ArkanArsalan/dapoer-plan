import 'package:flutter/material.dart';
import 'dart:convert';

class ResultPage extends StatelessWidget {
  final dynamic data;

  ResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    String prettyJson = JsonEncoder.withIndent('  ').convert(data);

    return Scaffold(
      appBar: AppBar(title: Text('Hasil Deteksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Hasil Deteksi:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  prettyJson,
                  style: TextStyle(fontFamily: 'Courier', fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
