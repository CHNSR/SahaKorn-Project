import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/services/firebase/shop/fire_shop_write_service.dart';
import 'package:sahakorn3/src/utils/custom_snackbar.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class EditShopProfileScreen extends StatefulWidget {
  const EditShopProfileScreen({super.key});

  @override
  State<EditShopProfileScreen> createState() => _EditShopProfileScreenState();
}

class _EditShopProfileScreenState extends State<EditShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String _status = 'active';
  String? _logoFileName;
  String? _shopId;
  String? _ownerId;

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Defer loading to after build to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShopData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    final ownerId = context.read<UserInformationProvider>().uid;
    if (ownerId == null) {
      if (mounted) setState(() => _isFetching = false);
      return;
    }

    final shopProvider = context.read<ShopProvider>();
    await shopProvider.loadShops(ownerId);

    if (shopProvider.shops.isNotEmpty) {
      // For now, retrieve the first shop.
      // In a multi-shop scenario, we might need a selection step before this screen.
      final shop = shopProvider.shops.first;
      _populateForm(shop);
    }

    if (mounted) setState(() => _isFetching = false);
  }

  void _populateForm(Shop shop) {
    _shopId = shop.id;
    _ownerId = shop.ownerId;
    _nameController.text = shop.name;
    _descriptionController.text = shop.description;
    _addressController.text = shop.address;
    _phoneController.text = shop.phone;
    _emailController.text = shop.email;
    _status = shop.status;
    _logoFileName = shop.logo.isNotEmpty ? shop.logo : null;
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;
    if (_shopId == null) {
      AppSnackBar.showError(context, 'No shop to update found.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final writeSvc = FireShopWriteService();
      final shopData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'status': _status,
        // 'logo': _logoFileName // If logo logic is added
        if (_logoFileName != null) 'logo': _logoFileName,
      };

      await writeSvc.updateShop(_shopId!, shopData);

      // Refresh local provider
      if (!mounted) return;
      // We should ideally reload the shops in provider
      await context.read<ShopProvider>().loadShops(_ownerId!);

      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Shop updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Error updating shop: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLogo() async {
    // Placeholder logic
    setState(() {
      _logoFileName = 'updated_logo.png';
    });
    AppSnackBar.showInfo(context, 'Logo selected (simulation)');
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: Colors.indigo.shade300, size: 20),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 14,
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Shop Profile')), // Simplified
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_shopId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Shop Profile',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No shop found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.createShop);
                },
                child: const Text('Create a Shop'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Shop Profile',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo Picker
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          _logoFileName != null
                              ? const Icon(Icons.check, color: Colors.indigo)
                              : const Icon(
                                Icons.image_outlined,
                                color: Colors.indigo,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shop Logo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _logoFileName ?? 'Upload a logo image',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _pickLogo,
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  label: 'Shop Name',
                  icon: Icons.store_mall_directory_outlined,
                ),
                validator: (v) => Validators.validateRequired(v, 'Shop name'),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration(
                  label: 'Shop Email',
                  icon: Icons.email_outlined,
                ),
                validator: (v) => Validators.validateEmail(v),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration(
                  label: 'Shop Phone',
                  icon: Icons.phone_outlined,
                ),
                validator: (v) => Validators.validateRequired(v, 'Phone'),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(
                  label: 'Description',
                  icon: Icons.description_outlined,
                ),
                maxLines: 3,
                validator: (v) => Validators.validateRequired(v, 'Description'),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                decoration: _buildInputDecoration(
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                ),
                maxLines: 2,
                validator: (v) => Validators.validateRequired(v, 'Address'),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: Theme.of(context).cardColor,
                decoration: _buildInputDecoration(
                  label: 'Status',
                  icon: Icons.toggle_on_outlined,
                ),
                items:
                    ['active', 'deactivate']
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Save Changes',
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
    );
  }
}
