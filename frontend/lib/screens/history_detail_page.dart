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
    // Implement save functionality if needed (e.g. API update)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur update belum tersedia')),
    );
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Konfirmasi Penghapusan'),
        content: const Text('Apakah Anda yakin ingin menghapus history ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
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
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save, color: Colors.green),
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: SingleChildScrollView(  // Make the body scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilkan prompt history yang terkait
              Text(
                'Ingredients Detection: ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                widget.historyItem['prompt'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ) ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Input field untuk resep
              const Text(
                'Resep: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _recipeController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Tulis resep di sini...',
                  hintStyle: const TextStyle(color: Colors.black45),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
