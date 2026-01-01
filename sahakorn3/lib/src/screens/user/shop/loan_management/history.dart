import 'package:flutter/material.dart';
import '../../../../utils/formatters.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Mock History Data
  final List<Map<String, dynamic>> _allHistory = [
    {
      'id': '1',
      'date': '2024-04-20 14:30',
      'action': 'Repayment',
      'customer': 'Somchai Jai-dee',
      'amount': 5000.0,
      'isIncome': true,
      'note': 'Cash payment',
    },
    {
      'id': '2',
      'date': '2024-04-18 10:15',
      'action': 'Loan Given',
      'customer': 'Manee Me-jai',
      'amount': 10000.0,
      'isIncome': false,
      'note': 'Fertilizer purchase',
    },
    {
      'id': '3',
      'date': '2024-04-15 09:45',
      'action': 'Loan Given',
      'customer': 'Mana Me-ngern',
      'amount': 50000.0,
      'isIncome': false,
      'note': 'Equipment loan',
    },
    {
      'id': '4',
      'date': '2024-04-10 16:20',
      'action': 'Repayment',
      'customer': 'Somsri Rak-ngern',
      'amount': 2500.0,
      'isIncome': true,
      'note': 'Monthly installment',
    },
    {
      'id': '5',
      'date': '2024-04-05 11:00',
      'action': 'Loan Given',
      'customer': 'Piti Rak-thai',
      'amount': 15000.0,
      'isIncome': false,
      'note': 'Seeds',
    },
  ];

  List<Map<String, dynamic>> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _filterData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredHistory =
          _allHistory.where((item) {
            // 1. Filter by Text
            final matchesSearch =
                item['customer'].toLowerCase().contains(query) ||
                item['action'].toLowerCase().contains(query);

            // 2. Filter by Category
            bool matchesCategory = true;
            if (_selectedFilter == 'Loan') {
              matchesCategory = !item['isIncome'];
            } else if (_selectedFilter == 'Repayment') {
              matchesCategory = item['isIncome'];
            }

            return matchesSearch && matchesCategory;
          }).toList();

      // Sort by date descending (mock date string comparison works for ISO-like, but better to parse)
      // For simplicity here relying on list order or simple string compare if needed
      _filteredHistory.sort((a, b) => b['date'].compareTo(a['date']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilterSection(),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _filteredHistory.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: _filteredHistory.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(_filteredHistory[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.history, color: Colors.indigo),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customer or action...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Loan'),
              const SizedBox(width: 8),
              _buildFilterChip('Repayment'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _filterData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[300]!,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item) {
    final bool isIncome = item['isIncome'];
    final DateTime date = DateTime.parse(item['date']); // simple parse for mock

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isIncome
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? Colors.green[700] : Colors.red[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['action'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['customer'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${Formatters.formatBaht(item['amount'], showSign: false)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(height: 4),
              if (item['note'] != null)
                Text(
                  item['note'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
