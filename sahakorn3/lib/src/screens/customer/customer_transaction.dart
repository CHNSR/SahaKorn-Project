import 'package:flutter/material.dart';

class CustomerTransaction extends StatelessWidget {
  const CustomerTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(10, (i) => MapEntry('TXN#${300 + i}', '-\$${(i+1) * 12}.00'));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transactions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final e = items[i];
                    return ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: Text(e.key),
                      trailing: Text(e.value),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
