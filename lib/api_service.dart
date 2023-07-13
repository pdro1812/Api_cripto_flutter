import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const apiKey = '8c2fc900-c3e5-4391-8b6a-20afb40ceed2';

  static Future<List<dynamic>> fetchCryptocurrencies() async {
    final url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-CMC_PRO_API_KEY': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Api erro');
    }
  }

  static Future<double?> fetchCryptoPrice(int id, String currency) async {
    id = 1;
    final url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=$id&convert=$currency';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-CMC_PRO_API_KEY': apiKey,
        },
      ).timeout(Duration(seconds: 20)); // Timeout de 20 segundos

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quote = data['data'][id.toString()]['quote'][currency.toUpperCase()];
        final price = quote['price'];
        return price.toDouble();
      } else {
        return null; // Retorna null caso a chamada não seja bem-sucedida
      }
    } catch (e) {
      return null; // Retorna null caso ocorra uma exceção durante a chamada
    }
  }
}
