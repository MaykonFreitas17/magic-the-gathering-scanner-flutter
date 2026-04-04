import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para o compute
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Para o Cache
import '../models/magic_card.dart';
import '../models/mtg_set.dart';

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
  static const String _setsCacheKey = 'mtg_sets_cache';

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
        final List<dynamic>? cardsJson = data['data'];
        if (cardsJson == null) return null;

        final cards = cardsJson
            .map((json) => MagicCard.fromJson(json))
            .toList();
        return ScryfallResponse(
          totalCards: data['total_cards'] ?? 0,
          hasMore: data['has_more'] ?? false,
          cards: cards,
        );
      }
    } catch (e) {
      debugPrint('Erro cartas: $e');
    }
    return null;
  }

  Future<List<MtgSet>?> getSets() async {
    final prefs = await SharedPreferences.getInstance();

    final String? cachedSets = prefs.getString(_setsCacheKey);

    if (cachedSets != null) {
      debugPrint('📦 Carregando coleções do Cache Local...');
      return compute(_parseSets, cachedSets);
    }

    debugPrint('🌐 Buscando coleções na API (Primeira vez)...');
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sets'),
        headers: {'User-Agent': 'SolLens/1.0', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        await prefs.setString(_setsCacheKey, response.body);

        return compute(_parseSets, response.body);
      }
    } catch (e) {
      debugPrint('Erro sets: $e');
    }
    return null;
  }
}

List<MtgSet> _parseSets(String responseBody) {
  final Map<String, dynamic> data = json.decode(responseBody);
  final List<dynamic> setsJson = data['data'];

  return setsJson
      .map((json) => MtgSet.fromJson(json))
      .where((set) => set.setType != 'token' && set.setType != 'memorabilia')
      .toList();
}
