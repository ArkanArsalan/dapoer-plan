import 'package:flutter/material.dart';
import '../services/generate_service.dart';

class GenerateResultPage extends StatefulWidget {
  final List<String> ingredients;
  const GenerateResultPage({super.key, required this.ingredients});

  @override
  _GenerateResultPageState createState() => _GenerateResultPageState();
}

class _GenerateResultPageState extends State<GenerateResultPage> {
  String? result;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    GenerateService.generate(widget.ingredients).then((r) {
      setState(() { result = r; loading = false; });
    }).catchError((e) {
      setState(() { error = e.toString(); loading = false; });
    });
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('Hasil Generate')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(result!),
                ),
    );
  }
}
