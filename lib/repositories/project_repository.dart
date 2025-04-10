import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';
import '../models/document.dart';
import '../models/correction.dart';

class ProjectRepository extends ChangeNotifier {
  Project? _currentProject;
  final List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  Project? get currentProject => _currentProject;
  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Proje listesini yükle
  Future<void> loadProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/projects');

      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }

      _projects.clear();

      final projectFiles = await projectsDir
          .list()
          .where((entity) => entity.path.endsWith('.json'))
          .toList();

      for (var file in projectFiles) {
        final content = await File(file.path).readAsString();
        try {
          final project = Project.fromJsonString(content);
          _projects.add(project);
        } catch (e) {
          print('Hatalı proje dosyası: ${file.path}, hata: $e');
        }
      }
    } catch (e) {
      _error = 'Projeler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni proje oluştur
  Future<Project> createProject(String name, {String? description}) async {
    final project = Project(
      name: name,
      description: description,
    );

    _projects.add(project);
    _currentProject = project;

    await _saveProject(project);
    notifyListeners();

    return project;
  }

  // Projeyi seç
  void selectProject(String projectId) {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _currentProject = _projects[index];
      notifyListeners();
    }
  }

  // Projeyi sil
  Future<void> deleteProject(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];

      if (project.savePath != null) {
        try {
          final file = File(project.savePath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          _error = 'Proje dosyası silinirken hata oluştu: $e';
        }
      }

      _projects.removeAt(index);

      if (_currentProject?.id == projectId) {
        _currentProject = _projects.isNotEmpty ? _projects.first : null;
      }

      notifyListeners();
    }
  }

  // Belge ekle
  Future<void> addDocument(Document document) async {
    if (_currentProject == null) {
      _error = 'Aktif proje bulunamadı, lütfen önce bir proje oluşturun.';
      notifyListeners();
      return;
    }

    _currentProject!.addDocument(document);
    await _saveProject(_currentProject!);
    notifyListeners();
  }

  // Belge çıkar
  Future<void> removeDocument(String documentId) async {
    if (_currentProject == null) return;

    _currentProject!.removeDocument(documentId);
    await _saveProject(_currentProject!);
    notifyListeners();
  }

  // Düzeltme ekle
  Future<void> addCorrection(Correction correction) async {
    if (_currentProject == null) return;

    _currentProject!.addCorrection(correction);
    await _saveProject(_currentProject!);
    notifyListeners();
  }

  // Düzeltme kaldır
  Future<void> removeCorrection(String correctionId) async {
    if (_currentProject == null) return;

    _currentProject!.removeCorrection(correctionId);
    await _saveProject(_currentProject!);
    notifyListeners();
  }

  // Projeyi dışa aktar
  Future<String> exportProject(Project project) async {
    return project.toJsonString();
  }

  // Projeyi içe aktar
  Future<Project> importProject(String jsonString) async {
    try {
      final project = Project.fromJsonString(jsonString);

      // Aynı ID'ye sahip proje var mı kontrol et
      final existingIndex = _projects.indexWhere((p) => p.id == project.id);
      if (existingIndex != -1) {
        // Projeyi güncelle
        _projects[existingIndex] = project;
      } else {
        // Yeni proje ekle
        _projects.add(project);
      }

      await _saveProject(project);
      notifyListeners();

      return project;
    } catch (e) {
      _error = 'Proje içe aktarılırken hata oluştu: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Projeyi kaydet
  Future<void> _saveProject(Project project) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/projects');

      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }

      final filePath = '${projectsDir.path}/${project.id}.json';
      final file = File(filePath);

      await file.writeAsString(project.toJsonString());

      // Kaydedilen dosya yolunu projede güncelle
      project.savePath = filePath;
    } catch (e) {
      _error = 'Proje kaydedilirken hata oluştu: $e';
      notifyListeners();
    }
  }
}
