class MagicCard {
  final String id;
  final String oracleId;
  final String name;
  final String lang;
  final String releasedAt;
  final String uri;
  final String scryfallUri;
  final String layout;

  // Imagens
  final ImageUris? imageUris;
  final List<CardFace>? cardFaces; // NOVO: Propriedade para cartas dupla-face

  // Atributos de Jogo
  final String? manaCost;
  final num cmc;
  final String typeLine;
  final String? oracleText;
  final String? power;
  final String? toughness;
  final List<String> colors;
  final List<String> colorIdentity;
  final List<String> keywords;

  // Legalidades e Formatos
  final Legalities? legalities;
  final List<String> games;
  final bool reserved;
  final bool foil;
  final bool nonfoil;
  final List<String> finishes;

  // Coleção
  final String setId;
  final String setCode;
  final String setName;
  final String setType;
  final String collectorNumber;
  final String rarity;

  // Miscelânea
  final String? flavorText;
  final String? artist;
  final String borderColor;
  final String frame;
  final bool fullArt;
  final bool textless;
  final bool booster;

  // Economia
  final Prices? prices;
  final Map<String, String> relatedUris;
  final Map<String, String> purchaseUris;

  MagicCard({
    required this.id,
    required this.oracleId,
    required this.name,
    required this.lang,
    required this.releasedAt,
    required this.uri,
    required this.scryfallUri,
    required this.layout,
    this.imageUris,
    this.cardFaces,
    this.manaCost,
    required this.cmc,
    required this.typeLine,
    this.oracleText,
    this.power,
    this.toughness,
    required this.colors,
    required this.colorIdentity,
    required this.keywords,
    this.legalities,
    required this.games,
    required this.reserved,
    required this.foil,
    required this.nonfoil,
    required this.finishes,
    required this.setId,
    required this.setCode,
    required this.setName,
    required this.setType,
    required this.collectorNumber,
    required this.rarity,
    this.flavorText,
    this.artist,
    required this.borderColor,
    required this.frame,
    required this.fullArt,
    required this.textless,
    required this.booster,
    this.prices,
    required this.relatedUris,
    required this.purchaseUris,
  });

  String get imageUrl {
    if (imageUris != null) return imageUris!.normal;
    if (cardFaces != null && cardFaces!.isNotEmpty) {
      return cardFaces![0].imageUris?.normal ?? '';
    }
    return '';
  }

  factory MagicCard.fromJson(Map<String, dynamic> json) {
    return MagicCard(
      id: json['id'] ?? '',
      oracleId: json['oracle_id'] ?? '',
      name: json['name'] ?? 'Nome Desconhecido',
      lang: json['lang'] ?? '',
      releasedAt: json['released_at'] ?? '',
      uri: json['uri'] ?? '',
      scryfallUri: json['scryfall_uri'] ?? '',
      layout: json['layout'] ?? '',

      imageUris: json['image_uris'] != null
          ? ImageUris.fromJson(json['image_uris'])
          : null,

      cardFaces: json['card_faces'] != null
          ? (json['card_faces'] as List)
                .map((i) => CardFace.fromJson(i))
                .toList()
          : null,

      manaCost: json['mana_cost'],
      cmc: json['cmc'] ?? 0,
      typeLine: json['type_line'] ?? '',
      oracleText: json['oracle_text'],
      power: json['power'],
      toughness: json['toughness'],
      colors: List<String>.from(json['colors'] ?? []),
      colorIdentity: List<String>.from(json['color_identity'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),

      legalities: json['legalities'] != null
          ? Legalities.fromJson(json['legalities'])
          : null,
      games: List<String>.from(json['games'] ?? []),
      reserved: json['reserved'] ?? false,
      foil: json['foil'] ?? false,
      nonfoil: json['nonfoil'] ?? false,
      finishes: List<String>.from(json['finishes'] ?? []),

      setId: json['set_id'] ?? '',
      setCode: json['set'] ?? '',
      setName: json['set_name'] ?? 'Coleção Desconhecida',
      setType: json['set_type'] ?? '',
      collectorNumber: json['collector_number'] ?? '',
      rarity: json['rarity'] ?? '',

      flavorText: json['flavor_text'],
      artist: json['artist'],
      borderColor: json['border_color'] ?? '',
      frame: json['frame'] ?? '',
      fullArt: json['full_art'] ?? false,
      textless: json['textless'] ?? false,
      booster: json['booster'] ?? false,

      prices: json['prices'] != null ? Prices.fromJson(json['prices']) : null,
      relatedUris: Map<String, String>.from(json['related_uris'] ?? {}),
      purchaseUris: Map<String, String>.from(json['purchase_uris'] ?? {}),
    );
  }
}

// --- Subclasses para organizar os objetos aninhados ---
class ImageUris {
  final String small;
  final String normal;
  final String large;
  final String png;
  final String artCrop;
  final String borderCrop;

  ImageUris({
    required this.small,
    required this.normal,
    required this.large,
    required this.png,
    required this.artCrop,
    required this.borderCrop,
  });

  factory ImageUris.fromJson(Map<String, dynamic> json) {
    return ImageUris(
      small: json['small'] ?? '',
      normal: json['normal'] ?? '',
      large: json['large'] ?? '',
      png: json['png'] ?? '',
      artCrop: json['art_crop'] ?? '',
      borderCrop: json['border_crop'] ?? '',
    );
  }
}

class Legalities {
  final String standard;
  final String pioneer;
  final String modern;
  final String legacy;
  final String commander;
  final String pauper;

  Legalities({
    required this.standard,
    required this.pioneer,
    required this.modern,
    required this.legacy,
    required this.commander,
    required this.pauper,
  });

  factory Legalities.fromJson(Map<String, dynamic> json) {
    return Legalities(
      standard: json['standard'] ?? 'not_legal',
      pioneer: json['pioneer'] ?? 'not_legal',
      modern: json['modern'] ?? 'not_legal',
      legacy: json['legacy'] ?? 'not_legal',
      commander: json['commander'] ?? 'not_legal',
      pauper: json['pauper'] ?? 'not_legal',
    );
  }
}

class Prices {
  final String? usd;
  final String? usdFoil;
  final String? eur;
  final String? eurFoil;

  Prices({this.usd, this.usdFoil, this.eur, this.eurFoil});

  factory Prices.fromJson(Map<String, dynamic> json) {
    return Prices(
      usd: json['usd'],
      usdFoil: json['usd_foil'],
      eur: json['eur'],
      eurFoil: json['eur_foil'],
    );
  }
}

class CardFace {
  final ImageUris? imageUris;

  CardFace({this.imageUris});

  factory CardFace.fromJson(Map<String, dynamic> json) {
    return CardFace(
      imageUris: json['image_uris'] != null
          ? ImageUris.fromJson(json['image_uris'])
          : null,
    );
  }
}
