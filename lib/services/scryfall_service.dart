import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/magic_card.dart';

class ScryfallService {
  // A URL base da API da Scryfall
  static const String _baseUrl = 'https://api.scryfall.com';

  Future<List<MagicCard>> getFeedCards() async {
    // O Uri.https monta a URL perfeitamente e codifica os espaços sozinho
    final url = Uri.https('api.scryfall.com', '/cards/search', {
      'q': 'f:pioneer order:released',
    });

    try {
      print('🔍 Buscando na URL: $url'); // Vamos ver a URL exata

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SolLens/1.0', // Nome do nosso app
          'Accept':
              'application/json', // Dizemos que queremos a resposta em JSON
        },
      );

      print(
        '📡 Status da Resposta: ${response.statusCode}',
      ); // Tem que ser 200!

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Colocamos uma interrogação caso a chave 'data' não exista
        final List<dynamic>? cardsJson = data['data'];

        if (cardsJson == null) {
          print('⚠️ A API não retornou o array "data"');
          return [];
        }

        print(
          '✅ Encontrou ${cardsJson.length} cartas. Transformando em Models...',
        );

        return cardsJson.map((json) => MagicCard.fromJson(json)).toList();
      } else {
        print('❌ Erro da API Scryfall: ${response.body}');
        return [];
      }
    } catch (e) {
      // Se der erro de conversão do JSON ou falta de internet, ele grita aqui:
      print('🔥 Erro Crítico no Service: $e');
      return [];
    }
  }
}
