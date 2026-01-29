import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Customer QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _isScanned = true;
              final code = barcode.rawValue!;

              // Helper to attempt decode
              String? decodedUid;
              try {
                // 1. Decode Base64
                // Note: The scanner might return raw strings, but we encoded it as Base64.
                // We expect "sahakorn_secret_UID" after decode
                final decodedBytes = base64Decode(code);
                final decodedString = utf8.decode(decodedBytes);

                // 2. Verify Prefix
                const prefix = 'sahakorn_secret_';
                if (decodedString.startsWith(prefix)) {
                  decodedUid = decodedString.substring(prefix.length);
                }
              } catch (e) {
                // If decode fails, it's not our secure code
                decodedUid = null;
              }

              if (decodedUid != null && decodedUid.isNotEmpty) {
                debugPrint('Secure QR found! $decodedUid');
                Navigator.pop(context, decodedUid);
              } else {
                // Option: Show error and resume scanning. For now, pop with error or null
                debugPrint('Invalid QR format: $code');
                // If we want to support non-secure QRs too (legacy), we could fallback:
                // Navigator.pop(context, code);

                // Show snackbar or visual cue that QR is invalid?
                // For now, let's just reset scan and ignore invalid codes
                _isScanned = false;
              }
              break;
            }
          }
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
