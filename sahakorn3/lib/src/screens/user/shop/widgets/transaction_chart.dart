import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class TransactionChart extends StatefulWidget {
  const TransactionChart({super.key});

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  String _selectedFilter = 'Day'; // Day, Month, Year
  // Toggle states
  bool _showTotal = true;
  bool _showLoan = true;
  bool _showCash = true;

  // Mock Data Structure: [Total (Blue), Loan (Yellow), Cash (Green)]
  final Map<String, List<List<double>>> _mockData = {
    'Day': [
      [1500, 2200, 1800, 2500, 3000, 2000, 3500], // Total
      [500, 1000, 600, 1000, 1200, 800, 1500], // Loan
      [1000, 1200, 1200, 1500, 1800, 1200, 2000], // Cash
    ],
    'Month': [
      [
        30000,
        35000,
        28000,
        40000,
        42000,
        38000,
        45000,
        41000,
        43000,
        48000,
        45000,
        50000,
      ], // Total
      [
        10000,
        12000,
        8000,
        15000,
        18000,
        14000,
        20000,
        16000,
        18000,
        22000,
        20000,
        24000,
      ], // Loan
      [
        20000,
        23000,
        20000,
        25000,
        24000,
        24000,
        25000,
        25000,
        25000,
        26000,
        25000,
        26000,
      ], // Cash
    ],
    'Year': [
      [300000, 350000, 400000, 450000, 500000], // Total
      [100000, 120000, 150000, 180000, 200000], // Loan
      [200000, 230000, 250000, 270000, 300000], // Cash
    ],
  };

  final Map<String, List<String>> _mockLabels = {
    'Day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Month': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
    'Year': ['2021', '2022', '2023', '2024', '2025'],
  };

  @override
  Widget build(BuildContext context) {
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
            // Header with Title and Time Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                _buildTimeFilter(),
              ],
            ),
            const SizedBox(height: 32),

            // Chart
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
                        color: Colors.grey.withValues(alpha: 0.05),
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
                          final labels = _mockLabels[_selectedFilter]!;
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
                  maxX: (_mockData[_selectedFilter]![0].length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    if (_showTotal)
                      _buildLineChartBarData(
                        _mockData[_selectedFilter]![0],
                        const Color(0xFF2196F3), // Professional Blue
                        true,
                      ),
                    if (_showLoan)
                      _buildLineChartBarData(
                        _mockData[_selectedFilter]![1],
                        const Color(0xFFFFC107), // Professional Amber
                        false,
                      ),
                    if (_showCash)
                      _buildLineChartBarData(
                        _mockData[_selectedFilter]![2],
                        const Color(0xFF4CAF50), // Professional Green
                        false,
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
                          String label = '';
                          if (barSpot.bar.color == const Color(0xFF2196F3))
                            label = 'Total';
                          if (barSpot.bar.color == const Color(0xFFFFC107))
                            label = 'Loan';
                          if (barSpot.bar.color == const Color(0xFF4CAF50))
                            label = 'Cash';

                          return LineTooltipItem(
                            '$label\n',
                            const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: Formatters.formatBaht(flSpot.y),
                                style: TextStyle(
                                  color: barSpot.bar.color,
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
            const SizedBox(height: 24),

            // Legend / Toggles
            _buildLegend(),
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

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          'Total',
          const Color(0xFF2196F3),
          _showTotal,
          (val) => setState(() => _showTotal = !val),
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          'Loan',
          const Color(0xFFFFC107),
          _showLoan,
          (val) => setState(() => _showLoan = !val),
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          'Cash',
          const Color(0xFF4CAF50),
          _showCash,
          (val) => setState(() => _showCash = !val),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    bool isVisible,
    Function(bool) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(isVisible),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isVisible ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isVisible ? color : Colors.grey.shade400,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isVisible ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
    List<double> data,
    Color color,
    bool isPrimary,
  ) {
    return LineChartBarData(
      spots: List.generate(data.length, (index) {
        return FlSpot(index.toDouble(), data[index]);
      }),
      isCurved: true,
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
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }

  double _getMaxY() {
    // Find max value across all datasets for current filter
    double max = 0;
    for (var dataset in _mockData[_selectedFilter]!) {
      for (var value in dataset) {
        if (value > max) max = value;
      }
    }
    return max * 1.2; // Add buffer
  }

  double _getInterval() {
    double max = _getMaxY();
    return max / 4;
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
