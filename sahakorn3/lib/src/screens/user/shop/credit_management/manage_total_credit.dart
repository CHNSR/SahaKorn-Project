import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sahakorn3/src/core/app_theme.dart';
import 'package:sahakorn3/src/utils/formatters.dart';

class ManageTotalCredit extends StatefulWidget {
  const ManageTotalCredit({super.key});

  @override
  State<ManageTotalCredit> createState() => _ManageTotalCreditState();
}

class _ManageTotalCreditState extends State<ManageTotalCredit> {
  final TextEditingController _creditController = TextEditingController();
  String _transactionType = 'Add'; // 'Add' or 'Reduce'

  // Mock Data
  double _totalCredit = 50000;
  double _usedCredit = 15000;

  @override
  void dispose() {
    _creditController.dispose();
    super.dispose();
  }

  void _manageCredit() {
    if (_creditController.text.isNotEmpty) {
      final double? amount = double.tryParse(
        _creditController.text.replaceAll(',', ''),
      );

      if (amount != null) {
        if (_transactionType == 'Reduce' && amount > _totalCredit) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot reduce more than total credit!'),
            ),
          );
          return;
        }

        setState(() {
          if (_transactionType == 'Add') {
            _totalCredit += amount;
          } else {
            _totalCredit -= amount;
            // Ensure total credit doesn't go below used credit?
            // The prompt didn't specify, but usually you shouldn't reduce below usage.
            // For now, let's just update total. If total < used, available will be 0 as per build logic.
          }
          _creditController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Credit limit ${_transactionType == 'Add' ? 'increased' : 'reduced'} successfully!',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double availableCredit = _totalCredit - _usedCredit;
    // Prevent negative available credit visually
    if (availableCredit < 0) availableCredit = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Chart Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Credit Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              startDegreeOffset: -90,
                              sections: [
                                PieChartSectionData(
                                  color: AppColors.primary,
                                  value: availableCredit,
                                  title:
                                      '${((availableCredit / _totalCredit) * 100).toStringAsFixed(1)}%',
                                  radius: 20,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  showTitle:
                                      false, // Cleaner look without titles on donut
                                ),
                                PieChartSectionData(
                                  color: Colors.redAccent,
                                  value: _usedCredit,
                                  title:
                                      '${((_usedCredit / _totalCredit) * 100).toStringAsFixed(1)}%',
                                  radius: 20,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Total Credit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  Formatters.formatBaht(_totalCredit),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(
                          color: AppColors.primary,
                          label: 'Available',
                          value: availableCredit,
                        ),
                        _buildLegendItem(
                          color: Colors.redAccent,
                          label: 'Used',
                          value: _usedCredit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Manage Credit Limit Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Manage Credit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Dropdown for selecting action
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _transactionType,
                              isDense: true,
                              items:
                                  ['Add', 'Reduce'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color:
                                              value == 'Add'
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _transactionType = newValue;
                                    _creditController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText:
                            _transactionType == 'Add'
                                ? 'Enter amount to add'
                                : 'Enter amount to reduce',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _manageCredit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _transactionType == 'Add'
                                  ? AppColors.primary
                                  : Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _transactionType == 'Add'
                              ? 'Add Credit'
                              : 'Reduce Credit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatBaht(value),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
