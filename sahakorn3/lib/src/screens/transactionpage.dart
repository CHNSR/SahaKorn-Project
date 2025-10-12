import 'package:flutter/material.dart';

class Transactionpage extends StatefulWidget {
  const Transactionpage({super.key});

  @override
  State<Transactionpage> createState() => _TransactionpageState();
}

class _TransactionpageState extends State<Transactionpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                // ...existing code...
              ],
            ),
          ),
        ),
      ),
    );
  }
}
