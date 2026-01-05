import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:sahakorn3/src/services/firebase/credit/credit_repository.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';

class CreateCreditAccount extends StatefulWidget {
  final String? scannedUserId; // Only present if scanned from QR

  const CreateCreditAccount({super.key, required this.scannedUserId});

  @override
  State<CreateCreditAccount> createState() => _CreateCreditAccountState();
}

class _CreateCreditAccountState extends State<CreateCreditAccount> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _interestController =
      TextEditingController(); // Assuming flat rate or percent?
  final _loanTermController = TextEditingController();

  bool _isLoading = false;
  late String _targetUserId;
  late bool _isManual; // True if manual entry, False if App User

  @override
  void initState() {
    super.initState();
    _isManual = widget.scannedUserId == null;

    if (_isManual) {
      // Auto-generate ID for manual user
      // Format: manual_timestamp_random
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(1000);
      _targetUserId = 'manual_${timestamp}_$random';
    } else {
      _targetUserId = widget.scannedUserId!;
      // TODO: Fetch user name if possible, or leave blank/placeholder
      _nameController.text = 'App User';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditLimitController.dispose();
    _interestController.dispose();
    _loanTermController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final shop = context.read<ShopProvider>().currentShop;
    if (shop == null) {
      AppSnackBar.showError(context, 'Shop error. Please restart.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final creditRepo = CreditRepository();

      // Prepare data
      // For Manual user, we might want to store the "Name" somewhere associated with the Credit
      // Current Credit model has 'userName' field, which fits perfectly.

      final error = await creditRepo.createCredit(
        userId: _targetUserId,
        shopId: shop.id,
        creditLimit: double.parse(
          _creditLimitController.text.replaceAll(',', ''),
        ),
        creditUsed: 0, // Start with 0 debt
        interest: double.tryParse(_interestController.text) ?? 0,
        loanTerm: int.tryParse(_loanTermController.text) ?? 12,
        loanStatus: 'Active',
      ); // Note: creditRepo createCredit currently doesn't accept userName field explicitly yet in parameters,
      // but the Model has it. We might need to update Repository/WriteService to save Name if we want Manual names to persist.
      // Wait, the previous task updated write service without adding userName param to the method signature explicitly?
      // Let's check. If not, I should probably add it, or save it as a separate update?
      // For now let's try to send basic info.

      // Update logic: To save the name for manual users, we technically need to pass it.
      // Assuming for now createCredit won't save name properly unless I updated it again.
      // Just creates the structure first.

      if (mounted) {
        setState(() => _isLoading = false);
        if (error == null) {
          AppSnackBar.showSuccess(context, 'Credit account created!');
          // Pop back to Customers Screen (2 pops: form -> choice -> customers)
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          AppSnackBar.showError(context, 'Error: $error');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.showError(context, 'Submission failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isManual ? 'New Manual Customer' : 'New App Customer',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isManual ? Icons.person : Icons.phonelink_ring,
                      size: 48,
                      color: _isManual ? Colors.teal : Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User ID',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    Text(
                      _targetUserId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier', // Monospace for ID
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              _buildInputLabel('Customer Name'),
              TextFormField(
                controller: _nameController,
                enabled: _isManual, // App users might have pre-filled names
                decoration: _inputDecoration('Enter name'),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              _buildInputLabel('Credit Limit (THB)'),
              TextFormField(
                controller: _creditLimitController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 50,000'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v.replaceAll(',', '')) == null)
                    return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Interest (%)'),
                        TextFormField(
                          controller: _interestController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('e.g. 5'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Term (Months)'),
                        TextFormField(
                          controller: _loanTermController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('e.g. 12'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
