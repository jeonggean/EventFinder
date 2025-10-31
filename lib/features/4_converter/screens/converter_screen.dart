import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/converter_controller.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late final ConverterController _controller;
  final TextEditingController _amountController = TextEditingController(
    text: "1.0",
  );

  @override
  void initState() {
    super.initState();
    _controller = ConverterController();
    _controller.addListener(_updateUI);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateUI);
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Konverter Mata Uang',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.errorMessage.isNotEmpty
          ? Center(child: Text(_controller.errorMessage))
          : _buildConverterUI(),
    );
  }

  Widget _buildConverterUI() {
    final resultFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '${_controller.toCurrency} ',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Jumlah',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.attach_money),
            ),
            onChanged: (value) {
              _controller.setAmount(value);
            },
          ),
          const SizedBox(height: 24),
          _buildCurrencyRow(),
          const SizedBox(height: 32),
          Text(
            'Hasil Konversi:',
            style: GoogleFonts.nunito(
              fontSize: 18,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultFormat.format(_controller.result),
            style: GoogleFonts.nunito(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildCurrencyDropdown(
            _controller.fromCurrency,
            _controller.setFromCurrency,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: const Icon(Icons.swap_horiz),
            iconSize: 32,
            color: Theme.of(context).colorScheme.primary,
            onPressed: _controller.swapCurrencies,
          ),
        ),
        Expanded(
          child: _buildCurrencyDropdown(
            _controller.toCurrency,
            _controller.setToCurrency,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(String value, Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _controller.currencies.map((String currency) {
        return DropdownMenuItem<String>(value: currency, child: Text(currency));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}
