
import 'package:flutter/material.dart';
import '../services/generate_service.dart';
import '../services/history_service.dart';

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
    _generateAndSave();
  }

  Future<void> _generateAndSave() async {
    try {
      final r = await GenerateService.generate(widget.ingredients);
      setState(() {
        result = r;
        loading = false;
      });
      await HistoryService.addHistory(widget.ingredients.join(', '), r);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil disimpan ke history')),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Generate')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(result ?? ''),
                ),
    );
  }
}
