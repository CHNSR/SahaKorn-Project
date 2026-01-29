import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class ManageTotalCredit extends StatefulWidget {
  const ManageTotalCredit({super.key});

  @override
  State<ManageTotalCredit> createState() => _ManageTotalCreditState();
}

class _ManageTotalCreditState extends State<ManageTotalCredit> {
  final TextEditingController _creditController = TextEditingController();
  final CreditRepository _creditRepo = CreditRepository();
  final ShopRepository _shopRepo = ShopRepository();

  String _transactionType = 'Add'; // 'Add' or 'Reduce'

  double _usedCredit = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final shop = context.read<ShopProvider>().currentShop;
    if (shop != null) {
      setState(() => _isLoading = true);
      final used = await _creditRepo.countTotalAmountDistributedCredit(
        shopId: shop.id,
      );
      if (mounted) {
        setState(() {
          _usedCredit = used ?? 0.0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _creditController.dispose();
    super.dispose();
  }

  Future<void> _manageCredit() async {
    final shop = context.read<ShopProvider>().currentShop;
    if (shop == null) return;

    if (_creditController.text.isNotEmpty) {
      final double? amount = double.tryParse(
        _creditController.text.replaceAll(',', ''),
      );

      if (amount != null) {
        final double totalCredit = shop.creditLimit;

        if (_transactionType == 'Reduce' &&
            amount > (totalCredit - _usedCredit)) {
          AppSnackBar.showError(
            context,
            'Cannot reduce more than total Available Credit!',
          );
          return;
        }

        setState(() => _isLoading = true);

        try {
          double newLimit = totalCredit;
          if (_transactionType == 'Add') {
            newLimit += amount;
          } else {
            newLimit -= amount;
          }

          await _shopRepo.updateShop(shop.id, {'creditLimit': newLimit});

          if (mounted) {
            await context.read<ShopProvider>().loadShops(shop.ownerId);
            _creditController.clear();

            AppSnackBar.showSuccess(
              context,
              'Credit limit ${_transactionType == 'Add' ? 'increased' : 'reduced'} successfully!',
            );
          }
        } catch (e) {
          if (mounted) {
            AppSnackBar.showError(context, 'Error updating credit: $e');
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>().currentShop;
    if (shop == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double availableCredit = shop.creditLimit - _usedCredit;
    if (availableCredit < 0) availableCredit = 0;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Professional background
      appBar: AppBar(
        title: const Text(
          'Credit Management',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            // Analytics Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Portfolio Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 70,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF185a9d), // Deep Indigo
                                value: availableCredit,
                                radius: 25,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFff5252), // Soft Red
                                value: _usedCredit,
                                radius: 25,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatBaht(shop.creditLimit),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: const Color(0xFF185a9d),
                        label: 'Available',
                        value: availableCredit,
                      ),
                      const SizedBox(width: 40),
                      _buildLegendItem(
                        color: const Color(0xFFff5252), // Soft Red
                        label: 'Distributed',
                        value: _usedCredit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Management Action Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modify Credit Limit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Custom Segmented Control
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentButton(
                          'Add',
                          isActive: _transactionType == 'Add',
                          color: const Color(0xFF4caf50),
                        ),
                        _buildSegmentButton(
                          'Reduce',
                          isActive: _transactionType == 'Reduce',
                          color: const Color(0xFFff5252),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount Input
                  TextFormField(
                    controller: _creditController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      suffixText: 'THB',
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(
                        _transactionType == 'Add'
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              _transactionType == 'Add'
                                  ? const Color(0xFF4caf50)
                                  : const Color(0xFFff5252),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _manageCredit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _transactionType == 'Add'
                                ? const Color(0xFF4caf50)
                                : const Color(0xFFff5252),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: (_transactionType == 'Add'
                                ? const Color(0xFF4caf50)
                                : const Color(0xFFff5252))
                            .withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                _transactionType == 'Add'
                                    ? 'Increase Limit'
                                    : 'Reduce Limit',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(
    String label, {
    required bool isActive,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _transactionType = label;
            _creditController.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isActive ? color : Colors.grey[600],
            ),
          ),
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
