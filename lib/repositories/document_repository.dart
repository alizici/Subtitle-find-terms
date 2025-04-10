// lib/repositories/document_repository.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../models/correction.dart';
import '../utils/ass_parser.dart';

class DocumentRepository extends ChangeNotifier {
  // Ekranlar arası durumu korumak için statik değişkenler
  static Document? _loadedDocument;
  static List<File>? _loadedFiles;
  static List<Correction> _savedCorrections = [];

  Document? _currentDocument;
  final List<Correction> _corrections = [];
  bool _isLoading = false;
  String? _error;

  Document? get currentDocument => _currentDocument;
  List<Correction> get corrections => List.unmodifiable(_corrections);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Belgeyi göstermeden önce önceden yüklenen belgeyi kontrol et
  DocumentRepository() {
    // Eğer statik olarak saklanmış bir belge ve düzeltmeler varsa, onları kullan
    if (_loadedDocument != null) {
      _currentDocument = _loadedDocument;
      _corrections.addAll(_savedCorrections);
      notifyListeners();
    }
  }

  Future<void> loadDocument(File chineseFile, File englishFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<String> chineseLines = [];
      List<String> englishLines = [];

      if (chineseFile.path.toLowerCase().endsWith('.ass')) {
        final chineseContent = await chineseFile.readAsString();
        final chineseEvents = parseAssContent(chineseContent);
        chineseLines = chineseEvents.map((event) => event.text).toList();
      } else {
        chineseLines = await chineseFile.readAsLines();
      }

      if (englishFile.path.toLowerCase().endsWith('.ass')) {
        final englishContent = await englishFile.readAsString();
        final englishEvents = parseAssContent(englishContent);
        englishLines = englishEvents.map((event) => event.text).toList();
      } else {
        englishLines = await englishFile.readAsLines();
      }

      // Ensure both files have the same number of lines
      final minLines = chineseLines.length < englishLines.length
          ? chineseLines.length
          : englishLines.length;

      final documentLines = List.generate(minLines, (index) {
        return DocumentLine(
          lineNumber: index + 1,
          chineseText: chineseLines[index],
          englishText: englishLines[index],
        );
      });

      _currentDocument = Document(
        name: chineseFile.path.split('/').last,
        lines: documentLines,
      );

      // Statik değişkenlere kaydet
      _loadedDocument = _currentDocument;
      _loadedFiles = [chineseFile, englishFile];

      _corrections.clear();
      _savedCorrections.clear();
    } catch (e) {
      _error = 'Belge yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDocument(String outputPath) async {
    if (_currentDocument == null) return;

    try {
      final baseName = _currentDocument!.name.contains('.')
          ? _currentDocument!.name
              .substring(0, _currentDocument!.name.lastIndexOf('.'))
          : _currentDocument!.name;

      // Orijinal dosya .ass uzantılı mı kontrol et
      final isAssFile = _currentDocument!.name.toLowerCase().endsWith('.ass');
      final extension = isAssFile ? 'ass' : 'txt';

      final chineseOutput = File(
        '$outputPath/${baseName}_chinese.$extension',
      );
      final englishOutput = File(
        '$outputPath/${baseName}_english.$extension',
      );

      // ASS dosyaları için şablon içerik
      if (isAssFile) {
        // Basit bir ASS dosya şablonu
        const assHeader = '''[Script Info]
Title: Generated ASS File
ScriptType: v4.00+
WrapStyle: 0
PlayResX: 1280
PlayResY: 720
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,20,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,2,2,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
''';

        String chineseContent = assHeader;
        String englishContent = assHeader;

        // Her satır için Dialogue satırı oluştur
        for (int i = 0; i < _currentDocument!.lines.length; i++) {
          final line = _currentDocument!.lines[i];
          final start = _formatAssTime(
              i * 2); // Basit zaman hesaplama (2 saniye aralıklar)
          final end = _formatAssTime(i * 2 + 2);

          chineseContent +=
              'Dialogue: 0,$start,$end,Default,,0,0,0,,${line.chineseText}\n';
          englishContent +=
              'Dialogue: 0,$start,$end,Default,,0,0,0,,${line.englishText}\n';
        }

        await chineseOutput.writeAsString(chineseContent);
        await englishOutput.writeAsString(englishContent);
      } else {
        // Normal metin dosyaları
        await chineseOutput.writeAsString(
          _currentDocument!.lines.map((line) => line.chineseText).join('\n'),
        );

        await englishOutput.writeAsString(
          _currentDocument!.lines.map((line) => line.englishText).join('\n'),
        );
      }

      _currentDocument!.markAsProcessed();
      notifyListeners();
    } catch (e) {
      _error = 'Belge kaydedilirken hata oluştu: $e';
      notifyListeners();
    }
  }

  // ASS zaman formatını oluşturmak için yardımcı fonksiyon
  String _formatAssTime(int seconds) {
    final hrs = (seconds ~/ 3600).toString().padLeft(1, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hrs:$mins:$secs.00';
  }

  void addCorrection(Correction correction) {
    // Önce aynı satır ve terim için mevcut bir düzeltme olup olmadığını kontrol et
    final existingIndex =
        _corrections.indexWhere((c) => c.uniqueKey == correction.uniqueKey);

    if (existingIndex != -1) {
      // Aynı satır ve terim için zaten bir düzeltme var, üzerine yazma
      print(
          "Aynı satır ve terim için var olan düzeltme güncellendi: ${correction.uniqueKey}");
      return;
    }

    // Yeni düzeltmeyi ekle
    _corrections.add(correction);

    // Statik listeye de ekle
    _savedCorrections.add(correction);

    if (_currentDocument != null) {
      final lineIndex = _currentDocument!.lines.indexWhere(
        (line) => line.lineNumber == correction.lineNumber,
      );

      if (lineIndex != -1) {
        _currentDocument!.lines[lineIndex].hasCorrections = true;
      }
    }

    notifyListeners();
  }

  void applyAllCorrections() {
    if (_currentDocument == null) {
      print("Belge yok, düzeltmeler uygulanamıyor.");
      return;
    }

    int appliedCount = 0;
    int failedCount = 0;

    print(
        "Tüm düzeltmeler uygulanıyor (${_corrections.where((c) => !c.isApplied).length} adet)...");

    for (var correction in _corrections.where((c) => !c.isApplied)) {
      // Satır metin değişiklikleri güncellenmiş versiyonla yapılacak
      if (correction.editedIncorrectTerm != null) {
        applyCustomCorrection(
            correction.id, correction.editedIncorrectTerm!, "");
        appliedCount++;
      } else {
        final lineIndex = _currentDocument!.lines.indexWhere(
          (line) => line.lineNumber == correction.lineNumber,
        );

        if (lineIndex != -1) {
          final line = _currentDocument!.lines[lineIndex];

          // applyCustomCorrection metodunu kullan
          applyCustomCorrection(correction.id, line.englishText, "");
          appliedCount++;
        } else {
          failedCount++;
          print("Satır bulunamadı: ${correction.lineNumber}");
        }
      }
    }

    print(
        "Düzeltme işlemi tamamlandı: $appliedCount başarılı, $failedCount başarısız.");
    notifyListeners();
  }

  void clearCorrections() {
    _corrections.clear();
    _savedCorrections.clear();

    if (_currentDocument != null) {
      for (var line in _currentDocument!.lines) {
        line.hasCorrections = false;
      }
    }

    notifyListeners();
  }

  /// Belirli bir satırdaki düzeltmeleri temizler
  void clearLineCorrections(int lineNumber) {
    // Yerel listeden kaldır
    _corrections
        .removeWhere((correction) => correction.lineNumber == lineNumber);

    // Statik listeden de kaldır
    _savedCorrections
        .removeWhere((correction) => correction.lineNumber == lineNumber);

    if (_currentDocument != null) {
      final lineIndex = _currentDocument!.lines.indexWhere(
        (line) => line.lineNumber == lineNumber,
      );

      if (lineIndex != -1) {
        // Başka düzeltme kalmadıysa düzeltme bayrağını kaldır
        if (!_corrections.any((c) => c.lineNumber == lineNumber)) {
          _currentDocument!.lines[lineIndex].hasCorrections = false;
        }
      }
    }

    notifyListeners();
  }

  Map<String, int> getTermCorrectionStats() {
    Map<String, int> stats = {};

    for (var correction in _corrections) {
      final key =
          '${correction.chineseTerm} (${correction.incorrectEnglishTerm} → ${correction.correctEnglishTerm})';
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }

  // Düzenlenmiş düzeltmeyi uygulamak için metot
  void applyCustomCorrection(
      String correctionId, String newIncorrectTerm, String newCorrectTerm) {
    print("Düzenlenmiş düzeltme repository'de uygulanıyor - ID: $correctionId");
    print("  Kullanıcının düzelttiği metin: $newIncorrectTerm");

    final correctionIndex =
        _corrections.indexWhere((c) => c.id == correctionId);

    if (correctionIndex != -1 && _currentDocument != null) {
      final correction = _corrections[correctionIndex];
      print(
          "  Düzeltme bulundu: ID=${correction.id}, Satır=${correction.lineNumber}, Çince Terim=${correction.chineseTerm}");

      // Belgedeki ilgili satırı bul
      final lineIndex = _currentDocument!.lines.indexWhere(
        (line) => line.lineNumber == correction.lineNumber,
      );

      if (lineIndex != -1) {
        // Satırı al
        final line = _currentDocument!.lines[lineIndex];

        print("  Satır ${correction.lineNumber} düzeltiliyor");
        print("  Orijinal satır metni: ${line.englishText}");

        // DÜZELTME: Kullanıcının girdiği metni doğrudan tüm satıra yerleştirmek yerine
        // sadece belirli bir kelimeyi değiştiriyoruz
        if (correction.editedIncorrectTerm != null) {
          // Eğer kullanıcı tarafından düzenlenmiş bir metin varsa, o zaman
          // orijinal metinden bu düzenlenen metne değiştirme yap
          if (line.englishText.contains(correction.incorrectEnglishTerm)) {
            line.englishText = line.englishText.replaceAll(
              correction.incorrectEnglishTerm,
              newIncorrectTerm,
            );
            print(
                "  Belirli kısım değiştirildi: ${correction.incorrectEnglishTerm} -> $newIncorrectTerm");
          } else {
            // Eğer tam eşleşme yoksa, benzer bir kelime bulmaya çalış
            try {
              final pattern = RegExp(
                  correction.incorrectEnglishTerm.replaceAll(r'$', r'\$'),
                  caseSensitive: false);
              if (pattern.hasMatch(line.englishText)) {
                line.englishText =
                    line.englishText.replaceAll(pattern, newIncorrectTerm);
                print(
                    "  Esnek eşleşme ile düzeltildi: ${correction.incorrectEnglishTerm} -> $newIncorrectTerm");
              } else {
                // Hala bir eşleşme bulunamadıysa, basit bir arama yap
                final englishLower = line.englishText.toLowerCase();
                final incorrectLower =
                    correction.incorrectEnglishTerm.toLowerCase();

                if (englishLower.contains(incorrectLower)) {
                  // Aynı büyük/küçük harf durumunu koru
                  final startIndex = englishLower.indexOf(incorrectLower);
                  final endIndex = startIndex + incorrectLower.length;

                  final before = line.englishText.substring(0, startIndex);
                  final after = line.englishText.substring(endIndex);

                  line.englishText = before + newIncorrectTerm + after;
                  print(
                      "  Basit eşleşme ile düzeltildi: ${correction.incorrectEnglishTerm} -> $newIncorrectTerm");
                } else {
                  print(
                      "  Hiçbir şekilde eşleşme bulunamadı! Tüm satır değiştiriliyor...");
                  line.englishText = newIncorrectTerm;
                }
              }
            } catch (e) {
              print("  Regex hatası: $e - Doğrudan değiştirme yapılıyor");
              line.englishText = newIncorrectTerm;
            }
          }
        } else {
          // Kullanıcı tarafından düzenlenmiş metin yoksa, tam metin yerleştirme yap
          line.englishText = newIncorrectTerm;
          print("  Tüm satır metni değiştirildi: $newIncorrectTerm");
        }

        // Düzeltmeyi uygulanmış olarak işaretle
        correction.apply();

        print("  Düzeltme sonrası metin: ${line.englishText}");

        // Tekrarları önlemek için aynı satırdaki diğer düzeltmeleri de uygula
        final sameLineCorrections = _corrections
            .where((c) =>
                c.lineNumber == correction.lineNumber &&
                c.id != correctionId &&
                !c.isApplied)
            .toList();

        if (sameLineCorrections.isNotEmpty) {
          print(
              "  Aynı satırdaki diğer düzeltmeler otomatik olarak uygulandı (${sameLineCorrections.length} adet)");

          // Aynı satırdaki diğer düzeltmeleri de uygulanmış olarak işaretle
          for (var otherCorrection in sameLineCorrections) {
            otherCorrection.apply();
          }
        }

        notifyListeners();
        return;
      } else {
        print("  Düzeltme için satır bulunamadı: ${correction.lineNumber}");
        print(
            "  Mevcut satırlar: ${_currentDocument!.lines.map((l) => l.lineNumber).toList()}");

        // Satır bulunamadı, bu durumda belgedeki tüm satırlardaki metin içinde arama yapalım
        for (int i = 0; i < _currentDocument!.lines.length; i++) {
          final line = _currentDocument!.lines[i];
          if (line.englishText.contains(correction.incorrectEnglishTerm)) {
            print(
                "  Hatalı terim satır ${line.lineNumber}'de bulundu, düzeltme uygulanıyor");

            // Düzeltmeyi bu satıra uygulayalım
            line.englishText = newIncorrectTerm;

            // Düzeltmenin satır numarasını güncellemek için yeni bir düzeltme oluşturalım
            final newCorrection = Correction(
              id: correction.id,
              documentId: correction.documentId,
              lineNumber: line.lineNumber,
              chineseTerm: correction.chineseTerm,
              incorrectEnglishTerm: correction.incorrectEnglishTerm,
              correctEnglishTerm: correction.correctEnglishTerm,
            );

            // Eski düzeltmeyi kaldır, yeni düzeltmeyi ekle
            _corrections[correctionIndex] = newCorrection;
            newCorrection.apply();

            print("  Satır ${line.lineNumber} düzeltildi: ${line.englishText}");
            notifyListeners();
            return;
          }
        }
      }
    } else {
      print("  Düzeltme bulunamadı: $correctionId");
      print(
          "  Mevcut düzeltmeler: ${_corrections.map((c) => "${c.id} (Satır: ${c.lineNumber})").toList()}");
    }

    // Eğer buraya kadar gelindiyse, düzeltme uygulanamadı demektir
    _error = "Düzeltme uygulanamadı. Belge değişmiş olabilir.";
    notifyListeners();
  }
}
