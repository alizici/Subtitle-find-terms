// lib/models/term_pair.dart
import 'package:flutter/material.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';

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

  // Helper method to get localized category name
  String getCategoryName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (category) {
      case TermCategory.person:
        return l10n.personName;
      case TermCategory.place:
        return l10n.placeName;
      case TermCategory.organization:
        return l10n.organization;
      case TermCategory.technical:
        return l10n.technicalTerm;
      case TermCategory.general:
        return l10n.general;
      case TermCategory.other:
        return l10n.other;
      default:
        return l10n.general;
    }
  }

  // Helper method to get all category names as a map for UI dropdowns
  static Map<TermCategory, String> getCategoryNames(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return {
      TermCategory.person: l10n.personName,
      TermCategory.place: l10n.placeName,
      TermCategory.organization: l10n.organization,
      TermCategory.technical: l10n.technicalTerm,
      TermCategory.general: l10n.general,
      TermCategory.other: l10n.other,
    };
  }
}
