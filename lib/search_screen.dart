import 'package:flutter/material.dart';
import 'api_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> filteredCryptocurrencies = [];
  bool showError = false;

  Future<void> filterCryptocurrencies(String value) async {
    try {
      final data = await ApiService.fetchCryptocurrencies();
      setState(() {
        filteredCryptocurrencies = data.where((cryptocurrency) {
          final name = cryptocurrency['name'].toString().toLowerCase();
          return name.contains(value.toLowerCase());
        }).toList();
        showError = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisa'),
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
              itemCount: filteredCryptocurrencies.length,
              itemBuilder: (context, index) {
                final cryptocurrency = filteredCryptocurrencies[index];
                final name = cryptocurrency['name'];
                final symbol = cryptocurrency['symbol'];
                final id = cryptocurrency['id'];

                return ListTile(
                  title: Text('$name ($symbol)'),
                  subtitle: Builder(builder: (context) {
                    return FutureBuilder<double?>(
                      future: ApiService.fetchCryptoPrice(id, 'BRL'),
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
