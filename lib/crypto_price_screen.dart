import 'package:flutter/material.dart';
import 'api_service.dart';

class CryptoPriceScreen extends StatefulWidget {
  @override
  _CryptoPriceScreenState createState() => _CryptoPriceScreenState();
}

class _CryptoPriceScreenState extends State<CryptoPriceScreen> {
  List<dynamic> cryptocurrencies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCryptocurrencies();
  }

  Future<void> fetchCryptocurrencies() async {
    try {
      final data = await ApiService.fetchCryptocurrencies();
      setState(() {
        cryptocurrencies = data;
        loading = false; // Definir como false para indicar que os dados foram carregados
      });
    } catch (e) {
      print(e.toString());
      // Chama o método novamente após 5 segundos em caso de erro
      Future.delayed(Duration(seconds: 5), () => fetchCryptocurrencies());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Prices'),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : cryptocurrencies.isEmpty
                    ? Center(
                        child: Text('Nenhum dado disponível.'),
                      )
                    : ListView.builder(
                        itemCount: cryptocurrencies.length > 5 ? 5 : cryptocurrencies.length,
                        itemBuilder: (context, index) {
                          final cryptocurrency = cryptocurrencies[index];
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
                                      future: Future.delayed(Duration(seconds: 5), () => true),
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
