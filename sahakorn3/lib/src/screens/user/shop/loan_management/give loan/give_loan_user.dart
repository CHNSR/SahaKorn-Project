import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class GiveLoanUserScreen extends StatefulWidget {
  const GiveLoanUserScreen({super.key});

  @override
  State<GiveLoanUserScreen> createState() => _GiveLoanUserScreenState();
}

class _GiveLoanUserScreenState extends State<GiveLoanUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _termMonths = 12;
  bool _isLoading = false;
  double _totalLoanAmount = 0.0;

  // Repositories
  final CreditRepository _creditRepo = CreditRepository();
  final CreditTransactionRepository _transactionRepo =
      CreditTransactionRepository();
  List<Credit> _credits = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final shopId = context.read<ShopProvider>().currentShop?.id;
    if (shopId == null) return;

    try {
      final credits = await _creditRepo.getCreditsByShop(shopId);
      final totalLoan =
          await _creditRepo.countTotalAmountLoan(shopId: shopId) ?? 0.0;

      if (mounted) {
        setState(() {
          // Only show customers with 0 Credit Limit (Profiles with no active credit line)
          _credits = credits.where((c) => c.creditLimit <= 0).toList();
          _totalLoanAmount = totalLoan;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error fetching data: $e');
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _submitLoan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final shop = context.read<ShopProvider>().currentShop;
      if (shop == null) {
        AppSnackBar.showError(context, 'Shop ID Not Found');
        setState(() => _isLoading = false);
        return;
      }

      final amount = double.parse(_amountController.text);

      // Check Shop Budget Stamina
      if (_totalLoanAmount + amount > shop.creditLimit) {
        AppSnackBar.showError(context, 'Shop credit budget exceeded!');
        setState(() => _isLoading = false);
        return;
      }

      final note = 'Credit Limit Granted: ${amount.toStringAsFixed(0)} THB';

      try {
        final error = await _transactionRepo.grantCreditLimit(
          creditId: _selectedCustomerId!,
          userId: _selectedCustomerId!,
          shopId: shop.id,
          amount: amount,
          note: note,
        );

        if (error == null) {
          if (mounted) {
            AppSnackBar.showSuccess(
              context,
              'Credit Limit Granted Successfully',
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) AppSnackBar.showError(context, error);
        }
      } catch (e) {
        if (mounted) AppSnackBar.showError(context, e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
    final shop = context.watch<ShopProvider>().currentShop;
    final shopLimit = shop?.creditLimit ?? 1.0; // Avoid div by 0
    // If limit is 0, allow infinite? Or assume 0? User asked for stamina, user likely has limit.
    // If shopLimit is 0 (unlimited/not set), we might treat as 100% or 0%. Let's assume it's set.
    final usagePercent =
        (shopLimit > 0) ? (_totalLoanAmount / shopLimit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Grant Credit Limit',
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
                  const SizedBox(height: 120), // Reduced spacing slightly
                  // Credit Stamina Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 15,
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
                            const Text(
                              'Shop Budget Stamina',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${(usagePercent * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    usagePercent > 0.9
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: usagePercent,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              usagePercent > 0.9
                                  ? Colors.red
                                  : usagePercent > 0.7
                                  ? Colors.orange
                                  : const Color(0xFF43cea2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Used: ${NumberFormat('#,##0').format(_totalLoanAmount)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Limit: ${NumberFormat('#,##0').format(shopLimit)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

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
                          // Customer Selection
                          _buildLabel('Borrower'),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Autocomplete<Credit>(
                                optionsBuilder: (
                                  TextEditingValue textEditingValue,
                                ) {
                                  if (textEditingValue.text.isEmpty) {
                                    return _credits;
                                  }
                                  return _credits.where((Credit option) {
                                    final name = option.userName ?? '';
                                    return name.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                                displayStringForOption:
                                    (Credit option) => option.userName ?? '',
                                onSelected: (Credit selection) {
                                  setState(() {
                                    _selectedCustomerId = selection.id;
                                  });
                                },
                                fieldViewBuilder: (
                                  BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted,
                                ) {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: _buildInputDecoration(
                                      'Search Customer Name',
                                      Icons.search,
                                    ).copyWith(
                                      suffixIcon:
                                          _selectedCustomerId != null
                                              ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  textEditingController.clear();
                                                  setState(() {
                                                    _selectedCustomerId = null;
                                                  });
                                                },
                                              )
                                              : null,
                                    ),
                                    validator: (val) {
                                      if (_selectedCustomerId == null) {
                                        return 'Please select a customer';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                optionsViewBuilder: (
                                  BuildContext context,
                                  AutocompleteOnSelected<Credit> onSelected,
                                  Iterable<Credit> options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth: constraints.maxWidth,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (
                                            BuildContext context,
                                            int index,
                                          ) {
                                            final Credit option = options
                                                .elementAt(index);
                                            return InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  '${option.userName} (ID: ${option.id.substring(0, 4)}..)',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Amount
                          _buildLabel('Limit Amount'),
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid amount';
                              }
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
                              onPressed: _isLoading ? null : _submitLoan,
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
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Grant Limit',
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
