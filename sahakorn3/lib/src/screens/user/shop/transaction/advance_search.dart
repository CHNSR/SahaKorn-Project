import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../models/transaction.dart';
import '../../../../services/firebase/transaction/transaction_repository.dart';
import '../../../../utils/formatters.dart';
import 'package:intl/intl.dart';
import 'config_transaction.dart';

class AdvanceSearch extends StatefulWidget {
  final TransactionRepository repository;

  const AdvanceSearch({super.key, required this.repository});

  @override
  State<AdvanceSearch> createState() => _AdvanceSearchState();
}

class SearchCriteria {
  final DateTime? startDate;
  final DateTime? endDate;
  final RangeValues amountRange;
  final List<String> selectedTypes;

  SearchCriteria({
    this.startDate,
    this.endDate,
    required this.amountRange,
    required this.selectedTypes,
  });
}

class _AdvanceSearchState extends State<AdvanceSearch> {
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _amountRange = const RangeValues(0, 50000);
  final double _minAmount = 0;
  final double _maxAmount = 50000;
  final List<String> _selectedTypes = [];
  final List<String> _availableTypes = ['Income', 'Expense', 'Loan', 'Payment'];

  // Search Results
  List<AppTransaction>? _searchResults;
  bool _isLoading = false;
  bool _hasSearched = false;

  void _reset() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _amountRange = RangeValues(_minAmount, _maxAmount);
      _selectedTypes.clear();
      _searchResults = null;
      _hasSearched = false;
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // 1. Fetch all (or improved query if repo supports it)
      // For now, fetching limit 200 to accommodate search on recent items
      final allTransactions = await widget.repository.listAll(limit: 200);

      // 2. Filter client-side
      final filtered =
          allTransactions.where((t) {
            // Date Filter
            if (_startDate != null && _endDate != null) {
              if (t.createdAt == null) return false;
              final end = _endDate!
                  .add(const Duration(days: 1))
                  .subtract(const Duration(seconds: 1));
              if (t.createdAt!.isBefore(_startDate!) ||
                  t.createdAt!.isAfter(end)) {
                return false;
              }
            }

            // Amount Filter
            if (t.totalAmount < _amountRange.start ||
                t.totalAmount > _amountRange.end) {
              return false;
            }

            // Type Filter
            if (_selectedTypes.isNotEmpty) {
              if (!_selectedTypes.contains(t.paymentMethod)) {
                return false;
              }
            }
            return true;
          }).toList();

      setState(() {
        _searchResults = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            // dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Filter Transactions',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section (Collapsible or just standard)
          Expanded(
            flex: _hasSearched && (_searchResults?.isNotEmpty ?? false) ? 2 : 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Date Range'),
                  const SizedBox(height: 12),
                  _buildDateSelector(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Transaction Type'),
                  const SizedBox(height: 12),
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Amount Range'),
                  const SizedBox(height: 12),
                  _buildAmountSlider(context),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results Section
          if (_hasSearched)
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.list_alt_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Results (${_searchResults?.length ?? 0})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : (_searchResults != null &&
                                  _searchResults!.isEmpty)
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transactions found',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.separated(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 20,
                                ),
                                itemCount: _searchResults!.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 12),
                                itemBuilder:
                                    (context, index) => _buildTransactionCard(
                                      _searchResults![index],
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

  Widget _buildTransactionCard(AppTransaction t) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ConfigTransaction(
                  transaction: t,
                  repository: widget.repository,
                ),
          ),
        );
        if (result == true) {
          _performSearch(); // Refresh list if edited/deleted
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    t.paymentMethod == 'Loan'
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                t.paymentMethod == 'Loan'
                    ? Icons.credit_score_rounded
                    : Icons.payments_rounded,
                color: t.paymentMethod == 'Loan' ? Colors.orange : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.detail ?? 'Transaction',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateDetailed(t.createdAt ?? DateTime.now()),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.formatBaht(t.totalAmount, showSign: true),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color:
                    t.paymentMethod == 'Loan'
                        ? Colors.orange[700]
                        : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    bool hasDate = _startDate != null && _endDate != null;
    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDate ? AppColors.primary : Colors.grey.shade200,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: hasDate ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDate
                    ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                    : 'Select Period',
                style: TextStyle(
                  color: hasDate ? Colors.black87 : Colors.grey.shade500,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          _availableTypes.map((type) {
            final isSelected = _selectedTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected
                      ? _selectedTypes.add(type)
                      : _selectedTypes.remove(type);
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAmountSlider(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_amountRange.start.round()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_amountRange.end.round()}+',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey.shade100,
            trackHeight: 4,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: RangeSlider(
            values: _amountRange,
            min: _minAmount,
            max: _maxAmount,
            divisions: 50,
            onChanged: (values) => setState(() => _amountRange = values),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateDetailed(DateTime date) {
    return DateFormat('dd MMM HH:mm').format(date);
  }
}
