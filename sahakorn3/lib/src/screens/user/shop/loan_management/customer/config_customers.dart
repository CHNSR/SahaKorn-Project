import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class ConfigCustomersScreen extends StatelessWidget {
  const ConfigCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Configuration'),
        centerTitle: true,
      ),
      body: const Center(child: Text('Edit Customer Details Here')),
    );
  }
}
