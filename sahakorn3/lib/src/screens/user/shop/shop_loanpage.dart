import 'package:flutter/material.dart';
import 'package:sahakorn3/src/screens/user/shop/widgets/loan_usage_chart.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class ShopCredit extends StatefulWidget {
  const ShopCredit({super.key});

  @override
  State<ShopCredit> createState() => _ShopCreditState();
}

class _ShopCreditState extends State<ShopCredit> {
  final double creditLimit = 20000.0;
  final double currentBalance = 5300.50; // amount owed

  final List<Map<String, dynamic>> activeLoans = [
    {'name': 'Somchai Jaidee', 'amount': 5000.0, 'date': '2025-08-20'},
    {'name': 'Somsri Rakthai', 'amount': 1500.0, 'date': '2025-08-22'},
    {'name': 'Mana Meesu', 'amount': 300.0, 'date': '2025-08-24'},
  ];

  @override
  Widget build(BuildContext context) {
    final available = creditLimit - currentBalance;
    final double usedRatio = (currentBalance / creditLimit).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage customer loans',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.switch_access_shortcut_add_outlined,
                          ),
                          label: const Text('Switch Shop'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total loan in this shop.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Loan used',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Formatters.formatBaht(creditLimit),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Loan available',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Formatters.formatBaht(available),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: usedRatio,
                          minHeight: 8,
                          color: Colors.redAccent,
                          backgroundColor: Colors.green[50],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.payment),
                                label: const Text('Make Payment'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.receipt_long),
                              label: const Text('Statement'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const LoanUsageChart(),
                const SizedBox(height: 24),
                const Text(
                  'Loan Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Quick Actions Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildActionCard(
                      icon: Icons.monetization_on,
                      color: Colors.blue,
                      label: 'Give Loan',
                      onTap: () {},
                    ),
                    _buildActionCard(
                      icon: Icons.payment,
                      color: Colors.green,
                      label: 'Repayment',
                      onTap: () {},
                    ),
                    _buildActionCard(
                      icon: Icons.people,
                      color: Colors.orange,
                      label: 'Customers',
                      onTap: () {},
                    ),
                    _buildActionCard(
                      icon: Icons.history,
                      color: Colors.purple,
                      label: 'History',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
