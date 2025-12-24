import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

class TransactionHeatmap extends StatefulWidget {
  const TransactionHeatmap({super.key});

  @override
  State<TransactionHeatmap> createState() => _TransactionHeatmapState();
}

class _TransactionHeatmapState extends State<TransactionHeatmap> {
  String _selectedView = 'Day'; // Day, Month, Year

  // Mock Data
  final Map<DateTime, int> _dayData = {
    DateTime.now(): 15,
    DateTime.now().subtract(const Duration(days: 2)): 8,
    DateTime.now().subtract(const Duration(days: 4)): 12,
    DateTime.now().subtract(const Duration(days: 5)): 20,
    DateTime.now().subtract(const Duration(days: 10)): 5,
    DateTime.now().subtract(const Duration(days: 15)): 10,
    DateTime.now().subtract(const Duration(days: 25)): 30,
    DateTime(2024, 1, 1): 1,
  };

  final Map<int, int> _monthData = {
    // Month index 1-12 : count
    1: 450, 2: 320, 3: 550, 4: 400, 5: 600, 6: 280,
    7: 500, 8: 700, 9: 450, 10: 620, 11: 400, 12: 500,
  };

  final Map<int, int> _yearData = {
    // Year : count
    2021: 15000,
    2022: 22000,
    2023: 18000,
    2024: 25000,
    2025: 5000,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                _buildViewSelector(),
              ],
            ),
            const SizedBox(height: 24),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            ['Day', 'Month', 'Year'].map((view) {
              final isSelected = _selectedView == view;
              return GestureDetector(
                onTap: () => setState(() => _selectedView = view),
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
                    view,
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

  Widget _buildContent() {
    switch (_selectedView) {
      case 'Day':
        return _buildDayHeatmap();
      case 'Month':
        return _buildMonthGrid();
      case 'Year':
        return _buildYearGrid();
      default:
        return _buildDayHeatmap();
    }
  }

  Widget _buildDayHeatmap() {
    return HeatMap(
      datasets: _dayData,
      colorMode: ColorMode.opacity,
      showText: false,
      scrollable: true,
      colorsets: {
        1: Colors.green.shade50,
        5: Colors.green.shade100,
        10: Colors.green.shade300,
        15: Colors.green.shade500,
        20: Colors.green.shade700,
        30: Colors.green.shade900,
      },
      onClick: (value) {
        // Handle click
      },
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      endDate: DateTime.now(),
      size: 24, // Block size
      textColor: Colors.black54,
    );
  }

  Widget _buildMonthGrid() {
    // 12 Months Grid
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 columns = 2 rows
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthIndex = index + 1;
        final count = _monthData[monthIndex] ?? 0;
        final opacity = (count / 800).clamp(0.2, 1.0); // Normalize mock max 800

        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(opacity),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM').format(DateTime(2024, monthIndex)),
                style: TextStyle(
                  color: opacity > 0.5 ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${count} txn',
                style: TextStyle(
                  color: opacity > 0.5 ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearGrid() {
    // Simple vertical list for years as columns might be too wide or few items
    final sortedYears = _yearData.keys.toList()..sort();

    return SizedBox(
      height: 120, // fixed height for row
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sortedYears.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final year = sortedYears[index];
          final count = _yearData[year] ?? 0;
          final maxCount = 25000; // Mock Max
          final heightFactor = (count / maxCount).clamp(0.2, 1.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 100 * heightFactor,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${(count / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                year.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
