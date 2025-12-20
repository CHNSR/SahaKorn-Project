import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Processing Loan...')));
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
      appBar: AppBar(title: const Text('Give Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Loan Application',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Customer Selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
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
                    (val) => val == null ? 'Please select a customer' : null,
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Loan Amount (THB)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interest Rate
              TextFormField(
                controller: _interestController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Interest Rate (% per year)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
                initialValue: null, // use controller
              ),
              const SizedBox(height: 16),

              // Term Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Loan Term',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                value: _termMonths,
                items:
                    [3, 6, 12, 24, 36].map((m) {
                      return DropdownMenuItem<int>(
                        value: m,
                        child: Text('$m Months'),
                      );
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    _termMonths = val!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_startDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitLoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Loan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
