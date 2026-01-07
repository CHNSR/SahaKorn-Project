import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:sahakorn3/src/services/firebase/credit/credit_repository.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';

class CreateCreditAccount extends StatefulWidget {
  final String? scannedUserId;

  const CreateCreditAccount({super.key, required this.scannedUserId});

  @override
  State<CreateCreditAccount> createState() => _CreateCreditAccountState();
}

class _CreateCreditAccountState extends State<CreateCreditAccount> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Note: default credit limit 0 initially, or managed elsewhere?
  // User asked to remove the field, so we default to 0.
  final double _defaultCreditLimit = 0.0;

  String? _selectedGender;
  bool _isLoading = false;
  late String _targetUserId;
  late bool _isManual;

  @override
  void initState() {
    super.initState();
    _isManual = widget.scannedUserId == null;

    if (_isManual) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(1000);
      _targetUserId = 'manual_${timestamp}_$random';
    } else {
      _targetUserId = widget.scannedUserId!;
      _nameController.text = 'App User';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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

      final error = await creditRepo.createCredit(
        userId: _targetUserId,
        shopId: shop.id,
        creditLimit: _defaultCreditLimit,
        creditUsed: 0,
        interest:
            0, // Default interest 0? or needed? Assuming 0 for initial setup
        loanTerm: 12, // Default 12 months?
        loanStatus: 'Active',
        userName: _nameController.text,
        gender: _selectedGender,
        age: int.tryParse(_ageController.text),
        phoneNumber: _phoneController.text,
        address: _addressController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (error == null) {
          AppSnackBar.showSuccess(context, 'Customer Profile Created!');
          Navigator.pop(context); // Go back
          Navigator.pop(context); // Go back to main list
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
      backgroundColor: Colors.grey[50], // Professional light grey background
      appBar: AppBar(
        title: const Text(
          'New Customer Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Identity Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF185a9d), Color(0xFF43cea2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF185a9d).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isManual ? Icons.person_add : Icons.phonelink_ring,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isManual ? 'Manual Entry' : 'Scanned User',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _targetUserId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Name Field
              _buildInputLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                enabled: _isManual,
                decoration: _buildInputDecoration(
                  'Enter full name',
                  Icons.person,
                ),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              // Row 1: Gender & Age
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Gender'),
                        DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration('Select', Icons.wc),
                          value: _selectedGender,
                          items:
                              ['Male', 'Female', 'Other']
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedGender = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Age'),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Age', Icons.cake),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Phone Number
              _buildInputLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration(
                  '08X-XXX-XXXX',
                  Icons.phone_android,
                ),
              ),
              const SizedBox(height: 20),

              // Address
              _buildInputLabel('Current Address'),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  'House No., Street, City',
                  Icons.location_on,
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185a9d),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF185a9d).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF185a9d), width: 1.5),
      ),
    );
  }
}
