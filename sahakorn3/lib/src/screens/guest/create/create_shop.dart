import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/services/firebase/shop/fire_shop_write_service.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:sahakorn3/src/widgets/shop_navbar.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _status = 'active';
  bool _isLoading = false;
  // Placeholder for logo file
  String? _logoFileName;

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    // This is a placeholder for actual image picking logic
    // e.g., using image_picker package
    setState(() {
      _logoFileName = 'logo_example.png';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logo selected (simulation)')));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final ownerId = context.read<UserInformationProvider?>()?.uid ?? '';

    final shopData = {
      'name': _shopNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'logo': _logoFileName ?? '',
      'address': _addressController.text.trim(),
      'status': _status,
      'ownerId': ownerId,
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    try {
      // construct Shop model (adjust field names if your model differs)
      final shop = Shop(
        id: '', // leave empty, Firestore will generate id
        name: shopData['name'] as String,
        address: shopData['address'] as String,
        ownerId: shopData['ownerId'] as String,
        phone: shopData['phone'] as String,
        email: shopData['email'] as String,
        description: shopData['description'] as String,
        logo: shopData['logo'] as String,
        status: shopData['status'] as String,
      );

      final writeSvc = FireShopWriteService();
      final result = await writeSvc.createShop(shop);
      // createShop returns doc id on success
      if (result is String && result.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const NavbarShop()),
          (route) => false,
        );
      } else {
        // unexpected return
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create shop'),
            backgroundColor: Color(0xFFf25f4c),
          ),
        );
      }
    } catch (e) {
      debugPrint('Create shop error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Color(0xFFf25f4c),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: Colors.indigo.shade300, size: 20),
      labelStyle: TextStyle(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
        fontSize: 14,
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]!
                  : Colors.grey[300]!,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create New Shop',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const NavbarShop()),
                (route) => false,
              );
            },
            child: Text(
              'Skip',
              style: TextStyle(color: Colors.indigo.shade400, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let\'s setup your shop',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details below to create your professional shop presence.',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _shopNameController,
                      decoration: _buildInputDecoration(
                        label: 'Shop Name',
                        icon: Icons.store_mall_directory_outlined,
                      ),
                      validator:
                          (v) => Validators.validateRequired(v, 'Shop name'),
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration(
                        label: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => Validators.validateEmail(v),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _buildInputDecoration(
                        label: 'Telephone',
                        icon: Icons.phone_outlined,
                      ),
                      keyboardType: TextInputType.phone,
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
                      validator:
                          (v) => Validators.validateRequired(v, 'Description'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: _buildInputDecoration(
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                      ),
                      maxLines: 2,
                      validator:
                          (v) => Validators.validateRequired(v, 'Address'),
                    ),
                    const SizedBox(height: 24),

                    // Logo Picker (Custom Design)
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
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.indigo,
                                    )
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
                                    color: Colors.grey[800],
                                    fontSize: 14,
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

                    const SizedBox(height: 20),

                    // Status Dropdown
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
                    const SizedBox(height: 48),

                    // Submit Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Create Shop',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
