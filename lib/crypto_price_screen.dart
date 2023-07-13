import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:async';

class CryptoPriceScreen extends StatefulWidget {
  @override
  _CryptoPriceScreenState createState() => _CryptoPriceScreenState();
}

class _CryptoPriceScreenState extends State<CryptoPriceScreen> {
  List<dynamic> cryptocurrencies = [];
  List<dynamic> filteredCryptocurrencies = [];
  Timer? timer;
  bool showError = false;

  @override
  void initState() {
    super.initState();
    fetchCryptocurrencies();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (!showError) {
        fetchCryptocurrencies();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchCryptocurrencies() async {
    try {
      final data = await ApiService.fetchCryptocurrencies();
      setState(() {
        cryptocurrencies = data;
        filteredCryptocurrencies = data;
        showError = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showError = true;
      });
    }
  }

  Future<double?> fetchCryptoPrice(int id, String currency) async {
    try {
      final price = await ApiService.fetchCryptoPrice(id, currency);
      return price;
    } catch (e) {
      return null;
    }
  }

  void filterCryptocurrencies(String value) {
    setState(() {
      filteredCryptocurrencies = cryptocurrencies.where((cryptocurrency) {
        final name = cryptocurrency['name'].toString().toLowerCase();
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Prices'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterCryptocurrencies,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCryptocurrencies.length > 10 ? 10 : filteredCryptocurrencies.length,
              itemBuilder: (context, index) {
                final cryptocurrency = filteredCryptocurrencies[index];
                final name = cryptocurrency['name'];
                final symbol = cryptocurrency['symbol'];
                final id = cryptocurrency['id'];

                return ListTile(
                  title: Text('$name ($symbol)'),
                  subtitle: Builder(builder: (context) {
                    return FutureBuilder<double?>(
                      future: fetchCryptoPrice(id, 'BRL'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Carregando');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final price = snapshot.data!;
                          return Text('R\$${price.toStringAsFixed(2)}');
                        } else {
                          return FutureBuilder<bool>(
                            future: Future.delayed(Duration(seconds: 0), () => true),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('Carregando...');
                              } else {
                                return Text('Falha ao obter o preço');
                              }
                            },
                          );
                        }
                      },
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
