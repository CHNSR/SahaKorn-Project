import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/app_theme.dart';
import '../../../../services/firebase/transaction/transaction_repository.dart';
import '../../../../utils/custom_snackbar.dart';

class ExportTransaction extends StatefulWidget {
  final TransactionRepository? repository;

  const ExportTransaction({super.key, this.repository});

  @override
  State<ExportTransaction> createState() => _ExportTransactionState();
}

class _ExportTransactionState extends State<ExportTransaction> {
  late final TransactionRepository _repo;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? TransactionRepository();

    // Default to current month
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Future<void> _exportData() async {
    if (_selectedDateRange == null) return;

    setState(() => _isLoading = true);

    try {
      // Fetch all (or implement better filtering later)
      // Since repo.listAll doesn't support complex filter, we fetch limit 500 for now or update repo
      // Assuming listAll can fetch enough. For production, should use a query.
      final transactions = await _repo.listAll(
        limit: 500,
      ); // Fetch a reasonable amount

      // Filter by date range client-side
      final filtered =
          transactions.where((t) {
            if (t.createdAt == null) return false;
            final start = _selectedDateRange!.start;
            final end = _selectedDateRange!.end
                .add(const Duration(days: 1))
                .subtract(const Duration(seconds: 1));
            return t.createdAt!.isAfter(start) && t.createdAt!.isBefore(end);
          }).toList();

      if (filtered.isEmpty) {
        if (mounted) {
          AppSnackBar.showInfo(
            context,
            'No transactions found in selected range.',
          );
        }
        return;
      }

      // Generate CSV
      List<List<dynamic>> rows = [];
      rows.add([
        'Transaction ID',
        'Date',
        'Time',
        'Category',
        'Payment Method',
        'Detail',
        'Amount',
        'User ID',
      ]); // Header

      for (var t in filtered) {
        rows.add([
          t.transactionId,
          DateFormat('yyyy-MM-dd').format(t.createdAt ?? DateTime.now()),
          DateFormat('HH:mm:ss').format(t.createdAt ?? DateTime.now()),
          t.category,
          t.paymentMethod,
          t.detail ?? '',
          t.totalAmount,
          t.userId,
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/transactions_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      // Share
      if (mounted) {
        await Share.shareXFiles([XFile(path)], text: 'Transaction Export');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Export Transactions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDateRange != null
                                  ? '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                                  : 'Select Range',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _exportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Export to CSV',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
