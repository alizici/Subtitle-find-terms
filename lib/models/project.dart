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
  String? savePath; // Path where the project is saved

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

  // Adds a document to the project
  void addDocument(Document document) {
    documents.add(document);
    updatedAt = DateTime.now();
  }

  // Removes a document from the project
  void removeDocument(String documentId) {
    documents.removeWhere((doc) => doc.id == documentId);
    updatedAt = DateTime.now();
  }

  // Adds a correction to the project
  void addCorrection(Correction correction) {
    // Check if a correction for the same line and term already exists
    final existingIndex =
        corrections.indexWhere((c) => c.uniqueKey == correction.uniqueKey);
    if (existingIndex != -1) {
      // Update existing correction
      corrections[existingIndex] = correction;
    } else {
      // Add new correction
      corrections.add(correction);
    }
    updatedAt = DateTime.now();
  }

  // Removes a correction from the project
  void removeCorrection(String correctionId) {
    corrections.removeWhere((corr) => corr.id == correctionId);
    updatedAt = DateTime.now();
  }

  // Convert to JSON
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

  // Create from JSON
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

  // Convert project to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create project from JSON string
  static Project fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Project.fromJson(json);
  }
}
