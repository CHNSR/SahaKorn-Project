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

  String _status = 'active';
  bool _isLoading = false;
  // Placeholder for logo file
  String? _logoFileName;

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
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
      'phone': '', // optional - not in form
    };

    try {
      // construct Shop model (adjust field names if your model differs)
      final shop = Shop(
        id: '', // leave empty, Firestore will generate id
        name: shopData['name'] as String,
        address: shopData['address'] as String,
        ownerId: shopData['ownerId'] as String,
        phone: '', // optional - not in form
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFb8c1ec),
      appBar: AppBar(
        title: const Text(
          'Create New Shop',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          TextButton(
            onPressed: () {
              // Skip straight to NavbarShop and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const NavbarShop()),
                (route) => false,
              );
            },
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF232946), width: 2),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFFfffffe),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title inside card
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Shop Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Shop Name
                      TextFormField(
                        controller: _shopNameController,
                        decoration: const InputDecoration(
                          labelText: 'Shop Name',
                        ),
                        validator:
                            (v) => Validators.validateRequired(v, 'Shop name'),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        validator:
                            (v) =>
                                Validators.validateRequired(v, 'Description'),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        maxLines: 2,
                        validator:
                            (v) => Validators.validateRequired(v, 'Address'),
                      ),
                      const SizedBox(height: 24),

                      // Logo Picker
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickLogo,
                            icon: const Icon(Icons.image),
                            label: const Text('Upload Logo'),
                          ),
                          const SizedBox(width: 10),
                          if (_logoFileName != null)
                            Expanded(
                              child: Text(
                                _logoFileName!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
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
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFeebbc3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF121629),
                              width: 2,
                            ),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Create Shop',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF121629),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
