import 'package:flutter/material.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Halaman Konverter',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}