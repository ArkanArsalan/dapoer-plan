// D:\PPB\PPB Final\dapoer-plan\frontend\lib\screens\history_detail_page.dart
import 'package:flutter/material.dart';
import '../services/history_service.dart';

class HistoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> historyItem;
  final VoidCallback onUpdate;

  const HistoryDetailPage({super.key, required this.historyItem, required this.onUpdate});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late TextEditingController _recipeController;

  @override
  void initState() {
    super.initState();
    _recipeController = TextEditingController(text: widget.historyItem['recipe']);
  }

  void _save() {
    // TODO: Implement update if backend supports it
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum didukung update')));
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus history ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.deleteHistory(widget.historyItem['_id']);
      widget.onUpdate();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail History'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _recipeController,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Resep',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
