// Medal 模型类定义

enum MedalLevel { iron, silver, gold, master }

class Medal {
  final String id;
  final String name;
  final String description;
  final String emoji; // Placeholder icon
  final String image; // Medal image path
  final MedalLevel level;
  final DateTime? earnedDate;

  Medal({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.image,
    this.level = MedalLevel.iron,
    this.earnedDate,
  });

  Medal copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    String? image,
    MedalLevel? level,
    DateTime? earnedDate,
  }) {
    return Medal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      image: image ?? this.image,
      level: level ?? this.level,
      earnedDate: earnedDate ?? this.earnedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'image': image,
      'level': level.index,
      'earnedDate': earnedDate?.toIso8601String(),
    };
  }

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      image: json['image'] ?? 'assets/images/medals/${json['id']}.webp',
      level: MedalLevel.values[json['level']],
      earnedDate: json['earnedDate'] != null
          ? DateTime.parse(json['earnedDate'])
          : null,
    );
  }
}
