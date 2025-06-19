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
  List<dynamic> _filteredRecipes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    setState(() => _loading = true);
    try {
      final data = await KatalogService.fetchRecipes(_currentPage, 5);
      setState(() {
        _recipes = data['data'] ?? [];
        _filteredRecipes = _recipes;
        _totalPages = data['pagination']?['totalPages'] ?? 1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _recipes = [];
        _filteredRecipes = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _filteredRecipes = _recipes);
      return;
    }

    final filtered = _recipes.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredRecipes = filtered;
    });
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
                    onChanged: _search,
                  ),
                ),
                Expanded(
                  child: _filteredRecipes.isEmpty
                      ? const Center(child: Text('Tidak ada resep ditemukan'))
                      : ListView.builder(
                          itemCount: _filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final item = _filteredRecipes[index];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                // Hilangkan leading gambar
                                title: Text(item['title'] ?? 'Tanpa Judul'),
                                subtitle: Text(
                                  (item['ingredients'] ?? 'Tidak ada bahan')
                                      .toString()
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
                                      builder: (_) =>
                                          KatalogDetailPage(recipe: item),
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
