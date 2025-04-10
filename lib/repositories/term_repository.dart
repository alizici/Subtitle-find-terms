// lib/repositories/term_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';
import '../models/term_pair.dart';

class TermRepository extends ChangeNotifier {
  final List<TermPair> _terms = [];
  bool _isLoading = false;
  String? _error;
  String? _importResult;

  List<TermPair> get terms => List.unmodifiable(_terms);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get importResult => _importResult;

  TermRepository() {
    _loadTerms();
  }

  // Sonucu temizlemek için metod
  void clearImportResult() {
    _importResult = null;
    notifyListeners();
  }

  Future<void> _loadTerms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/terms.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _terms.clear();
        _terms.addAll(jsonList.map((json) => TermPair.fromJson(json)).toList());
      }
    } catch (e) {
      _error = 'Terimler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTerms() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/terms.json');
      final jsonList = _terms.map((term) => term.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      _error = 'Terimler kaydedilirken hata oluştu: $e';
      notifyListeners();
    }
  }

  Future<void> addTerm(TermPair term) async {
    _terms.add(term);
    await _saveTerms();
    notifyListeners();
  }

  Future<void> updateTerm(TermPair term) async {
    final index = _terms.indexWhere((t) => t.id == term.id);
    if (index != -1) {
      _terms[index] = term;
      await _saveTerms();
      notifyListeners();
    }
  }

  Future<void> deleteTerm(String id) async {
    _terms.removeWhere((term) => term.id == id);
    await _saveTerms();
    notifyListeners();
  }

  TermPair? findTermByChineseTerm(String chineseTerm) {
    return _terms.firstWhereOrNull((term) => term.chineseTerm == chineseTerm);
  }

  List<TermPair> findTermsByCategory(TermCategory category) {
    return _terms.where((term) => term.category == category).toList();
  }

  Future<void> importTerms(String jsonContent) async {
    try {
      _isLoading = true;
      notifyListeners();

      final List<dynamic> jsonList = jsonDecode(jsonContent);
      final importedTerms =
          jsonList.map((json) => TermPair.fromJson(json)).toList();

      int duplicateCount = 0;
      int addedCount = 0;

      // Merge with existing terms, avoiding duplicates
      for (var importedTerm in importedTerms) {
        final existingIndex =
            _terms.indexWhere((t) => t.chineseTerm == importedTerm.chineseTerm);
        if (existingIndex == -1) {
          _terms.add(importedTerm);
          addedCount++;
        } else {
          duplicateCount++;
        }
      }

      await _saveTerms();

      // Sonucu error değil importResult'a kaydet
      _importResult =
          '$addedCount terim eklendi, $duplicateCount terim zaten var olduğu için eklenmedi.';
      _error = null;
    } catch (e) {
      _error = 'Terimler içe aktarılırken hata oluştu: $e';
      _importResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importTermsFromTxt(String txtContent) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<TermPair> importedTerms = [];
      TermCategory currentCategory = TermCategory.general;
      int duplicateCount = 0;
      int addedCount = 0;

      final lines = txtContent.split('\n');
      for (var line in lines) {
        line = line.trim();

        // Eğer satır boşsa atla
        if (line.isEmpty) continue;

        // Sadece sayı olup olmadığını kontrol et (kategori indeksi)
        if (RegExp(r'^\d+$').hasMatch(line)) {
          int index = int.parse(line);
          if (index >= 0 && index < TermCategory.values.length) {
            currentCategory = TermCategory.values[index];
          }
          continue;
        }

        // Kategori satırı kontrolü (metin açıklamalar için)
        if (!line.contains('-')) {
          // Kategori adını belirle
          if (line.toLowerCase().contains('kişi')) {
            currentCategory = TermCategory.person;
          } else if (line.toLowerCase().contains('tarikat') ||
              line.toLowerCase().contains('organizasyon') ||
              line.toLowerCase().contains('sect')) {
            currentCategory = TermCategory.organization;
          } else if (line.toLowerCase().contains('yer')) {
            currentCategory = TermCategory.place;
          } else if (line.toLowerCase().contains('teknik')) {
            currentCategory = TermCategory.technical;
          } else {
            currentCategory = TermCategory.other;
          }
          continue;
        }

        // Terim çifti ayrıştırma
        final parts = line.split('-');
        if (parts.length == 2) {
          final chineseTerm = parts[0].trim();
          final englishTerm = parts[1].trim();

          if (chineseTerm.isNotEmpty && englishTerm.isNotEmpty) {
            // Önce mevcut terimlerde aynı çince terim var mı kontrol et
            bool isDuplicate = _terms.any((t) => t.chineseTerm == chineseTerm);

            // Sonra import edilenler listesinde de var mı kontrol et
            if (!isDuplicate) {
              isDuplicate =
                  importedTerms.any((t) => t.chineseTerm == chineseTerm);
            }

            if (!isDuplicate) {
              importedTerms.add(TermPair(
                chineseTerm: chineseTerm,
                englishTerm: englishTerm,
                category: currentCategory,
              ));
              addedCount++;
            } else {
              duplicateCount++;
            }
          }
        }
      }

      // Benzersiz terimleri ekle
      _terms.addAll(importedTerms);
      await _saveTerms();

      // Sonucu error değil importResult'a kaydet
      _importResult =
          '$addedCount terim eklendi, $duplicateCount terim zaten var olduğu için eklenmedi.';
      _error = null;
    } catch (e) {
      _error = 'TXT dosyasından terimler içe aktarılırken hata oluştu: $e';
      _importResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> exportTerms() async {
    final jsonList = _terms.map((term) => term.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
