// lib/models/document.dart
class Document {
  final String id;
  final String name;
  final List<DocumentLine> lines;
  DateTime importedAt;
  DateTime? lastProcessedAt;
  String? chineseFilePath; // Path of the Chinese file
  String? englishFilePath; // Path of the English file
  String? chineseFileName; // Name of the Chinese file
  String? englishFileName; // Name of the English file
  bool isCompleted; // Altyazının tamamlanıp tamamlanmadığını gösteren değişken

  Document({
    String? id,
    required this.name,
    required this.lines,
    this.chineseFilePath,
    this.englishFilePath,
    this.chineseFileName,
    this.englishFileName,
    this.isCompleted = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        importedAt = DateTime.now();

  void markAsProcessed() {
    lastProcessedAt = DateTime.now();
  }

  void markAsCompleted(bool completed) {
    isCompleted = completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lines': lines.map((line) => line.toJson()).toList(),
      'importedAt': importedAt.toIso8601String(),
      'lastProcessedAt': lastProcessedAt?.toIso8601String(),
      'chineseFilePath': chineseFilePath,
      'englishFilePath': englishFilePath,
      'chineseFileName': chineseFileName,
      'englishFileName': englishFileName,
      'isCompleted': isCompleted,
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      lines: (json['lines'] as List)
          .map((line) => DocumentLine.fromJson(line))
          .toList(),
      chineseFilePath: json['chineseFilePath'],
      englishFilePath: json['englishFilePath'],
      chineseFileName: json['chineseFileName'],
      englishFileName: json['englishFileName'],
      isCompleted: json['isCompleted'] ?? false,
    )
      ..importedAt = json['importedAt'] != null
          ? DateTime.parse(json['importedAt'])
          : DateTime.now()
      ..lastProcessedAt = json['lastProcessedAt'] != null
          ? DateTime.parse(json['lastProcessedAt'])
          : null;
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
      hasCorrections: json['hasCorrections'] ?? false,
    );
  }
}
