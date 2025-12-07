import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions Trend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                                if (_selectedFilter == 'Month' &&
                                    index % 2 != 0) {
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
                            reservedSize: 40,
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
                      maxX:
                          (_mockData[_selectedFilter]![0].length - 1)
                              .toDouble(),
                      minY: 0,
                      maxY: _getMaxY(),
                      lineBarsData: [
                        // Line 1: Total (Blue)
                        if (_showTotal)
                          _buildLineChartBarData(
                            _mockData[_selectedFilter]![0],
                            Colors.blue,
                          ),
                        // Line 2: Loan (Yellow)
                        if (_showLoan)
                          _buildLineChartBarData(
                            _mockData[_selectedFilter]![1],
                            Colors.amber,
                          ),
                        // Line 3: Cash (Green)
                        if (_showCash)
                          _buildLineChartBarData(
                            _mockData[_selectedFilter]![2],
                            Colors.green,
                          ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => Colors.blueGrey,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              String label = '';
                              // Map color to label since barIndex might change based on visibility
                              if (barSpot.bar.color == Colors.blue)
                                label = 'Total: ';
                              if (barSpot.bar.color == Colors.amber)
                                label = 'Loan: ';
                              if (barSpot.bar.color == Colors.green)
                                label = 'Cash: ';

                              return LineTooltipItem(
                                '$label${flSpot.y.round()} ฿',
                                TextStyle(color: barSpot.bar.color),
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
        ),
        const SizedBox(height: 12),
        _buildToggleButtons(),
      ],
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

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton('Total', Colors.blue, _showTotal, (val) {
          setState(() => _showTotal = val);
        }),
        const SizedBox(width: 12),
        _buildToggleButton('Loan', Colors.amber, _showLoan, (val) {
          setState(() => _showLoan = val);
        }),
        const SizedBox(width: 12),
        _buildToggleButton('Cash', Colors.green, _showCash, (val) {
          setState(() => _showCash = val);
        }),
      ],
    );
  }

  Widget _buildToggleButton(
    String label,
    Color color,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: onChanged,
      backgroundColor: Colors.grey[200],
      selectedColor: color,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
        ),
      ),
      showCheckmark: false,
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (index) {
        return FlSpot(index.toDouble(), data[index]);
      }),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
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
