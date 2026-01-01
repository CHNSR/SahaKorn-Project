import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';

class GiveLoanScreen extends StatefulWidget {
  const GiveLoanScreen({super.key});

  @override
  State<GiveLoanScreen> createState() => _GiveLoanScreenState();
}

class _GiveLoanScreenState extends State<GiveLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _termMonths = 12;

  // Mock Customers for Dropdown
  final List<Map<String, dynamic>> _customers = [
    {'id': '1', 'name': 'Somchai Jai-dee'},
    {'id': '2', 'name': 'Somsri Rak-ngern'},
    {'id': '3', 'name': 'Mana Me-ngern'},
    {'id': '4', 'name': 'Manee Me-jai'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _submitLoan() {
    if (_formKey.currentState!.validate()) {
      // TODO: Process Loan Creation
      AppSnackBar.showInfo(context, 'Processing Loan...');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Give Loan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Banner Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/loan_banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.grey[50]!, // Blend into background
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 140), // Spacing for banner visibility
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF185a9d,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.assignment_outlined,
                                  color: Color(0xFF185a9d),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Loan Details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Customer Selection
                          _buildLabel('Borrower'),
                          DropdownButtonFormField<String>(
                            decoration: _buildInputDecoration(
                              'Select Customer',
                              Icons.person_outline,
                            ),
                            value: _selectedCustomerId,
                            items:
                                _customers.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c['id'],
                                    child: Text(c['name']),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCustomerId = val;
                              });
                            },
                            validator:
                                (val) =>
                                    val == null
                                        ? 'Please select a customer'
                                        : null,
                          ),
                          const SizedBox(height: 24),

                          // Amount
                          _buildLabel('Loan Amount'),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            decoration: _buildInputDecoration(
                              '0.00',
                              Icons.attach_money,
                            ).copyWith(suffixText: 'THB'),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter amount';
                              if (double.tryParse(value) == null)
                                return 'Invalid amount';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Rowan: Interest & Term
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Interest Rate'),
                                    TextFormField(
                                      controller: _interestController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: _buildInputDecoration(
                                        'Rate',
                                        Icons.percent,
                                      ).copyWith(suffixText: '%/yr'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Duration'),
                                    DropdownButtonFormField<int>(
                                      decoration: _buildInputDecoration(
                                        'Term',
                                        Icons.calendar_today,
                                      ),
                                      value: _termMonths,
                                      items:
                                          [3, 6, 12, 24, 36].map((m) {
                                            return DropdownMenuItem<int>(
                                              value: m,
                                              child: Text('$m M'),
                                            );
                                          }).toList(),
                                      onChanged:
                                          (val) => setState(
                                            () => _termMonths = val!,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Start Date
                          _buildLabel('Start Date'),
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(16),
                            child: InputDecorator(
                              decoration: _buildInputDecoration(
                                'Select Date',
                                Icons.event,
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_startDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitLoan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF185a9d),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: const Color(
                                  0xFF185a9d,
                                ).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Approve Loan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
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
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF185a9d), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[200]!),
      ),
    );
  }
}
