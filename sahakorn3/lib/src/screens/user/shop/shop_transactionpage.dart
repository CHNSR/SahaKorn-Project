import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:intl/intl.dart';

class ShopTransaction extends StatefulWidget {
  const ShopTransaction({super.key});

  @override
  State<ShopTransaction> createState() => _ShopTransactionState();
}

class _ShopTransactionState extends State<ShopTransaction> {
  final TransactionRepository _repository = TransactionRepository();
  // SearchCriteria? _currentCriteria; // Removed as Search is now standalone

  void _openAdvanceSearch() {
    Navigator.pushNamed(context, Routes.advanceSearch, arguments: _repository);
  }

  // void _clearSearch() {
  //   setState(() {
  //     _currentCriteria = null;
  //   });
  // }

  // bool _isTransactionVisible(AppTransaction t) {
  //   if (_currentCriteria == null) return true;
  //   final c = _currentCriteria!;

  //   // Date Filter
  //   if (c.startDate != null && c.endDate != null) {
  //     if (t.createdAt == null) return false;
  //     // Include the whole end date
  //     final end = c.endDate!
  //         .add(const Duration(days: 1))
  //         .subtract(const Duration(seconds: 1));
  //     if (t.createdAt!.isBefore(c.startDate!) || t.createdAt!.isAfter(end)) {
  //       return false;
  //     }
  //   }

  //   // Amount Filter
  //   if (t.totalAmount < c.amountRange.start ||
  //       t.totalAmount > c.amountRange.end) {
  //     return false;
  //   }

  //   // Type/PaymentMethod Filter
  //   if (c.selectedTypes.isNotEmpty) {
  //     // Logic: if selectedType contains the PaymentMethod (or matches)
  //     // Since our mock data uses various strings for paymentMethod, we do a basic check.
  //     // If user selected 'Income', we might want to show all.
  //     // For now, let's assume direct text match is what user expects if they are cleaning up data.
  //     // Or if data is consistent (e.g. 'Cash', 'Credit'), filtering by 'Income' might be vague.
  //     // Let's assume the user selects 'Cash' if they want 'Cash'.
  //     // But the UI offers 'Income', 'Expense', 'Loan', 'Payment'.
  //     // If t.paymentMethod is 'Loan', and 'Loan' selected -> true.
  //     if (!c.selectedTypes.contains(t.paymentMethod)) {
  //       // If exact match fails, try partial or "smart" match?
  //       // Let's keep strict for now to encourage better data.
  //       return false;
  //     }
  //   }

  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE4F0E8), // Soft mint green (top)
              Color(0xFFC9E4D6), // Slightly darker sage (bottom)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildShopNameCards(),
              const SizedBox(height: 20),
              Expanded(child: _buildTransactionList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        'Transactions',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildShopNameCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Yellow Top Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF6FF85), // Pale yellow
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24), // Spacer for centering
                    Column(
                      children: [
                        const Text(
                          'THB',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Balance Available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.black.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Formatters.formatBaht(26887.09),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '+\$421.03',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20), // Dark green
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // White Bottom Section (Buttons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.saved_search,
                  'Search',
                  onTap: _openAdvanceSearch,
                ),
                _buildVerticalDivider(),
                _buildActionButton(
                  Icons.swap_horiz,
                  'Export',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.exportTransaction,
                      arguments: _repository,
                    );
                  },
                ),
                _buildVerticalDivider(),
                _buildActionButton(
                  Icons.receipt,
                  'Recept',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.digitalReceipt);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}), // Simple refresh
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<AppTransaction>>(
              future: _repository.listAll(limit: 20),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }

                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.05),
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
                              color: Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              t.paymentMethod == 'Loan'
                                  ? Icons.credit_score
                                  : Icons.payments_outlined,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.detail ?? 'Transaction',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.paymentMethod,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.formatBaht(
                                  t.totalAmount,
                                  showSign: true,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(t.createdAt ?? DateTime.now()),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return DateFormat('dd/MM HH:mm').format(d);
  }
}
