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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: 'Cari resep...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        ),
                      ),
                      onSubmitted: _search,
                    ),
                  ),
                ),
                // Recipes List
                Expanded(
                  child: _recipes.isEmpty
                      ? const Center(child: Text('Tidak ada resep ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
                      : ListView.builder(
                          itemCount: _recipes.length,
                          itemBuilder: (context, index) {
                            final item = _recipes[index];
                            final title = item['title'] ?? 'Tanpa Judul';
                            final ingredients = (item['ingredients'] as String?)?.split('--').take(2).join(', ') ?? 'Tidak ada bahan';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                subtitle: Text(
                                  ingredients,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
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
                // Pagination Controls
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
                        icon: const Icon(Icons.arrow_back, color: Colors.green),
                      ),
                      Text(
                        'Page $_currentPage / $_totalPages',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
                        icon: const Icon(Icons.arrow_forward, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
