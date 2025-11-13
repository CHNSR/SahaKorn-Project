import 'package:flutter/material.dart';

class ShopCredit extends StatefulWidget {
  const ShopCredit({super.key});

  @override
  State<ShopCredit> createState() => _ShopCreditState();
}

class _ShopCreditState extends State<ShopCredit> {
  final double creditLimit = 20000.0;
  final double currentBalance = 5300.50; // amount owed

  final List<CreditTransaction> recent = [
    CreditTransaction(title: 'Grocery Store', date: '24 Aug 2025', amount: -250.50),
    CreditTransaction(title: 'Online Purchase', date: '20 Aug 2025', amount: -1200.00),
    CreditTransaction(title: 'Refund', date: '18 Aug 2025', amount: 150.00),
  ];

  @override
  Widget build(BuildContext context) {
    final available = creditLimit - currentBalance;
    final double usedRatio = (currentBalance / creditLimit).clamp(0.0, 1.0);

    return Scaffold(
      // remove AppBar, use a header inside the body to give a web-like dashboard feel
      body: SafeArea(
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
                        Text('Credit', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                        const SizedBox(height: 6),
                        Text('Manage credit card, payments, and statements', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_card), label: const Text('Add Card')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Card visual and summary stacked
              _buildCardVisual(),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Credit Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Credit Limit', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 6),
                              Text('${creditLimit.toStringAsFixed(2)} ฿', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Available', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 6),
                              Text('${available.toStringAsFixed(2)} ฿', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: usedRatio, minHeight: 8, color: Colors.redAccent, backgroundColor: Colors.green[50]),
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

              const SizedBox(height: 16),
              const Text('Recent Credit Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // recent list inside Expanded
              Expanded(
                child: ListView.separated(
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = recent[index];
                    final isCredit = t.amount > 0;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
                          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red),
                        ),
                        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(t.date, style: const TextStyle(color: Colors.black54)),
                        trailing: Text('${t.amount > 0 ? '+' : '-'}${t.amount.abs().toStringAsFixed(2)} ฿', style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        onTap: () {},
                      ),
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

  Widget _buildCardVisual() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Platinum Card', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text('**** **** **** 1234', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Valid\nuntil', style: TextStyle(color: Colors.white70), textAlign: TextAlign.right),
                  SizedBox(height: 6),
                  Text('08/27', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Balance owed', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text('${currentBalance.toStringAsFixed(2)} ฿', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
class CreditTransaction {
  final String title;
  final String date;
  final double amount;

  CreditTransaction({required this.title, required this.date, required this.amount});
}
