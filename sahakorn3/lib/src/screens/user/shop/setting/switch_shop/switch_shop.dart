import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class SwitchShopScreen extends StatelessWidget {
  const SwitchShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Switch Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: ShopSalesChart(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Shops',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Consumer<ShopProvider>(
              builder: (context, provider, _) {
                if (provider.shops.isEmpty) {
                  return const Center(child: Text('No shops available'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.shops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final shop = provider.shops[index];
                    return _ShopCard(
                      shop: shop,
                      isActive: shop.id == provider.currentShop?.id,
                      onTap: () {
                        provider.selectShop(shop);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final bool isActive;
  final VoidCallback onTap;

  const _ShopCard({
    required this.shop,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              isActive
                  ? Border.all(color: Colors.indigo.shade400, width: 2)
                  : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Shop Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive ? Colors.indigo.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                image:
                    shop.logo.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(shop.logo),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  shop.logo.isEmpty
                      ? Center(
                        child: Text(
                          shop.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                isActive ? Colors.indigo : Colors.grey.shade400,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 16),
            // Shop Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(shop.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shop.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(shop.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Active Indicator
            if (isActive)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'open':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class ShopSalesChart extends StatefulWidget {
  const ShopSalesChart({super.key});

  @override
  State<StatefulWidget> createState() => ShopSalesChartState();
}

class ShopSalesChartState extends State<ShopSalesChart> {
  // Professional color palette based on AppColors.primary (Purple/Indigo theme)
  final Color dark = const Color(0xFF4A3B99); // Deep Indigo
  final Color normal = const Color(0xFF7A5CFF); // Primary Purple
  final Color light = const Color(0xFFB4A3FF); // Soft Lavender

  int _selectedYear = DateTime.now().year;
  final List<int> _availableYears = [
    DateTime.now().year,
    DateTime.now().year - 1,
    DateTime.now().year - 2,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Revenue',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$128,430',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 12,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '4.2%',
                                  style: TextStyle(
                                    color: Colors.green,
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
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        elevation: 0,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedYear = newValue);
                          }
                        },
                        items:
                            _availableYears.map<DropdownMenuItem<int>>((
                              int value,
                            ) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceBetween,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor:
                                (_) => const Color(0xFF1E293B), // Dark Slate
                            tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.round()}M',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: bottomTitles,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          checkToShowHorizontalLine: (value) => value % 20 == 0,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey.shade100,
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: getData(constraints.maxWidth),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Shop A', normal),
                  const SizedBox(width: 24),
                  _buildLegendItem('Shop B', dark),
                  const SizedBox(width: 24),
                  _buildLegendItem('Shop C', light),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF94A3B8), // Slate 400
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    String text = switch (value.toInt()) {
      0 => 'Jan',
      2 => 'Mar',
      4 => 'May',
      6 => 'Jul',
      8 => 'Sep',
      10 => 'Nov',
      _ => '',
    };
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> getData(double maxWidth) {
    // Generate mock data
    final isCurrentYear = _selectedYear == DateTime.now().year;

    // Calculate width to fit 12 bars comfortably
    final barWidth = (maxWidth - 48) / 12 * 0.5;

    return List.generate(12, (index) {
      double v1 = (index + 1) * 5.0 + (isCurrentYear ? 20 : 10);
      double v2 = (index + 1) * 3.0 + (isCurrentYear ? 30 : 20);
      double v3 = (index + 1) * 4.0 + (isCurrentYear ? 15 : 10);

      // Add some randomness
      if (index % 3 == 0) v1 += 10;
      if (index % 2 == 0) v2 -= 5;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: v1 + v2 + v3,
            rodStackItems: [
              BarChartRodStackItem(0, v1, normal),
              BarChartRodStackItem(v1, v1 + v2, dark),
              BarChartRodStackItem(v1 + v2, v1 + v2 + v3, light),
            ],
            borderRadius: BorderRadius.circular(4),
            width: barWidth,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150, // Max height
              color: Colors.grey.withOpacity(0.05),
            ),
          ),
        ],
      );
    });
  }
}
