import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'dart:convert';

class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({super.key});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Get User Info
    final userProvider = context.watch<UserInformationProvider>();
    final uid = userProvider.uid;
    final name = userProvider.displayName ?? 'Unknown User';
    final phone = userProvider.phone ?? '';

    // 2. Check loading/error
    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My QR Code')),
        body: const Center(child: Text('User not found. Please log in.')),
      );
    }

    // 3. UI Implementation
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My QR Code',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar (Optional decoration)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.indigo.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Beautiful QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade100,
                          width: 2,
                        ),
                      ),
                      child: PrettyQrView.data(
                        data: base64Encode(utf8.encode('sahakorn_secret_$uid')),
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                        decoration: const PrettyQrDecoration(
                          shape: PrettyQrSmoothSymbol(color: Colors.indigo),
                          image: PrettyQrDecorationImage(
                            image: AssetImage('assets/icon/SahaKorn_V1_0.png'),
                            position: PrettyQrDecorationImagePosition.embedded,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Show this code to the shop\nto be added as a customer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Helper Button (e.g., Share or Close)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
