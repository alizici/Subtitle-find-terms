// lib/models/term_pair.dart

enum TermCategory {
  person,
  place,
  organization,
  technical,
  general,
  other,
}

class TermPair {
  final String id;
  String chineseTerm;
  String englishTerm;
  TermCategory category;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  TermPair({
    String? id,
    required this.chineseTerm,
    required this.englishTerm,
    this.category = TermCategory.general,
    this.notes,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  TermPair copyWith({
    String? chineseTerm,
    String? englishTerm,
    TermCategory? category,
    String? notes,
  }) {
    return TermPair(
      id: id,
      chineseTerm: chineseTerm ?? this.chineseTerm,
      englishTerm: englishTerm ?? this.englishTerm,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chineseTerm': chineseTerm,
      'englishTerm': englishTerm,
      'category': category.index,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TermPair.fromJson(Map<String, dynamic> json) {
    return TermPair(
      id: json['id'],
      chineseTerm: json['chineseTerm'],
      englishTerm: json['englishTerm'],
      category: TermCategory.values[json['category']],
      notes: json['notes'],
    );
  }
}
