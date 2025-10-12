import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRGeneratePage extends StatelessWidget {
  const QRGeneratePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productData = {
      "id": "P123",
      "name": "ข้าวหอมมะลิ 5 กก.",
      "price": 250.00,
      "quantity": 1,
    };
    final qrValue = productData.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code สินค้า"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrettyQr(
              data: qrValue,
              size: 250,
              roundEdges: true,
            ),
            const SizedBox(height: 20),
            const Text(
              "สแกน QR Code เพื่อดูข้อมูลสินค้าและชำระเงิน",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
