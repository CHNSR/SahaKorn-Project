import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Home', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Overview and quick actions for the customer.'),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Account Balance'),
                  subtitle: const Text('\$1,240.00'),
                  trailing: ElevatedButton(onPressed: () {}, child: const Text('Top-up')),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, i) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('Order #${1000 + i}'),
                      subtitle: const Text('Status: Delivered'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
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
