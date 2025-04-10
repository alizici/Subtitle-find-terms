// lib/repositories/term_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';
import '../models/term_pair.dart';
import '../models/project.dart';

class TermRepository extends ChangeNotifier {
  // Projeye göre terimleri tutan map
  final Map<String, List<TermPair>> _projectTerms = {};
  String? _currentProjectId;
  bool _isLoading = false;
  String? _error;
  String? _importResult;

  // Mevcut projeye ait terimler
  List<TermPair> get terms {
    if (_currentProjectId == null) return [];
    return List.unmodifiable(_projectTerms[_currentProjectId] ?? []);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get importResult => _importResult;

  TermRepository() {
    _loadAllProjectTerms();
  }

  // Aktif projeyi ayarla
  void setCurrentProject(Project project) {
    final oldProjectId = _currentProjectId;
    _currentProjectId = project.id;

    if (!_projectTerms.containsKey(project.id)) {
      _projectTerms[project.id] = [];
      _loadProjectTerms(project.id);
    } else {
      // Proje değiştiyse bildir
      if (oldProjectId != project.id) {
        notifyListeners();
      }
    }
  }

  // Sonucu temizlemek için metod
  void clearImportResult() {
    _importResult = null;
    notifyListeners();
  }

  // Tüm projelerin terimlerini yükle
  Future<void> _loadAllProjectTerms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final termsDir = Directory('${directory.path}/terms');

      if (!await termsDir.exists()) {
        await termsDir.create(recursive: true);
      }

      final files =
          await termsDir.list().where((f) => f.path.endsWith('.json')).toList();

      for (var file in files) {
        final fileName = file.path.split('/').last;
        final projectId =
            fileName.replaceAll('terms_', '').replaceAll('.json', '');

        if (projectId.isNotEmpty) {
          final content = await File(file.path).readAsString();
          final List<dynamic> jsonList = jsonDecode(content);
          _projectTerms[projectId] =
              jsonList.map((json) => TermPair.fromJson(json)).toList();
        }
      }
    } catch (e) {
      _error = 'Terimler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir projenin terimlerini yükle
  Future<void> _loadProjectTerms(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/terms/terms_$projectId.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _projectTerms[projectId] =
            jsonList.map((json) => TermPair.fromJson(json)).toList();
      } else {
        _projectTerms[projectId] = [];
      }
    } catch (e) {
      _error = 'Terimler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir projenin terimlerini kaydet
  Future<void> _saveProjectTerms(String projectId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final termsDir = Directory('${directory.path}/terms');

      if (!await termsDir.exists()) {
        await termsDir.create(recursive: true);
      }

      final file = File('${directory.path}/terms/terms_$projectId.json');
      final jsonList =
          _projectTerms[projectId]?.map((term) => term.toJson()).toList() ?? [];
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      _error = 'Terimler kaydedilirken hata oluştu: $e';
      notifyListeners();
    }
  }

  Future<void> addTerm(TermPair term) async {
    if (_currentProjectId == null) return;

    if (!_projectTerms.containsKey(_currentProjectId!)) {
      _projectTerms[_currentProjectId!] = [];
    }

    _projectTerms[_currentProjectId!]!.add(term);
    await _saveProjectTerms(_currentProjectId!);
    notifyListeners();
  }

  Future<void> updateTerm(TermPair term) async {
    if (_currentProjectId == null) return;

    if (!_projectTerms.containsKey(_currentProjectId!)) return;

    final index =
        _projectTerms[_currentProjectId!]!.indexWhere((t) => t.id == term.id);
    if (index != -1) {
      _projectTerms[_currentProjectId!]![index] = term;
      await _saveProjectTerms(_currentProjectId!);
      notifyListeners();
    }
  }

  Future<void> deleteTerm(String id) async {
    if (_currentProjectId == null) return;

    if (!_projectTerms.containsKey(_currentProjectId!)) return;

    final termToRemove = _projectTerms[_currentProjectId!]!
        .firstWhereOrNull((term) => term.id == id);

    if (termToRemove != null) {
      _projectTerms[_currentProjectId!]!.remove(termToRemove);
    }

    await _saveProjectTerms(_currentProjectId!);
    notifyListeners();
  }

  TermPair? findTermByChineseTerm(String chineseTerm) {
    if (_currentProjectId == null) return null;

    if (!_projectTerms.containsKey(_currentProjectId!)) return null;

    return _projectTerms[_currentProjectId!]!
        .firstWhereOrNull((term) => term.chineseTerm == chineseTerm);
  }

  List<TermPair> findTermsByCategory(TermCategory category) {
    if (_currentProjectId == null) return [];

    if (!_projectTerms.containsKey(_currentProjectId!)) return [];

    return _projectTerms[_currentProjectId!]!
        .where((term) => term.category == category)
        .toList();
  }

  Future<void> importTerms(String jsonContent) async {
    if (_currentProjectId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final List<dynamic> jsonList = jsonDecode(jsonContent);
      final importedTerms =
          jsonList.map((json) => TermPair.fromJson(json)).toList();

      int duplicateCount = 0;
      int addedCount = 0;

      if (!_projectTerms.containsKey(_currentProjectId!)) {
        _projectTerms[_currentProjectId!] = [];
      }

      // Merge with existing terms, avoiding duplicates
      for (var importedTerm in importedTerms) {
        final existingIndex = _projectTerms[_currentProjectId!]!
            .indexWhere((t) => t.chineseTerm == importedTerm.chineseTerm);

        if (existingIndex == -1) {
          _projectTerms[_currentProjectId!]!.add(importedTerm);
          addedCount++;
        } else {
          duplicateCount++;
        }
      }

      await _saveProjectTerms(_currentProjectId!);

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
    if (_currentProjectId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      List<TermPair> importedTerms = [];
      TermCategory currentCategory = TermCategory.general;
      int duplicateCount = 0;
      int addedCount = 0;

      if (!_projectTerms.containsKey(_currentProjectId!)) {
        _projectTerms[_currentProjectId!] = [];
      }

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
            bool isDuplicate = _projectTerms[_currentProjectId!]!
                .any((t) => t.chineseTerm == chineseTerm);

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
      _projectTerms[_currentProjectId!]!.addAll(importedTerms);
      await _saveProjectTerms(_currentProjectId!);

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
    if (_currentProjectId == null) return '[]';

    if (!_projectTerms.containsKey(_currentProjectId!)) return '[]';

    final jsonList = _projectTerms[_currentProjectId!]
            ?.map((term) => term.toJson())
            .toList() ??
        [];
    return jsonEncode(jsonList);
  }

  // Belirli bir indeksteki terimi sil
  Future<void> deleteTermByIndex(int index) async {
    if (_currentProjectId == null) return;

    if (!_projectTerms.containsKey(_currentProjectId!)) return;

    // İndeks kontrol et
    if (index < 0 || index >= _projectTerms[_currentProjectId!]!.length) {
      return;
    }

    // İndeks ile terimi sil
    _projectTerms[_currentProjectId!]!.removeAt(index);

    await _saveProjectTerms(_currentProjectId!);
    notifyListeners();
  }
}
