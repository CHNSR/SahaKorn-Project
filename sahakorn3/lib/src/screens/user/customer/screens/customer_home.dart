import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/routes/routes.dart';
import 'package:sahakorn3/src/services/firebase/transaction/transaction_repository.dart';
import 'package:sahakorn3/src/services/firebase/credit/credit_repository.dart';
import 'package:sahakorn3/src/services/firebase/shop/shop_repository.dart';
import 'package:sahakorn3/src/models/transaction.dart';
import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/models/credit.dart';
import 'package:intl/intl.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final TransactionRepository _txRepository = TransactionRepository();
  final CreditRepository _creditRepository = CreditRepository();
  final ShopRepository _shopRepository = ShopRepository();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserInformationProvider>();
    final uid = userProvider.uid;

    if (uid == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting Header
            _buildHeader(userProvider),
            const SizedBox(height: 24),

            // 2. Credit Summary Card
            _buildCreditCard(uid),
            const SizedBox(height: 24),

            // 3. Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // 4. Active Shops (Updated)
            const Text(
              'Your Shops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildActiveShops(uid),
            const SizedBox(height: 24),

            // 5. Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentActivity(uid),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserInformationProvider userProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              userProvider.displayName ?? 'Valued Customer',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.indigo.shade50,
          child: Text(
            (userProvider.displayName ?? 'C')[0].toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCard(String uid) {
    return FutureBuilder<double>(
      future: _txRepository.fetchTotalUnpaidByCustomer(uid),
      builder: (context, snapshot) {
        final totalUnpaid = snapshot.data ?? 0.0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.indigo.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.shade200.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Debt',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.credit_card, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : Text(
                    NumberFormat.currency(symbol: '฿').format(totalUnpaid),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                'Unpaid Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.qr_code,
            label: 'My QR Code',
            color: Colors.teal,
            onTap: () => Navigator.pushNamed(context, Routes.myQrCode),
          ),
        ),
        const SizedBox(width: 16),
        // Placeholder for future actions (e.g., Search Shop)
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.store,
            label: 'Find Shops',
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, Routes.searchShop);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveShops(String uid) {
    return FutureBuilder<Credit?>(
      future: _creditRepository.getCreditByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final credit = snapshot.data;
        if (credit == null) {
          return _buildEmptyState('No active credit accounts');
        }

        // Fetch Shop Details
        return FutureBuilder<Shop?>(
          future: _shopRepository.getShopById(credit.shopId),
          builder: (context, shopSnapshot) {
            if (shopSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final shop = shopSnapshot.data;
            if (shop == null) return const SizedBox.shrink();

            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.customerShop,
                  arguments: shop,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.store, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Credit Limit: ${NumberFormat.currency(symbol: '฿').format(credit.creditLimit)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(String uid) {
    return StreamBuilder<List<AppTransaction>>(
      stream: _txRepository.watchTransactionsByCustomer(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return _buildEmptyState('No recent activity');
        }

        // Show top 5
        final recent = transactions.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final tx = recent[index];
            final isDebt = tx.paymentMethod == 'Credit';
            final color = isDebt ? Colors.red : Colors.green;
            // Removed unused 'sign' variable

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
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
                  tx.category, // Or Shop Name if we fetched it
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
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
