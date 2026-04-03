import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para o debugPrint
import '../models/magic_card.dart';

class ScryfallResponse {
  final int totalCards;
  final bool hasMore;
  final List<MagicCard> cards;

  ScryfallResponse({
    required this.totalCards,
    required this.hasMore,
    required this.cards,
  });
}

class ScryfallService {
  static const String _baseUrl = 'https://api.scryfall.com';

  Future<ScryfallResponse?> getCards({int page = 1}) async {
    final String urlString =
        '$_baseUrl/cards/search?q=game:paper&order=name&page=$page';
    final url = Uri.parse(urlString);

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'SolLens/1.0', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final int total = data['total_cards'] ?? 0;
        final bool more = data['has_more'] ?? false;
        final List<dynamic>? cardsJson = data['data'];

        if (cardsJson == null) return null;

        final cards = cardsJson
            .map((json) => MagicCard.fromJson(json))
            .toList();

        return ScryfallResponse(totalCards: total, hasMore: more, cards: cards);
      }
      return null;
    } catch (e, stackTrace) {
      // O 'stackTrace' mostra exatamente a linha do arquivo que gerou o erro!
      debugPrint('🔥 Erro Crítico no Service: $e\n$stackTrace');
      return null;
    }
  }
}
