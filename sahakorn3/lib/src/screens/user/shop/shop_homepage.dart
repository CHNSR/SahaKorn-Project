import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/services/firebase/credit/credit_repository.dart';

class ShopHomepage extends StatefulWidget {
  const ShopHomepage({super.key});

  @override
  State<ShopHomepage> createState() => _ShopHomepageState();
}

class _ShopHomepageState extends State<ShopHomepage> {
  final CreditRepository _creditRepo = CreditRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();

  double _usedCredit = 0.0;
  double _overdueCredit = 0.0;
  List<AppTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadShops();
      context.read<UserInformationProvider>().addListener(_checkAndLoadShops);
    });
  }

  @override
  void dispose() {
    context.read<UserInformationProvider>().removeListener(_checkAndLoadShops);
    super.dispose();
  }

  void _checkAndLoadShops() {
    if (!mounted) return;

    final userProvider = context.read<UserInformationProvider>();
    final shopProvider = context.read<ShopProvider>();

    final userId = userProvider.uid;

    // Only load if user exists and shops aren't loaded or loading
    if (userId != null && shopProvider.shops.isEmpty && !shopProvider.loading) {
      shopProvider.loadShops(userId).then((_) {
        // After shops are loaded, load credit stats
        _loadCreditStats();
      });
    } else if (shopProvider.currentShop != null) {
      // If shop already loaded, just update stats
      _loadCreditStats();
    }
  }

  Future<void> _loadCreditStats() async {
    final shop = context.read<ShopProvider>().currentShop;
    final userId = context.read<UserInformationProvider>().uid;

    if (shop == null || userId == null) return;

    final used = await _creditRepo.countTotalAmountDistributedCredit(
      shopId: shop.id,
    );
    final overdue = await _creditRepo.countTotalAmountOverdueCredit(
      shopId: shop.id,
    );

    final txns = await _transactionRepo.fetchForAnalytics(
      userId,
      shopId: shop.id,
    );

    if (mounted) {
      setState(() {
        _usedCredit = used ?? 0.0;
        _overdueCredit = overdue ?? 0.0;
        _transactions = txns;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade50, // Light background for better contrast
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Summary Cards
              _buildSummarySection(),
              const SizedBox(height: 24),

              // Transaction Chart
              TransactionChart(transactions: _transactions),
              const SizedBox(height: 24),

              // Transaction Heatmap
              TransactionHeatmap(transactions: _transactions),

              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
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
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo.shade600,
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _buildBalanceCard()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildActionCard()),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final shop = context.watch<ShopProvider>().currentShop;
    final double creditLimit = shop?.creditLimit ?? 0.0;
    final double available = creditLimit - _usedCredit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                'Credit Balance',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.formatBaht(available),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('LIMIT', creditLimit, Colors.green),
              const SizedBox(width: 16),
              _buildMiniStat('USED', _usedCredit, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          Formatters.formatBaht(amount, showSign: false),
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard() {
    final shop = context.watch<ShopProvider>().currentShop;
    final double creditLimit = shop?.creditLimit ?? 0.0;

    // Calculate distributions
    double available = creditLimit - _usedCredit;
    if (available < 0) available = 0;
    final double normalUsed = _usedCredit - _overdueCredit;

    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, Routes.manageTotalCredit);
        // Refresh when coming back
        _loadCreditStats();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade600, Colors.blue.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.shade200,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40, // 80% scale
                startDegreeOffset: -90,
                sections:
                    creditLimit > 0
                        ? [
                          // Available (Green/White)
                          PieChartSectionData(
                            color: const Color(0xFFb5e48c),
                            value: available,
                            title: '',
                            radius: 10,
                            showTitle: false,
                          ),
                          // Normal Used (Yellow)
                          PieChartSectionData(
                            color: const Color(0xFFf4d35e),
                            value: normalUsed > 0 ? normalUsed : 0,
                            title: '',
                            radius: 10,
                            showTitle: false,
                          ),
                          // Overdue (Red)
                          PieChartSectionData(
                            color: const Color(0xFFf95738),
                            value: _overdueCredit,
                            title: '',
                            radius: 10,
                            showTitle: false,
                          ),
                        ]
                        : [], // Empty if no limit
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'Credit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
