import 'package:flutter/material.dart';
import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/services/firebase/shop/shop_repository.dart';
import 'package:sahakorn3/src/routes/routes.dart';

class SearchShopScreen extends StatefulWidget {
  const SearchShopScreen({super.key});

  @override
  State<SearchShopScreen> createState() => _SearchShopScreenState();
}

class _SearchShopScreenState extends State<SearchShopScreen> {
  final _searchController = TextEditingController();
  final _shopRepository = ShopRepository();
  List<Shop> _results = [];
  bool _isLoading = false;

  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    final results = await _shopRepository.searchShops(query);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Shops'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by shop name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _onSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for shops to join',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final shop = _results[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: const Icon(
                                Icons.store,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Text(shop.name),
                            subtitle: Text(shop.address),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.customerShop,
                                  arguments: shop,
                                );
                              },
                              // style: ElevatedButton.styleFrom(
                              //   backgroundColor: Colors.indigo,
                              //   foregroundColor: Colors.white,
                              // ),
                              child: const Text('View'),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
