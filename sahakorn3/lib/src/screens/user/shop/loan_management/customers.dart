import 'package:flutter/material.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';
import '../../../../utils/formatters.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _customers = [
    {
      'id': '1',
      'name': 'Somchai Jai-dee',
      'phone': '081-234-5678',
      'creditLimit': 20000.0,
      'currentDebt': 5000.0,
      'avatarColor': Colors.blue,
    },
    {
      'id': '2',
      'name': 'Somsri Rak-ngern',
      'phone': '089-876-5432',
      'creditLimit': 15000.0,
      'currentDebt': 0.0,
      'avatarColor': Colors.pink,
    },
    {
      'id': '3',
      'name': 'Mana Me-ngern',
      'phone': '090-111-2222',
      'creditLimit': 50000.0,
      'currentDebt': 12500.0,
      'avatarColor': Colors.green,
    },
    {
      'id': '4',
      'name': 'Manee Me-jai',
      'phone': '085-555-5555',
      'creditLimit': 10000.0,
      'currentDebt': 9000.0,
      'avatarColor': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to Add Customer Screen
              AppSnackBar.showInfo(context, 'Add Customer feature coming soon');
            },
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          final double creditLimit = customer['creditLimit'];
          final double currentDebt = customer['currentDebt'];
          final double availableCredit = creditLimit - currentDebt;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: customer['avatarColor'].withOpacity(0.2),
                child: Text(
                  customer['name'][0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customer['avatarColor'],
                  ),
                ),
              ),
              title: Text(
                customer['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        customer['phone'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Debt: ${Formatters.formatBaht(currentDebt)}',
                        style: TextStyle(
                          color: currentDebt > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Available: ${Formatters.formatBaht(availableCredit)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // TODO: View Customer Details
              },
            ),
          );
        },
      ),
    );
  }
}
