import 'package:flutter/material.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';
import '../../../../utils/formatters.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock Data
  final List<Map<String, dynamic>> _allCustomers = [
    {
      'id': '1',
      'name': 'Somchai Jai-dee',
      'phone': '081-234-5678',
      'creditLimit': 20000.0,
      'currentDebt': 5000.0,
      'avatarColor': Colors.blue,
      'status': 'Good',
    },
    {
      'id': '2',
      'name': 'Somsri Rak-ngern',
      'phone': '089-876-5432',
      'creditLimit': 15000.0,
      'currentDebt': 0.0,
      'avatarColor': Colors.pink,
      'status': 'Inactive',
    },
    {
      'id': '3',
      'name': 'Mana Me-ngern',
      'phone': '090-111-2222',
      'creditLimit': 50000.0,
      'currentDebt': 12500.0,
      'avatarColor': Colors.green,
      'status': 'Good',
    },
    {
      'id': '4',
      'name': 'Manee Me-jai',
      'phone': '085-555-5555',
      'creditLimit': 10000.0,
      'currentDebt': 9000.0,
      'avatarColor': Colors.orange,
      'status': 'Overdue',
    },
    {
      'id': '5',
      'name': 'Piti Rak-thai',
      'phone': '081-999-8888',
      'creditLimit': 30000.0,
      'currentDebt': 28000.0,
      'avatarColor': Colors.purple,
      'status': 'Warning',
    },
  ];

  List<Map<String, dynamic>> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = _allCustomers;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers =
          _allCustomers.where((customer) {
            final name = customer['name'].toLowerCase();
            final phone = customer['phone'];
            return name.contains(query) || phone.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppSnackBar.showInfo(context, 'Add Customer feature coming soon');
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Customers (${_filteredCustomers.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                itemCount: _filteredCustomers.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildCustomerCard(_filteredCustomers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                'Customers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.people_outline, color: Colors.indigo),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name or phone...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      color: Colors.grey[400],
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final double creditLimit = customer['creditLimit'];
    final double currentDebt = customer['currentDebt'];
    // final double available = creditLimit - currentDebt; // unused

    final String status = customer['status'] ?? 'Good';

    Color statusColor;
    switch (status) {
      case 'Overdue':
        statusColor = Colors.red;
        break;
      case 'Warning':
        statusColor = Colors.orange;
        break;
      case 'Inactive':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            AppSnackBar.showInfo(context, 'Tapped ${customer['name']}');
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(customer),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            customer['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            customer['phone'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatBadge(
                            'Debt',
                            currentDebt,
                            Colors.red[700]!,
                          ),
                          const SizedBox(width: 12),
                          _buildStatBadge(
                            'Limit',
                            creditLimit,
                            Colors.blue[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> customer) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: customer['avatarColor'].withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        customer['name'][0],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: customer['avatarColor'],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            Formatters.formatBaht(value, showSign: false),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
