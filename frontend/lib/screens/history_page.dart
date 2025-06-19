import 'package:flutter/material.dart';
import '../services/history_service.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; });
    try {
      final data = await HistoryService.fetchHistory();
      setState(() {
        _history = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_history.isEmpty) {
      return const Center(child: Text('Belum ada history.'));
    }

    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(item['prompt']),
            subtitle: Text(
              item['recipe'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HistoryDetailPage(historyItem: item, onUpdate: _loadHistory),
              ));
            },
          ),
        );
      },
    );
  }
}
