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
    setState(() {
      _loading = true;
      _error = null;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Terjadi kesalahan: $_error',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _history.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada history.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              leading: Icon(Icons.history,
                                  color: Colors.green[700], size: 28),
                              title: Text(
                                item['prompt'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                item['recipe'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.green[700]),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => HistoryDetailPage(
                                    historyItem: item,
                                    onUpdate: _loadHistory,
                                  ),
                                ));
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
