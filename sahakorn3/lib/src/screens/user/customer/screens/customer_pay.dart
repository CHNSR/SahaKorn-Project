import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/models/transaction.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';

class CustomerPay extends StatefulWidget {
  const CustomerPay({super.key});

  @override
  State<CustomerPay> createState() => _CustomerPayState();
}

class _CustomerPayState extends State<CustomerPay> {
  // Helper to update transaction status
  Future<void> _updateStatus(
    BuildContext context,
    AppTransaction transaction,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.docId) // Use docId from model
          .update({'status': status});

      if (mounted) {
        if (status == 'completed') {
          AppSnackBar.showSuccess(context, 'Payment Successful!');
        } else {
          AppSnackBar.showInfo(context, 'Transaction Cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error updating transaction: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserInformationProvider>();
    final uid = userProvider.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to use this feature.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('transactions')
                  .where('user_id', isEqualTo: uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Check if there are any pending transactions
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              // Get the first pending transaction (FIFO usually best, or handle lists)
              // For simplicity, we handle one at a time.
              final doc = snapshot.data!.docs.first;
              final transaction = AppTransaction.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );

              return _buildConfirmationUI(transaction);
            }

            // Default: Show QR Code
            return _buildQrUI(uid);
          },
        ),
      ),
    );
  }

  Widget _buildQrUI(String uid) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Scan to Pay',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Show this QR code to the cashier',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),

          // QR Card
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                width: 250,
                height: 250,
                child: PrettyQrView.data(
                  data: uid, // Sending raw UID as requested/planned
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Waiting indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Waiting for shop...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationUI(AppTransaction transaction) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Payment Request',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please confirm the transaction details below',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Shop ID',
                    transaction.shopId,
                  ), // Could fetch name if we had ShopService
                  const Divider(height: 24),
                  _buildDetailRow('Category', transaction.category),
                  const Divider(height: 24),
                  _buildDetailRow('Detail', transaction.detail ?? '-'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '฿${transaction.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        () => _updateStatus(context, transaction, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _updateStatus(context, transaction, 'completed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Confirm Pay'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
