class MtgSet {
  final String id;
  final String code;
  final String name;
  final String releasedAt;
  final String setType;

  MtgSet({
    required this.id,
    required this.code,
    required this.name,
    required this.releasedAt,
    required this.setType,
  });

  factory MtgSet.fromJson(Map<String, dynamic> json) {
    return MtgSet(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? 'Coleção Desconhecida',
      releasedAt: json['released_at'] ?? '',
      setType: json['set_type'] ?? '',
    );
  }
}
