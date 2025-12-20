import 'package:flutter/material.dart';
import '../../../../utils/formatters.dart';

class RepaymentScreen extends StatefulWidget {
  const RepaymentScreen({super.key});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  // Mock Active Loans
  final List<Map<String, dynamic>> _activeLoans = [
    {
      'id': 'L001',
      'customerName': 'Somchai Jai-dee',
      'totalAmount': 20000.0,
      'remainingBalance': 5000.0,
      'dueDate': '2024-05-30',
      'avatarColor': Colors.blue,
    },
    {
      'id': 'L003',
      'customerName': 'Mana Me-ngern',
      'totalAmount': 50000.0,
      'remainingBalance': 12500.0,
      'dueDate': '2024-06-15',
      'avatarColor': Colors.green,
    },
    {
      'id': 'L004',
      'customerName': 'Manee Me-jai',
      'totalAmount': 10000.0,
      'remainingBalance': 9000.0,
      'dueDate': '2024-05-25',
      'avatarColor': Colors.orange,
    },
  ];

  void _showRepaymentDialog(Map<String, dynamic> loan) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Repay Loan: ${loan['customerName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Remaining: ${Formatters.formatBaht(loan['remainingBalance'])}',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Process Repayment
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Repayment recorded for ${loan['id']}'),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repayments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeLoans.length,
        itemBuilder: (context, index) {
          final loan = _activeLoans[index];
          final double progress =
              1.0 - (loan['remainingBalance'] / loan['totalAmount']);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
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
                    children: [
                      CircleAvatar(
                        backgroundColor: loan['avatarColor'].withOpacity(0.2),
                        child: Text(
                          loan['customerName'][0],
                          style: TextStyle(
                            color: loan['avatarColor'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan['customerName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Loan ID: ${loan['id']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: const Text(
                          'Active',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining Balance',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        Formatters.formatBaht(loan['remainingBalance']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${Formatters.formatBaht(loan['totalAmount'])}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% Paid',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${loan['dueDate']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showRepaymentDialog(loan),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text('Repay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
