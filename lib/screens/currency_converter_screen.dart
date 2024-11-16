import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Tambahkan form key
  String? _errorMessage; // Untuk menampilkan pesan error
  bool _isProcessing = false; // Loading state

  final Map<String, double> _rates = {
    'USD': 1.0,
    'IDR': 15500.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'SGD': 1.35,
    'JPY': 110.0,
    'CNY': 6.45,
    'AUD': 1.35,
    'CAD': 1.25,
    'KRW': 1200.0,
  };

  double _convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Add listener untuk validasi real-time
    _amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Validasi input jumlah
  void _validateAmount() {
    setState(() {
      _errorMessage = null;
    });
  }

  // Format number dengan pemisah ribuan
  String _formatNumber(double number) {
    try {
      return number.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } catch (e) {
      return '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.amberAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.currency_exchange, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Currency Converter',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.amber[50],
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konversi',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Jumlah',
                          errorText: _errorMessage,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Silakan masukkan jumlah';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Silakan masukkan nomor yang valid';
                          }
                          if (number <= 0) {
                            return 'Jumlahnya harus lebih besar dari 0';
                          }
                          if (number > 999999999) {
                            return 'Jumlahnya terlalu besar';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _fromCurrency,
                            isExpanded: true,
                            items: _rates.keys.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue == _toCurrency) {
                                _showErrorSnackBar(
                                    'Mata uang Dari dan Ke tidak boleh sama');
                                return;
                              }
                              setState(() {
                                _fromCurrency = newValue!;
                                _convertedAmount = 0.0;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jumlah yang Dikonversi:',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatNumber(_convertedAmount),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _toCurrency,
                            isExpanded: true,
                            items: _rates.keys.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue == _fromCurrency) {
                                _showErrorSnackBar(
                                    'Mata uang Dari dan Ke tidak boleh sama');
                                return;
                              }
                              setState(() {
                                _toCurrency = newValue!;
                                _convertedAmount = 0.0;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleConversion,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.amber[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Konversi',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 24.0),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mata Uang yang Tersedia:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...[
                                'USD - United States Dollar',
                                'IDR - Indonesian Rupiah',
                                'EUR - Euro',
                                'GBP - British Pound Sterling',
                                'SGD - Singapore Dollar',
                                'JPY - Japanese Yen',
                                'CNY - Chinese Yuan',
                                'AUD - Australian Dollar',
                                'CAD - Canadian Dollar',
                                'KRW - South Korean Won',
                              ].map((currency) => Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    child: Text(currency),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleConversion() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isProcessing = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => _isProcessing = false);
        return;
      }

      if (_fromCurrency == _toCurrency) {
        _showErrorSnackBar('Silakan pilih mata uang yang berbeda');
        setState(() => _isProcessing = false);
        return;
      }

      double amount = double.tryParse(_amountController.text) ?? 0.0;

      // Simulasi network delay
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // Konversi
      double fromRate = _rates[_fromCurrency] ?? 1.0;
      double toRate = _rates[_toCurrency] ?? 1.0;

      setState(() {
        _convertedAmount = (amount / fromRate) * toRate;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan selama konversi';
        _isProcessing = false;
        _convertedAmount = 0.0;
      });
      _showErrorSnackBar('Gagal mengonversi mata uang. Silakan coba lagi.');
    }
  }
}
