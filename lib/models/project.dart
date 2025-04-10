import 'dart:convert';
import 'document.dart';
import 'correction.dart';

class Project {
  final String id;
  String name;
  String? description;
  List<Document> documents;
  List<Correction> corrections;
  DateTime createdAt;
  DateTime updatedAt;
  String? savePath; // Projenin kaydedildiği dosya yolu

  Project({
    String? id,
    required this.name,
    this.description,
    List<Document>? documents,
    List<Correction>? corrections,
    this.savePath,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        documents = documents ?? [],
        corrections = corrections ?? [],
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  // Bir belgeyi projeye ekler
  void addDocument(Document document) {
    documents.add(document);
    updatedAt = DateTime.now();
  }

  // Bir belgeyi projeden kaldırır
  void removeDocument(String documentId) {
    documents.removeWhere((doc) => doc.id == documentId);
    updatedAt = DateTime.now();
  }

  // Bir düzeltmeyi projeye ekler
  void addCorrection(Correction correction) {
    // Aynı satır ve terim için mevcut bir düzeltme var mı kontrol et
    final existingIndex =
        corrections.indexWhere((c) => c.uniqueKey == correction.uniqueKey);
    if (existingIndex != -1) {
      // Var olan düzeltmeyi güncelle
      corrections[existingIndex] = correction;
    } else {
      // Yeni düzeltme ekle
      corrections.add(correction);
    }
    updatedAt = DateTime.now();
  }

  // Bir düzeltmeyi projeden kaldırır
  void removeCorrection(String correctionId) {
    corrections.removeWhere((corr) => corr.id == correctionId);
    updatedAt = DateTime.now();
  }

  // JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'corrections': corrections.map((corr) => corr.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'savePath': savePath,
    };
  }

  // JSON'dan oluşturma
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      documents: (json['documents'] as List)
          .map((doc) => Document.fromJson(doc))
          .toList(),
      corrections: (json['corrections'] as List)
          .map((corr) => Correction.fromJson(corr))
          .toList(),
      savePath: json['savePath'],
    );
  }

  // Projeyi JSON string'e dönüştürme
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // JSON string'den proje oluşturma
  static Project fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Project.fromJson(json);
  }
}
