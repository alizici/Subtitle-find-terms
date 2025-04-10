// lib/utils/file_handler.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/term_pair.dart';

class FileHandler {
  /// Dosya içeriğini satırlar olarak okur
  static Future<List<String>> readFileLines(File file) async {
    try {
      final String content = await file.readAsString();

      // Satır sonlandırıcıları standartlaştır
      final normalizedContent =
          content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      return normalizedContent.split('\n');
    } catch (e) {
      rethrow;
    }
  }

  /// İki metin dosyası içeriğini karşılaştırır
  static Future<bool> compareFiles(File file1, File file2) async {
    try {
      final content1 = await file1.readAsString();
      final content2 = await file2.readAsString();

      return content1 == content2;
    } catch (e) {
      return false;
    }
  }

  /// JSON formatında terim çiftlerini dosyadan yükler
  static Future<List<TermPair>> loadTermsFromJson(File file) async {
    try {
      final String content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      return jsonList.map((json) => TermPair.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// CSV formatında terim çiftlerini dosyadan yükler
  static Future<List<TermPair>> loadTermsFromCsv(File file) async {
    try {
      final List<String> lines = await readFileLines(file);
      final List<TermPair> terms = [];

      // Başlık satırını atla
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(',');
        if (parts.length < 2) continue;

        final chineseTerm = parts[0].trim();
        final englishTerm = parts[1].trim();

        TermCategory category = TermCategory.general;
        String? notes;

        if (parts.length > 2) {
          final categoryStr = parts[2].trim().toLowerCase();
          category = _parseCategory(categoryStr);
        }

        if (parts.length > 3) {
          notes = parts[3].trim();
          if (notes.isEmpty) notes = null;
        }

        terms.add(
          TermPair(
            chineseTerm: chineseTerm,
            englishTerm: englishTerm,
            category: category,
            notes: notes,
          ),
        );
      }

      return terms;
    } catch (e) {
      rethrow;
    }
  }

  /// Terim kategorisi parse etme
  static TermCategory _parseCategory(String categoryStr) {
    // Lokalizasyon için context'imiz olmadığından, kategori isimlerini birebir kontrol ediyoruz
    switch (categoryStr) {
      case 'person':
      case 'kişi':
      case 'kişi ismi':
      case '人物': // Çince kategori adı
        return TermCategory.person;
      case 'place':
      case 'yer':
      case 'yer ismi':
      case '地点': // Çince kategori adı
        return TermCategory.place;
      case 'organization':
      case 'organizasyon':
      case '组织': // Çince kategori adı
        return TermCategory.organization;
      case 'technical':
      case 'teknik':
      case 'teknik terim':
      case '技术': // Çince kategori adı
        return TermCategory.technical;
      case 'other':
      case 'diğer':
      case '其他': // Çince kategori adı
        return TermCategory.other;
      default:
        return TermCategory.general;
    }
  }

  /// Uygulama belgeleri dizininde dosya oluşturur veya günceller
  static Future<File> createOrUpdateFile(
    String fileName,
    String content,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      return await file.writeAsString(content);
    } catch (e) {
      rethrow;
    }
  }

  /// Dosya seçici ile dosya seçme
  static Future<File?> pickFile(List<String> allowedExtensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Kayıt yeri seçici ile dosya kaydetme
  static Future<File?> saveFile(
    String content,
    String fileName,
    String extension,
    BuildContext context,
  ) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: AppLocalizations.of(context)!.save,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [extension],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(content);
        return file;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
