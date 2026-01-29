import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/models/credit.dart';
import 'package:sahakorn3/src/models/transaction.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/services/firebase/credit/credit_repository.dart';
import 'package:sahakorn3/src/services/firebase/transaction/transaction_repository.dart';

class CustomerShop extends StatefulWidget {
  final Shop shop;
  const CustomerShop({super.key, required this.shop});

  @override
  State<CustomerShop> createState() => _CustomerShopState();
}

class _CustomerShopState extends State<CustomerShop> {
  final CreditRepository _creditRepository = CreditRepository();
  final TransactionRepository _txRepository = TransactionRepository();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserInformationProvider>();
    final uid = userProvider.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.shop.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Shop Info Card
            _buildShopInfoCard(),
            const SizedBox(height: 16),

            // 2. Credit Status
            _buildCreditStatus(uid),
            const SizedBox(height: 24),

            // 3. Recent Transactions Header
            const Text(
              'History with this Shop',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // 4. Transaction List
            _buildTransactionList(uid),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.indigo.shade50,
            child: const Icon(Icons.store, size: 30, color: Colors.indigo),
          ),
          const SizedBox(height: 12),
          Text(
            widget.shop.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.shop.address,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          // Removed phoneNumber as it is not in the Shop model
        ],
      ),
    );
  }

  Widget _buildCreditStatus(String uid) {
    return FutureBuilder<Credit?>(
      future: _creditRepository.getCreditByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final credit = snapshot.data;
        // Check if credit belongs to this shop.
        // If null or different shopId, user has no credit here.
        if (credit == null || credit.shopId != widget.shop.id) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                Text(
                  'No active credit account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  'Ask the shop owner to add you.',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ],
            ),
          );
        }

        final available = credit.creditLimit - credit.creditUsed;
        final progress =
            credit.creditLimit > 0
                ? (credit.creditUsed / credit.creditLimit).clamp(0.0, 1.0)
                : 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.indigo.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.shade200,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Credit Limit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: '฿',
                    ).format(credit.creditLimit),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Used',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: '฿',
                        ).format(credit.creditUsed),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Available',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '฿').format(available),
                        style: const TextStyle(
                          color: Color(0xFFb5e48c),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.9 ? Colors.redAccent : Colors.tealAccent,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(String uid) {
    return FutureBuilder<List<AppTransaction>>(
      // We fetch ALL transactions for this customer and filter client-side
      // because we haven't implemented a specific composite query yet.
      // This is acceptable for MVP volume.
      future: _txRepository.fetchForAnalytics(uid, shopId: widget.shop.id),
      // Ideally we should have a 'watchTransactions' that accepts optional shopId,
      // but 'fetchForAnalytics' returns Future<List>. Let's use that for now or watch.
      // Actually 'watchTransactionsByCustomer' is a Stream.
      // Let's us Stream for real-time updates.
      builder: (context, snapshot) {
        // We'll standardly use StreamBuilder with _txRepository.watchTransactionsByCustomer
        // and filter manually here until BE supports it.
        return StreamBuilder<List<AppTransaction>>(
          stream: _txRepository.watchTransactionsByCustomer(uid),
          builder: (context, streamSnap) {
            if (streamSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allTx = streamSnap.data ?? [];
            final shopTx =
                allTx.where((t) => t.shopId == widget.shop.id).toList();

            if (shopTx.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'No transactions with this shop yet.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shopTx.length,
              itemBuilder: (context, index) {
                final tx = shopTx[index];
                final isDebt = tx.paymentMethod == 'Credit';
                final color = isDebt ? Colors.red : Colors.green;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDebt ? Icons.receipt_long : Icons.payment,
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tx.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(tx.createdAt ?? DateTime.now()),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      NumberFormat.currency(symbol: '฿').format(tx.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
