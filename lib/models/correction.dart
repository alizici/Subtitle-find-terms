// lib/models/correction.dart
import 'package:flutter/material.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';

class Correction {
  final String id;
  final String documentId;
  final int lineNumber;
  final String chineseTerm;
  final String incorrectEnglishTerm;
  final String correctEnglishTerm;
  bool isApplied;
  DateTime createdAt;

  // Temporary variable for editing - now we only store the corrected text
  String? editedIncorrectTerm;

  // Extra ID field to prevent duplicates for the same term on the same line
  String get uniqueKey => '$lineNumber:$chineseTerm:$incorrectEnglishTerm';

  Correction({
    String? id,
    required this.documentId,
    required this.lineNumber,
    required this.chineseTerm,
    required this.incorrectEnglishTerm,
    required this.correctEnglishTerm,
    this.isApplied = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now(),
        editedIncorrectTerm = null;

  void apply() {
    isApplied = true;
  }

  void revert() {
    isApplied = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'lineNumber': lineNumber,
      'chineseTerm': chineseTerm,
      'incorrectEnglishTerm': incorrectEnglishTerm,
      'correctEnglishTerm': correctEnglishTerm,
      'isApplied': isApplied,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Correction.fromJson(Map<String, dynamic> json) {
    return Correction(
      id: json['id'],
      documentId: json['documentId'],
      lineNumber: json['lineNumber'],
      chineseTerm: json['chineseTerm'],
      incorrectEnglishTerm: json['incorrectEnglishTerm'],
      correctEnglishTerm: json['correctEnglishTerm'],
      isApplied: json['isApplied'],
    );
  }

  @override
  String toString() {
    return 'Correction{id: $id, lineNumber: $lineNumber, chineseTerm: $chineseTerm, incorrectEnglishTerm: $incorrectEnglishTerm, correctEnglishTerm: $correctEnglishTerm, isApplied: $isApplied}';
  }

  // Helper method to get status text based on the current locale
  String getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return isApplied ? l10n.appliedStatus : l10n.pending;
  }

  // Helper method to get line number text
  String getLineText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return '${l10n.linePrefix}: $lineNumber';
  }
}
