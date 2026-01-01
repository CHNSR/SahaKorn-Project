import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../../../models/transaction.dart';
import '../../../../services/firebase/transaction/transaction_repository.dart';
import '../../../../utils/custom_snackbar.dart';

class ConfigTransaction extends StatefulWidget {
  final AppTransaction transaction;
  final TransactionRepository? repository;

  const ConfigTransaction({
    super.key,
    required this.transaction,
    this.repository,
  });

  @override
  State<ConfigTransaction> createState() => _ConfigTransactionState();
}

class _ConfigTransactionState extends State<ConfigTransaction> {
  late TextEditingController _detailController;
  late TextEditingController _amountController;
  late String _paymentMethod;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Income',
    'Expense',
    'Loan',
    'Payment',
    'Cash',
    'Credit',
  ];
  late final TransactionRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? TransactionRepository();
    _detailController = TextEditingController(
      text: widget.transaction.detail ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction.totalAmount.toString(),
    );
    _paymentMethod =
        _paymentMethods.contains(widget.transaction.paymentMethod)
            ? widget.transaction.paymentMethod
            : _paymentMethods.first;
    _selectedDate = widget.transaction.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _detailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    // Simple validation
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    // Check for changes
    final Map<String, dynamic> changes = {};
    if (widget.transaction.detail != _detailController.text) {
      changes['detail'] = {
        'old': widget.transaction.detail,
        'new': _detailController.text,
      };
    }
    // Compare amounts with tolerance
    if ((widget.transaction.totalAmount - amount).abs() > 0.001) {
      changes['totalAmount'] = {
        'old': widget.transaction.totalAmount,
        'new': amount,
      };
    }
    if (widget.transaction.paymentMethod != _paymentMethod) {
      changes['paymentMethod'] = {
        'old': widget.transaction.paymentMethod,
        'new': _paymentMethod,
      };
    }
    // Note: Date/Time changes not tracked for simplicity unless requested

    final updatedData = {
      'detail': _detailController.text,
      'total_amount': amount,
      'payment_method': _paymentMethod,
      'created_at': _selectedDate.millisecondsSinceEpoch ~/ 1000,
    };

    if (changes.isNotEmpty) {
      final newHistoryItem = {
        'edited_at':
            DateTime.now().millisecondsSinceEpoch ~/ 1000, // as int timestamp
        'changes': changes,
      };

      final currentHistory = widget.transaction.editHistory ?? [];
      updatedData['edit_history'] = [...currentHistory, newHistoryItem];
    }

    try {
      final error = await _repo.update(
        widget.transaction.docId ?? widget.transaction.transactionId,
        updatedData,
      );
      if (error == null) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          AppSnackBar.showError(context, 'Error: $error');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final error = await _repo.delete(
        widget.transaction.docId ?? widget.transaction.transactionId,
      );
      if (error == null) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          AppSnackBar.showError(context, 'Error: $error');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Edit Transaction',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _delete,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Details'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _detailController,
                  label: 'Detail',
                  icon: Icons.description_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                _buildSectionLabel('Amount (THB)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _amountController,
                  label: 'Amount',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionLabel('Payment Method'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _paymentMethod,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:
                          _paymentMethods.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _paymentMethod = newValue);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionLabel('Date & Time'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
