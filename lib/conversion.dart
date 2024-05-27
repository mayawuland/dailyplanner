import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final List<String> currencies = [
    'Euro',
    'Dollar (USA)',
    'Yen',
    'Poundsterling'
  ];
  String toCurrency = 'Euro';
  TextEditingController inputValueController = TextEditingController();
  double result = 0.0;

  @override
  void dispose() {
    inputValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8f14b8),
      ),
      backgroundColor: Color(0xFFc553ec),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<String>(
                value: toCurrency,
                items: currencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    toCurrency = newValue!;
                  });
                },
                style: TextStyle(color: Colors.black),
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                underline: SizedBox(),
                isExpanded: true,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: inputValueController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: InputDecoration(
                hintText: 'Input Value (Rupiah)',
                hintStyle: TextStyle(color: Colors.black26),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                convertCurrency();
                setState(() {});
              },
              child: Text('Convert', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8f14b8),
              ),
            ),
            SizedBox(height: 16.0),
            Text("Result: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            SizedBox(height: 10.0),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: result.toString()),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void convertCurrency() {
    double inputValue = double.tryParse(inputValueController.text) ?? 0.0;
    double? rate = getExchangeRate('Rupiah', toCurrency);
    if (rate != null) {
      setState(() {
        result = inputValue * rate;
      });
    } else {
      setState(() {
        result = 0.0;
      });
    }
  }

  double? getExchangeRate(String fromCurrency, String toCurrency) {
    Map<String, double> exchangeRates = {
      'Euro': 0.00006,
      'Dollar (USA)': 0.000062,
      'Yen': 0.0098,
      'Poundsterling': 0.000049,
    };

    if (exchangeRates.containsKey(toCurrency)) {
      return exchangeRates[toCurrency]!;
    } else {
      return null;
    }
  }
}
