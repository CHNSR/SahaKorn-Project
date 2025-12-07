import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LoanUsageChart extends StatefulWidget {
  const LoanUsageChart({super.key});

  @override
  State<LoanUsageChart> createState() => _LoanUsageChartState();
}

class _LoanUsageChartState extends State<LoanUsageChart> {
  String _selectedFilter = 'Day'; // Day, Month, Year

  // Mock Data
  final Map<String, List<double>> _mockData = {
    'Day': [500, 1200, 800, 1500, 2000, 1000, 2500], // Last 7 days
    'Month': [
      15000,
      18000,
      12000,
      20000,
      22000,
      19000,
      25000,
      21000,
      23000,
      26000,
      24000,
      28000,
    ], // 12 Months
    'Year': [150000, 180000, 200000, 220000, 250000], // Last 5 Years
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Loan Usage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildFilterDropdown(),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getInterval(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
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
                            // Show fewer labels for Month view to avoid crowding
                            if (_selectedFilter == 'Month' && index % 2 != 0) {
                              return const SizedBox();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                labels[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
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
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      left: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: (_mockData[_selectedFilter]!.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.blueGrey,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '${flSpot.y.round()} ฿',
                            const TextStyle(color: Colors.white),
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

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items:
              ['Day', 'Month', 'Year'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    final data = _mockData[_selectedFilter]!;
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index]);
    });
  }

  double _getMaxY() {
    final data = _mockData[_selectedFilter]!;
    double max = data.reduce((curr, next) => curr > next ? curr : next);
    return max * 1.2; // Add some buffer
  }

  double _getInterval() {
    double max = _getMaxY();
    return max / 4; // 4 grid lines
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
