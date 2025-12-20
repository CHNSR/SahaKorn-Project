import 'package:flutter/material.dart';
import '../../../../utils/formatters.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mock History Data
  final List<Map<String, dynamic>> _history = [
    {
      'date': '2024-04-20',
      'action': 'Repayment',
      'customer': 'Somchai Jai-dee',
      'amount': 5000.0,
      'isIncome': true,
    },
    {
      'date': '2024-04-18',
      'action': 'Loan Given',
      'customer': 'Manee Me-jai',
      'amount': 10000.0,
      'isIncome': false,
    },
    {
      'date': '2024-04-15',
      'action': 'Loan Given',
      'customer': 'Mana Me-ngern',
      'amount': 50000.0,
      'isIncome': false,
    },
    {
      'date': '2024-04-10',
      'action': 'Repayment',
      'customer': 'Somsri Rak-ngern',
      'amount': 2500.0,
      'isIncome': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          final isIncome = item['isIncome'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isIncome
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                item['action'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['customer']),
                  Text(
                    item['date'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Text(
                '${isIncome ? '+' : '-'} ${Formatters.formatBaht(item['amount'])}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
