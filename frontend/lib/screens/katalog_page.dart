import 'package:flutter/material.dart';
import '../services/katalog_service.dart';
import 'katalog_detail_page.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  int _currentPage = 1;
  int _totalPages = 1;
  List<dynamic> _recipes = [];
  bool _loading = true;
  String _keyword = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    setState(() => _loading = true);
    try {
      final data = await KatalogService.fetchRecipes(_currentPage, 15, keyword: _keyword);
      setState(() {
        _recipes = data['data'] ?? [];
        _totalPages = data['pagination']?['totalPages'] ?? 1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _recipes = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  void _search(String query) {
    setState(() {
      _keyword = query;
      _currentPage = 1;
    });
    _fetchRecipes();
  }

  void _changePage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() => _currentPage = page);
    _fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Resep')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari resep...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      ),
                    ),
                    onSubmitted: _search,
                  ),
                ),
                Expanded(
                  child: _recipes.isEmpty
                      ? const Center(child: Text('Tidak ada resep ditemukan'))
                      : ListView.builder(
                          itemCount: _recipes.length,
                          itemBuilder: (context, index) {
                            final item = _recipes[index];
                            final title = (item['title'] as String?) ?? 'Tanpa Judul';
                            final ingredients = (item['ingredients'] as String?) ?? 'Tidak ada bahan';

                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(title),
                                subtitle: Text(
                                  ingredients
                                      .split('--')
                                      .take(2)
                                      .join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => KatalogDetailPage(recipe: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1
                            ? () => _changePage(_currentPage - 1)
                            : null,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text('Page $_currentPage / $_totalPages'),
                      IconButton(
                        onPressed: _currentPage < _totalPages
                            ? () => _changePage(_currentPage + 1)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
