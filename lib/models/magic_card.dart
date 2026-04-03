class MagicCard {
  final String id;
  final String name;
  final String? manaCost;
  final String typeLine;
  final String imageUrl;
  final String setName; // NOVO: Campo para a coleção

  MagicCard({
    required this.id,
    required this.name,
    this.manaCost,
    required this.typeLine,
    required this.imageUrl,
    required this.setName,
  });

  factory MagicCard.fromJson(Map<String, dynamic> json) {
    return MagicCard(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Nome Desconhecido',
      manaCost: json['mana_cost'],
      typeLine: json['type_line'] ?? '',
      // Captura a imagem, se existir
      imageUrl: json['image_uris'] != null ? json['image_uris']['normal'] : '',
      // Captura o nome da coleção do JSON da Scryfall
      setName: json['set_name'] ?? 'Coleção Desconhecida',
    );
  }
}
