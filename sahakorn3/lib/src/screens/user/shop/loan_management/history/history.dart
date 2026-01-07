import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final TransactionRepository _transactionRepo = TransactionRepository();

  List<AppTransaction> _allTransactions = [];
  List<AppTransaction> _filteredTransactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    final shop = context.read<ShopProvider>().currentShop;
    if (shop == null) return;

    setState(() => _isLoading = true);

    try {
      // Fetch all transactions for the shop (with a reasonable limit for history)
      final txns = await _transactionRepo.getByCatagoryOfUser(
        catagory: TransactionQueryType.shop,
        playload: shop.id,
        limit: 500, // Fetch enough to filter
      );

      // Filter specifically for Loan-related events
      final relevantTxns =
          txns.where((t) {
            // 1. Repayment (category == 'LOAN_REPAYMENT')
            if (t.category == 'LOAN_REPAYMENT' || t.category == 'repayment')
              return true; // keep legacy check for a moment if needed
            // 2. Loan Given (paymentMethod == 'Loan')
            if (t.paymentMethod == 'Loan') return true;
            return false;
          }).toList();

      if (mounted) {
        setState(() {
          _allTransactions = relevantTxns;
          _filteredTransactions = relevantTxns;
          _isLoading = false;
        });
        _filterData(); // Apply initial filters if any
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // show error?
      }
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTransactions =
          _allTransactions.where((item) {
            // Determine type for filter
            final isRepayment =
                item.category == 'LOAN_REPAYMENT' ||
                item.category == 'repayment';

            // 1. Filter by Text (Search user ID or detail)
            final matchesSearch =
                item.userId.toLowerCase().contains(query) ||
                (item.detail ?? '').toLowerCase().contains(query) ||
                item.transactionId.toLowerCase().contains(query);

            // 2. Filter by Category
            bool matchesCategory = true;
            if (_selectedFilter == 'Loan') {
              matchesCategory = !isRepayment; // Show only Loans
            } else if (_selectedFilter == 'Repayment') {
              matchesCategory = isRepayment; // Show only Repayments
            }

            return matchesSearch && matchesCategory;
          }).toList();

      // Sort by newest first
      _filteredTransactions.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(2000);
        final dateB = b.createdAt ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: _filteredTransactions.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(
                            _filteredTransactions[index],
                          );
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
                'Loan History',
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
                hintText: 'Search User ID or Detail...',
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

  Widget _buildTransactionCard(AppTransaction item) {
    // Determine type
    final bool isRepayment =
        item.category == 'LOAN_REPAYMENT' || item.category == 'repayment';

    // UI Props based on type
    final String actionTitle = isRepayment ? 'Repayment' : 'Loan Given';
    final bool isIncome =
        isRepayment; // Repayment = Money In (Green), Loan = Money Out/Debt Up (Red-ish)
    final DateTime date = item.createdAt ?? DateTime.now();

    // For Loan Given, usually it's Credit Purchase, so it technically means "Sales", but in Debt context it increases debt.
    // Let's stick to Green for Repayment (Good), Red/Orange for Loan (Debt).

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
                      : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? Colors.green[700] : Colors.orange[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actionTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // Show User ID or fallback. Ideally fetch User Name.
                  item.userId.length > 10
                      ? 'User: ...${item.userId.substring(item.userId.length - 6)}'
                      : 'User: ${item.userId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy • HH:mm').format(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${Formatters.formatBaht(item.totalAmount, showSign: false)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.green[700] : Colors.orange[800],
                ),
              ),
              const SizedBox(height: 4),
              if (item.detail != null && item.detail!.isNotEmpty)
                Text(
                  item.detail!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          Icon(Icons.manage_search, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No loan history found',
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
