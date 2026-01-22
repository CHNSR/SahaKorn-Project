import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:intl/intl.dart';

class ShopTransaction extends StatefulWidget {
  const ShopTransaction({super.key});

  @override
  State<ShopTransaction> createState() => _ShopTransactionState();
}

class _ShopTransactionState extends State<ShopTransaction> {
  final TransactionRepository _repository = TransactionRepository();
  late Future<Map<String, double>> _statsFuture;
  late Future<List<AppTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final shopId = context.read<ShopProvider>().currentShop?.id ?? '';
    setState(() {
      _statsFuture = _repository.calculateStats(shopId: shopId);
      _transactionsFuture = _repository.getByCatagoryOfUser(
        catagory: TransactionQueryType.shop,
        playload: shopId,
        limit: 20,
      );
    });
  }

  void _openAdvanceSearch() {
    Navigator.pushNamed(context, Routes.advanceSearch, arguments: _repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Professional Light Grey
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            Expanded(child: _buildTransactionList()),
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
                'Transactions',
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
            child: const Icon(Icons.receipt_long, color: Colors.indigo),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return FutureBuilder<Map<String, double>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'totalBalance': 0.0, 'todaySales': 0.0};
        final totalBalance = stats['totalBalance']!;
        final todaySales = stats['todaySales']!;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ], // Modern Dark Teal
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C5364).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_graph,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              isLoading
                  ? const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : Text(
                    Formatters.formatBaht(totalBalance),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: Colors.lightGreenAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${Formatters.formatBaht(todaySales, showSign: false)} (Today)',
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCapsule(
              icon: Icons.search,
              label: 'Search',
              color: Colors.blueAccent,
              onTap: _openAdvanceSearch,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCapsule(
              icon: Icons.upload_file,
              label: 'Export',
              color: Colors.orange,
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    Routes.exportTransaction,
                    arguments: _repository,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCapsule(
              icon: Icons.receipt,
              label: 'Receipt',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, Routes.digitalReceipt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCapsule({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: _refreshData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<AppTransaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: transactions.length,
                  separatorBuilder:
                      (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                  itemBuilder: (context, index) {
                    return _buildTransactionTile(transactions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(AppTransaction t) {
    bool isLoan = t.paymentMethod == 'Loan';
    bool isCredit = t.paymentMethod == 'Credit';

    IconData icon;
    Color iconColor;
    Color iconBg;

    if (isLoan) {
      icon = Icons.credit_score;
      iconColor = Colors.orange[700]!;
      iconBg = Colors.orange[50]!;
    } else if (isCredit) {
      icon = Icons.credit_card;
      iconColor = Colors.purple[700]!;
      iconBg = Colors.purple[50]!;
    } else {
      icon = Icons.payments_outlined;
      iconColor = Colors.green[700]!;
      iconBg = Colors.green[50]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
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
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      t.paymentMethod,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.circle, size: 4, color: Colors.grey[300]),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(t.createdAt ?? DateTime.now()),
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatBaht(t.totalAmount, showSign: true),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green, // Assuming mostly income for now
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return DateFormat('HH:mm').format(d);
  }
}
