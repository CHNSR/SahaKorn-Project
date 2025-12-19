import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class ShopTransaction extends StatefulWidget {
  const ShopTransaction({super.key});

  @override
  State<ShopTransaction> createState() => _ShopTransactionState();
}

class _ShopTransactionState extends State<ShopTransaction> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';

  final List<TransactionItem> _transactions = [
    TransactionItem(
      title: 'Shopping at Market',
      date: DateTime(2025, 8, 24),
      amount: -250.50,
      category: 'Groceries',
    ),
    TransactionItem(
      title: 'Electricity Bill',
      date: DateTime(2025, 8, 20),
      amount: -1200.00,
      category: 'Utilities',
    ),
    TransactionItem(
      title: 'Salary',
      date: DateTime(2025, 8, 1),
      amount: 15000.00,
      category: 'Income',
    ),
    TransactionItem(
      title: 'Sold old bike',
      date: DateTime(2025, 7, 28),
      amount: 1200.00,
      category: 'Income',
    ),
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  List<TransactionItem> get _filteredTransactions {
    final query = _searchController.text.toLowerCase();
    return _transactions.where((t) {
      if (_filter == 'Income' && t.amount <= 0) return false;
      if (_filter == 'Expenses' && t.amount > 0) return false;
      if (query.isEmpty) return true;
      return t.title.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar: use a web-style heading inside the body for a spacious look
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Web-style heading
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Overview of recent activity and balances',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Optional actions on the right to mimic a web toolbar
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // quick action: clear search
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear_all),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // placeholder for export/share action
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSummaryCard(),
                const SizedBox(height: 12),
                _buildSearchAndFilter(),
                const SizedBox(height: 12),
                Expanded(child: _buildTransactionList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final balance = _transactions.fold<double>(0, (s, e) => s + e.amount);
    final income = _transactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (s, e) => s + e.amount);
    final expense = _transactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (s, e) => s + e.amount.abs());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  '${balance.toStringAsFixed(2)} ฿',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatBaht(income, showSign: true),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.formatBaht(-expense, showSign: true),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search transactions or category',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (v) => setState(() => _filter = v),
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: 'All', child: Text('All')),
                PopupMenuItem(value: 'Income', child: Text('Income')),
                PopupMenuItem(value: 'Expenses', child: Text('Expenses')),
              ],
          child: Chip(label: Text(_filter)),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final items = _filteredTransactions;
    if (items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 60),
          Center(
            child: Text(
              'No transactions',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = items[index];
        final isIncome = t.amount > 0;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              t.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${_formatDate(t.date)} • ${t.category}',
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Amount: ${Formatters.formatBaht(t.amount, showSign: true)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.amount > 0 ? 'Completed' : 'Paid',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
            onTap: () {
              _showDetails(t);
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _showDetails(TransactionItem t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final isIncome = t.amount > 0;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Category: ${t.category}'),
              const SizedBox(height: 4),
              Text('Date: ${_formatDate(t.date)}'),
              const SizedBox(height: 4),
              Text(
                Formatters.formatBaht(t.amount, showSign: true),
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TransactionItem {
  final String title;
  final DateTime date;
  final double amount;
  final String category;

  TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
  });
}
