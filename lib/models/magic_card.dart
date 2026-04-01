class MagicCard {
  // Atributos da Classe
  final String id;
  final String name;
  final String manaCost;
  final String typeLine;
  final String imageUrl;

  // Construtor do Classe Dart
  MagicCard({
    required this.id,
    required this.name,
    required this.manaCost,
    required this.typeLine,
    required this.imageUrl,
  });

  // O "fromArray" do Flutter. Pega o JSON da Scryfall e transforma no Objeto.
  factory MagicCard.fromJson(Map<String, dynamic> json) {
    return MagicCard(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Nome Desconhecido',
      manaCost: json['mana_cost'],
      typeLine: json['type_line'] ?? '',
      imageUrl: json['image_uris'] != null ? json['image_uris']['normal'] : '',
    );
  }
}
