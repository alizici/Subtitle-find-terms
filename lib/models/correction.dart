// lib/models/correction.dart
class Correction {
  final String id;
  final String documentId;
  final int lineNumber;
  final String chineseTerm;
  final String incorrectEnglishTerm;
  final String correctEnglishTerm;
  bool isApplied;
  DateTime createdAt;

  // Düzenleme için geçici değişken - artık sadece düzeltilmiş metni tutuyoruz
  String? editedIncorrectTerm;

  // Ekstra bir ID alanı ekliyoruz, aynı satırdaki aynı terim için tekrarları önlemek için
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
}
