import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/history_service.dart';
import '../services/katalog_service.dart';
import 'camera_page.dart';
import 'generate_page.dart';
import 'history_page.dart';
import 'katalog_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import 'history_detail_page.dart';
import 'katalog_detail_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<dynamic> _recentHistory = [];
  List<dynamic> _recentKatalog = [];
  bool _loading = true;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Container(), // Home Content will be built dynamically
      const KatalogPage(),
      CameraPage(),
      const GeneratePage(),
      const HistoryPage(),
    ]);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final history = await HistoryService.fetchHistory();
      final katalogResult = await KatalogService.fetchRecipes(1, 4);
      final katalog = katalogResult['data'] ?? [];

      setState(() {
        _recentHistory = history.take(3).toList();
        _recentKatalog = katalog;
        _pages[0] = _buildHomeContent();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal load data: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.user.username}!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CameraPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Now'),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent History Section
          if (_recentHistory.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentHistory.length,
                itemBuilder: (context, index) {
                  final item = _recentHistory[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.green.shade50,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HistoryDetailPage(
                              historyItem: item,
                              onUpdate: _loadData,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history,
                                size: 40, color: Colors.green),
                            const SizedBox(height: 12),
                            Text(
                              item['prompt'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Katalog Highlights Section
          if (_recentKatalog.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Katalog Highlights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentKatalog.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = _recentKatalog[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  color: Colors.green.shade50,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => KatalogDetailPage(recipe: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.book, color: Colors.green, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            item['title'] ?? 'Tanpa Judul',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DapoerPlan',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.exit_to_app, color: Colors.green),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                _pages[0],
                _pages[1],
                _pages[3],
                _pages[4],
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => _onTap(0),
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0 ? Colors.green : const Color.fromARGB(255, 97, 97, 97),
              ),
              tooltip: 'Home',
            ),
            IconButton(
              onPressed: () => _onTap(1),
              icon: Icon(
                Icons.book,
                color: _currentIndex == 1 ? Colors.green : const Color.fromARGB(255, 97, 97, 97),
              ),
              tooltip: 'Katalog',
            ),
            const SizedBox(width: 48),
            IconButton(
              onPressed: () => _onTap(2),
              icon: Icon(
                Icons.restaurant_menu,
                color: _currentIndex == 2 ? Colors.green : const Color.fromARGB(255, 97, 97, 97),
              ),
              tooltip: 'Generate',
            ),
            IconButton(
              onPressed: () => _onTap(3),
              icon: Icon(
                Icons.history,
                color: _currentIndex == 3 ? Colors.green : const Color.fromARGB(255, 97, 97, 97),
              ),
              tooltip: 'History',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CameraPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.camera_alt, color: Colors.white),
        tooltip: 'Scan / Deteksi',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
