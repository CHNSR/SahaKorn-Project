import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sahakorn3/src/models/transaction.dart';
import 'package:sahakorn3/src/utils/formatters.dart';
import 'package:intl/intl.dart';

class TransactionChart extends StatefulWidget {
  final List<AppTransaction> transactions;
  const TransactionChart({super.key, required this.transactions});

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  String _selectedFilter = 'Day'; // Day, Month, Year
  // Toggle states
  bool _showTotal = true;
  bool _showLoan = true;
  bool _showCash = true;

  Map<String, List<List<double>>> _processedData = {};
  Map<String, List<String>> _labels = {};

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant TransactionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _processData();
    }
  }

  void _processData() {
    // Initialize empty structure
    _processedData = {
      'Day': [[], [], []],
      'Month': [[], [], []],
      'Year': [[], [], []],
    };
    _labels = {'Day': [], 'Month': [], 'Year': []};

    if (widget.transactions.isEmpty) return;

    final now = DateTime.now();

    // --- Process Day (Last 7 Days) ---
    final List<String> dayLabels = [];
    final List<double> dayTotal = [];
    final List<double> dayLoan = [];
    final List<double> dayCash = [];

    // Create 7 buckets (reverse order: 6 days ago -> today)
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dayLabels.add(DateFormat('E').format(date)); // Mon, Tue...

      // Filter txns for this day
      final txns = widget.transactions.where((t) {
        final tDate = t.createdAt;
        if (tDate == null) return false;
        return tDate.year == date.year &&
            tDate.month == date.month &&
            tDate.day == date.day;
      });

      double total = 0;
      double loan = 0;
      double cash = 0;

      for (var t in txns) {
        // Logic:
        // Cash: Income, Payment, Cash, Credit
        // Loan: Loan, Expense (Expense is arguably not 'Loan' but negative cash...
        // for simplicity, let's treat Loan as 'Credit Used/Loan' and Expense as separate or ignored in 'Cash' graph?
        // User requirements: "Total, Loan, Cash"

        bool isLoanType = ['Loan'].contains(t.paymentMethod);
        bool isCashType = [
          'Income',
          'Payment',
          'Cash',
          'Credit',
        ].contains(t.paymentMethod);
        // Note: 'Expense' usually means money out, so not 'Cash IN'.

        if (isLoanType) {
          loan += t.totalAmount;
          total += t.totalAmount; // Add to activity volume
        } else if (isCashType) {
          cash += t.totalAmount;
          total += t.totalAmount;
        }
      }
      dayTotal.add(total);
      dayLoan.add(loan);
      dayCash.add(cash);
    }
    _processedData['Day'] = [dayTotal, dayLoan, dayCash];
    _labels['Day'] = dayLabels;

    // --- Process Month (Last 12 Months) ---
    final List<String> monthLabels = [];
    final List<double> monthTotal = [];
    final List<double> monthLoan = [];
    final List<double> monthCash = [];

    for (int i = 11; i >= 0; i--) {
      // Logic to get month start date
      final d = DateTime(now.year, now.month - i, 1);
      monthLabels.add(DateFormat('MMM').format(d));

      final txns = widget.transactions.where((t) {
        final tDate = t.createdAt;
        if (tDate == null) return false;
        return tDate.year == d.year && tDate.month == d.month;
      });

      double total = 0;
      double loan = 0;
      double cash = 0;
      for (var t in txns) {
        bool isLoanType = ['Loan'].contains(t.paymentMethod);
        bool isCashType = [
          'Income',
          'Payment',
          'Cash',
          'Credit',
        ].contains(t.paymentMethod);
        if (isLoanType) {
          loan += t.totalAmount;
          total += t.totalAmount;
        } else if (isCashType) {
          cash += t.totalAmount;
          total += t.totalAmount;
        }
      }
      monthTotal.add(total);
      monthLoan.add(loan);
      monthCash.add(cash);
    }
    _processedData['Month'] = [monthTotal, monthLoan, monthCash];
    _labels['Month'] = monthLabels;

    // --- Process Year (Last 5 Years) ---
    final List<String> yearLabels = [];
    final List<double> yearTotal = [];
    final List<double> yearLoan = [];
    final List<double> yearCash = [];

    for (int i = 4; i >= 0; i--) {
      final y = now.year - i;
      yearLabels.add(y.toString());

      final txns = widget.transactions.where((t) {
        final tDate = t.createdAt;
        if (tDate == null) return false;
        return tDate.year == y;
      });

      double total = 0;
      double loan = 0;
      double cash = 0;
      for (var t in txns) {
        bool isLoanType = ['Loan'].contains(t.paymentMethod);
        bool isCashType = [
          'Income',
          'Payment',
          'Cash',
          'Credit',
        ].contains(t.paymentMethod);
        if (isLoanType) {
          loan += t.totalAmount;
          total += t.totalAmount;
        } else if (isCashType) {
          cash += t.totalAmount;
          total += t.totalAmount;
        }
      }
      yearTotal.add(total);
      yearLoan.add(loan);
      yearCash.add(cash);
    }
    _processedData['Year'] = [yearTotal, yearLoan, yearCash];
    _labels['Year'] = yearLabels;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
        child: const SizedBox(
          height: 300,
          child: Center(child: Text('No transaction data')),
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
                            // Skip labels on small screens if many items
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
                      ((_processedData[_selectedFilter]?[0].length ?? 1) - 1)
                          .toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    if (_showTotal)
                      _buildLineChartBarData(
                        _processedData[_selectedFilter]![0],
                        const Color(0xFF2196F3), // Professional Blue
                        true,
                      ),
                    if (_showLoan)
                      _buildLineChartBarData(
                        _processedData[_selectedFilter]![1],
                        const Color(0xFFFFC107), // Professional Amber
                        false,
                      ),
                    if (_showCash)
                      _buildLineChartBarData(
                        _processedData[_selectedFilter]![2],
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
    // Find max value across all datasets for current filter
    double max = 0;
    final datasets = _processedData[_selectedFilter] ?? [];
    for (var dataset in datasets) {
      for (var value in dataset) {
        if (value > max) max = value;
      }
    }
    return max == 0 ? 10 : max * 1.2; // Add buffer
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
