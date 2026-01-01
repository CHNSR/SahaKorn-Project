import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../../../models/transaction.dart';
import '../../../../services/firebase/transaction/transaction_repository.dart';
import '../../../../utils/formatters.dart';
import '../../../../utils/custom_snackbar.dart';

class DigitalReceipt extends StatefulWidget {
  const DigitalReceipt({super.key});

  @override
  State<DigitalReceipt> createState() => _DigitalReceiptState();
}

class _DigitalReceiptState extends State<DigitalReceipt> {
  final TransactionRepository _repository = TransactionRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Digital Receipts',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<AppTransaction>>(
        future: _repository.listAll(limit: 50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text('No receipts found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildReceiptItem(context, transactions[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildReceiptItem(BuildContext context, AppTransaction t) {
    return GestureDetector(
      onTap: () => _showReceiptDetail(context, t),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.detail ?? 'Receipt',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(t.createdAt ?? DateTime.now()),
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showReceiptDetail(BuildContext context, AppTransaction t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReceiptDetailSheet(transaction: t),
    );
  }
}

class _ReceiptDetailSheet extends StatelessWidget {
  final AppTransaction transaction;

  const _ReceiptDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          // Receipt Paper
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0), // Paper look
                ),
                child: CustomPaint(
                  painter: ReceiptPainter(), // Jagged edge effect could go here
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 50,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'SAHAKORN SHOP', // Store Name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Tax Invoice (ABB)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 20),

                      _buildRow(
                        'Date',
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(transaction.createdAt ?? DateTime.now()),
                      ),
                      _buildRow(
                        'Time',
                        DateFormat(
                          'HH:mm',
                        ).format(transaction.createdAt ?? DateTime.now()),
                      ),
                      _buildRow(
                        'Receipt No',
                        '#${transaction.transactionId.substring(0, 8)}',
                      ),
                      _buildRow('Method', transaction.paymentMethod),

                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 20),

                      // Edit History
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Edit History',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (transaction.editHistory == null ||
                          transaction.editHistory!.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'None',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        ...transaction.editHistory!.map((history) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            (history['edited_at'] as int) * 1000,
                          );
                          final changes =
                              history['changes'] as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edited on ${DateFormat('dd MMM HH:mm').format(date)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ...changes.entries.map((e) {
                                  final field = e.key;
                                  final oldVal = e.value['old'];
                                  final newVal = e.value['new'];
                                  return Text(
                                    '- $field: $oldVal -> $newVal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 20),
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Items',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              transaction.detail ?? 'Transaction Item',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Text(
                            Formatters.formatBaht(transaction.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            Formatters.formatBaht(
                              transaction.totalAmount,
                              showSign: false,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 200,
                              decoration: BoxDecoration(
                                color:
                                    Colors.grey[200], // Placeholder for Barcode
                              ),
                              child: const Center(
                                child: Text(
                                  '||| ||||||| |||| || ||||',
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Thank you for shopping!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                // Share functionality placeholder
                Navigator.pop(context);
                AppSnackBar.showSuccess(context, 'Receipt Shared!');
              },
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                'Share Receipt',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ReceiptPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Optional: Draw zig-zag line at bottom
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
