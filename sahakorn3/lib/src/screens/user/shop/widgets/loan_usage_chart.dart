import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahakorn3/src/models/transaction.dart';
import 'package:sahakorn3/src/utils/formatters.dart';

class LoanUsageChart extends StatefulWidget {
  final List<AppTransaction> transactions;
  const LoanUsageChart({super.key, required this.transactions});

  @override
  State<LoanUsageChart> createState() => _LoanUsageChartState();
}

class _LoanUsageChartState extends State<LoanUsageChart> {
  String _selectedFilter = 'Day'; // Day, Month, Year

  Map<String, List<double>> _processedData = {};
  Map<String, List<String>> _labels = {};

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant LoanUsageChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _processData();
    }
  }

  void _processData() {
    // Initialize empty structure
    _processedData = {'Day': [], 'Month': [], 'Year': []};
    _labels = {'Day': [], 'Month': [], 'Year': []};

    if (widget.transactions.isEmpty) return;

    final now = DateTime.now();

    // --- Process Day (Last 7 Days) ---
    final List<String> dayLabels = [];
    final List<double> dayData = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dayLabels.add(DateFormat('E').format(date)); // Mon, Tue...

      final txns = widget.transactions.where((t) {
        final tDate = t.createdAt;
        if (tDate == null) return false;
        return tDate.year == date.year &&
            tDate.month == date.month &&
            tDate.day == date.day &&
            t.paymentMethod == 'Loan';
      });

      double sum = txns.fold(0, (prev, element) => prev + element.totalAmount);
      dayData.add(sum);
    }
    _processedData['Day'] = dayData;
    _labels['Day'] = dayLabels;

    // --- Process Month (Last 12 Months) ---
    final List<String> monthLabels = [];
    final List<double> monthData = [];

    for (int i = 11; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      monthLabels.add(DateFormat('MMM').format(d));

      final txns = widget.transactions.where((t) {
        final tDate = t.createdAt;
        if (tDate == null) return false;
        return tDate.year == d.year &&
            tDate.month == d.month &&
            t.paymentMethod == 'Loan';
      });

      double sum = txns.fold(0, (prev, element) => prev + element.totalAmount);
      monthData.add(sum);
    }
    _processedData['Month'] = monthData;
    _labels['Month'] = monthLabels;

    // --- Process Year (Last 5 Years) ---
    final List<String> yearLabels = [];
    final List<double> yearData = [];

    for (int i = 4; i >= 0; i--) {
      final y = now.year - i;
      yearLabels.add(y.toString());

      final txns = widget.transactions.where((t) {
        final tDate = t.createdAt;
        if (tDate == null) return false;
        return tDate.year == y && t.paymentMethod == 'Loan';
      });

      double sum = txns.fold(0, (prev, element) => prev + element.totalAmount);
      yearData.add(sum);
    }
    _processedData['Year'] = yearData;
    _labels['Year'] = yearLabels;
  }

  @override
  Widget build(BuildContext context) {
    // Check if data is empty or all zeros
    bool isEmpty = widget.transactions.isEmpty;
    bool allZeros = true;
    if (!isEmpty && _processedData[_selectedFilter] != null) {
      allZeros = _processedData[_selectedFilter]!.every((val) => val == 0);
    }

    if (isEmpty || allZeros) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
        child: const SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No loan usage data available'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loan Usage',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                _buildTimeFilter(),
              ],
            ),
            const SizedBox(height: 32),
            AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getInterval(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.05),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          final labels = _labels[_selectedFilter] ?? [];
                          if (index >= 0 && index < labels.length) {
                            if (_selectedFilter == 'Month' && index % 2 != 0) {
                              return const SizedBox();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getInterval(),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            _formatCurrency(value),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX:
                      ((_processedData[_selectedFilter]?.length ?? 1) - 1)
                          .toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    _buildLineChartBarData(
                      _processedData[_selectedFilter] ?? [],
                      const Color(0xFF2196F3),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor:
                          (touchedSpot) => Colors.blueGrey.shade900,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            'Loan\n',
                            const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: Formatters.formatBaht(flSpot.y),
                                style: const TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            ['Day', 'Month', 'Year'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                            : null,
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (index) {
        return FlSpot(index.toDouble(), data[index]);
      }),
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  double _getMaxY() {
    final data = _processedData[_selectedFilter];
    if (data == null || data.isEmpty) return 100;

    double max = 0;
    for (var val in data) {
      if (val > max) max = val;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  double _getInterval() {
    double max = _getMaxY();
    return max == 0 ? 1 : max / 4;
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
