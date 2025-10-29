import 'package:flutter/foundation.dart';
import '../../../core/services/currency_service.dart';

class ConverterController extends ChangeNotifier {
  final CurrencyService _service = CurrencyService();

  Map<String, dynamic> _rates = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  double _amount = 1.0;
  double _result = 0.0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  double get amount => _amount;
  double get result => _result;
  List<String> get currencies => ['USD', 'IDR', 'JPY', 'EUR'];

  ConverterController() {
    loadRates();
  }

  Future<void> loadRates() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _rates = await _service.getRates();
      calculate();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void setFromCurrency(String currency) {
    _fromCurrency = currency;
    calculate();
    notifyListeners();
  }

  void setToCurrency(String currency) {
    _toCurrency = currency;
    calculate();
    notifyListeners();
  }

  void setAmount(String amount) {
    _amount = double.tryParse(amount) ?? 0.0;
    calculate();
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    calculate();
    notifyListeners();
  }

  void calculate() {
    if (_rates.isEmpty) return;
    
    double fromRate = (_rates[_fromCurrency] as num).toDouble();
    double toRate = (_rates[_toCurrency] as num).toDouble();
    
    _result = (_amount / fromRate) * toRate;
    notifyListeners();
  }
}