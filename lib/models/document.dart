// lib/models/document.dart
class Document {
  final String id;
  final String name;
  final List<DocumentLine> lines;
  DateTime importedAt;
  DateTime? lastProcessedAt;

  Document({String? id, required this.name, required this.lines})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        importedAt = DateTime.now();

  void markAsProcessed() {
    lastProcessedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lines': lines.map((line) => line.toJson()).toList(),
      'importedAt': importedAt.toIso8601String(),
      'lastProcessedAt': lastProcessedAt?.toIso8601String(),
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      lines: (json['lines'] as List)
          .map((line) => DocumentLine.fromJson(line))
          .toList(),
    );
  }
}

class DocumentLine {
  final int lineNumber;
  final String chineseText;
  String englishText;
  bool hasCorrections;

  DocumentLine({
    required this.lineNumber,
    required this.chineseText,
    required this.englishText,
    this.hasCorrections = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'lineNumber': lineNumber,
      'chineseText': chineseText,
      'englishText': englishText,
      'hasCorrections': hasCorrections,
    };
  }

  factory DocumentLine.fromJson(Map<String, dynamic> json) {
    return DocumentLine(
      lineNumber: json['lineNumber'],
      chineseText: json['chineseText'],
      englishText: json['englishText'],
      hasCorrections: json['hasCorrections'],
    );
  }
}
