import 'package:flutter/material.dart';

class CustomerCredit extends StatelessWidget {
  const CustomerCredit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Credit', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('View credit limits, dues and make a payment.'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available Credit', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      const Text('\$3,500', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: 0.35),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () {}, child: const Text('Make a Payment')),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.payment),
                    title: Text('Invoice #${200 + i}'),
                    subtitle: const Text('Due: 3 days'),
                    trailing: const Text('-\$45.00'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
