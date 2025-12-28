import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sahakorn3/src/screens/user/shop/widgets/transaction_chart.dart';
import 'package:sahakorn3/src/screens/user/shop/widgets/transaction_heatmap.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';

class ShopHomepage extends StatefulWidget {
  const ShopHomepage({super.key});

  @override
  State<ShopHomepage> createState() => _ShopHomepageState();
}

class _ShopHomepageState extends State<ShopHomepage> {
  @override
  void initState() {
    super.initState();
    // Load mock data for demonstration as requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadMockShops();
    });
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
              const TransactionChart(),
              const SizedBox(height: 24),

              // Transaction Heatmap
              const TransactionHeatmap(),

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
            Formatters.formatBaht(12300.00),
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
              _buildMiniStat('IN', 18000.00, Colors.green),
              const SizedBox(width: 16),
              _buildMiniStat('OUT', 5700.00, Colors.red),
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
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.manageTotalCredit);
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
                sections: [
                  // Remaining (Green/White)
                  PieChartSectionData(
                    color: Color(0xFFb5e48c),
                    value: 12300,
                    title: '',
                    radius: 10,
                    showTitle: false,
                  ),
                  // Used (Yellow)
                  PieChartSectionData(
                    color: Color(0xFFf4d35e),
                    value: 5700,
                    title: '',
                    radius: 10,
                    showTitle: false,
                  ),
                  //out date (Red)
                  PieChartSectionData(
                    color: Color(0xFFf95738),
                    value: 500,
                    title: '',
                    radius: 10,
                    showTitle: false,
                  ),
                ],
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
