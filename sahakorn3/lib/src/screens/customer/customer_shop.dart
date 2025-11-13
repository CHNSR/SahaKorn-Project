import 'package:flutter/material.dart';

class CustomerShop extends StatefulWidget {
  const CustomerShop({super.key});

  @override
  State<CustomerShop> createState() => _CustomerShopState();
}

class _CustomerShopState extends State<CustomerShop> {
  final TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, String>> _allItems = [];
  List<MapEntry<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // สร้างข้อมูลตัวอย่าง
    _allItems = List.generate(10, (i) => MapEntry('Shop #${300 + i}', 'Location ${(i + 1)}'));
    _filteredItems = _allItems;
    _searchController.addListener(_filterShops);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterShops);
    _searchController.dispose();
    super.dispose();
  }

  void _filterShops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final shopName = item.key.toLowerCase();
        return shopName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shops', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // --- Search Bar UI ---
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Shops',
                  hintText: 'Enter shop name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredItems.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final e = _filteredItems[i];
                    return ListTile(
                      leading: const Icon(Icons.storefront),
                      title: Text(e.key),
                      subtitle: Text(e.value),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
