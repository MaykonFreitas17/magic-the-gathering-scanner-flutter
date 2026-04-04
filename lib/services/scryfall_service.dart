import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<ScryfallResponse?> getCards({
    int page = 1,
    String? name,
    String? oracle,
    List<String>? sets,
    String? format,
    List<String>? colors,
    List<String>? keywords,
    List<String>? types,
  }) async {
    List<String> queryParts = ['game:paper'];

    if (name != null && name.isNotEmpty) {
      queryParts.add(name);
    }

    if (oracle != null && oracle.isNotEmpty) {
      final oracleParts = oracle
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => 'o:$w')
          .join(' ');
      queryParts.add('($oracleParts)');
    }

    if (types != null && types.isNotEmpty) {
      // Cria a regra: (t:creature OR t:instant)
      final typeQuery = types.map((t) => 't:$t').join(' OR ');
      queryParts.add('($typeQuery)');
    }

    if (keywords != null && keywords.isNotEmpty) {
      // Cria a regra: kw:flying kw:haste (A carta precisa ter as duas)
      final kwQuery = keywords.map((k) => 'kw:$k').join(' ');
      queryParts.add(kwQuery);
    }

    if (format != null && format.isNotEmpty) {
      queryParts.add('f:$format');
    }

    if (sets != null && sets.isNotEmpty) {
      final setQuery = sets.map((s) => 'e:$s').join(' OR ');
      queryParts.add('($setQuery)');
    }

    if (colors != null && colors.isNotEmpty) {
      final colorString = colors.join('');
      queryParts.add('c:$colorString');
    }

    final finalQuery = queryParts.join(' ');
    final encodedQuery = Uri.encodeComponent(finalQuery);
    final String urlString =
        '$_baseUrl/cards/search?q=$encodedQuery&order=name&page=$page';
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
      } else if (response.statusCode == 404) {
        return ScryfallResponse(totalCards: 0, hasMore: false, cards: []);
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
      return compute(_parseSets, cachedSets);
    }

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
