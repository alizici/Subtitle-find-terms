// lib/services/correction_service.dart
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';

import '../models/document.dart';
import '../models/correction.dart';
import '../repositories/document_repository.dart';
import 'term_matcher.dart';
import 'package:flutter/material.dart';

class CorrectionService {
  final TermMatcher _termMatcher;
  final BuildContext? context;

  CorrectionService(this._termMatcher, {this.context});

  Object _getLocalizedString(String key) {
    if (context == null) return key;
    final localizations = AppLocalizations.of(context!);
    if (localizations == null) return key;

    // Map service's hardcoded strings to the localized versions
    switch (key) {
      case 'Satır bulunamadı':
        return localizations.lineNotFound;
      case 'Belge işleniyor':
        return localizations.processingDocument;
      case 'satır işleniyor':
        return localizations.processingLine;
      case 'terim eşleşmesi bulundu':
        return localizations.termMatchesFound;
      case 'UYARI':
        return localizations.warning;
      case 'Eşleşme satır numarası':
        return localizations.mismatchedLineNumbers;
      case 'Düzeltiliyor':
        return localizations.correcting;
      case 'Düzeltme':
        return localizations.correction;
      case 'olması gereken':
        return localizations.shouldBe;
      case 'Hatalı terim':
        return localizations.incorrectTermNotFound;
      case 'satır':
        return localizations.inLine;
      case 'metninde bulunamadı':
        return localizations.incorrectTermNotFound;
      case 'düzeltme uygulandı':
        return localizations.correctionsApplied;
      case 'Uygulanacak düzeltme bulunamadı':
        return localizations.noCorrectionsToApply;
      case 'doğru':
        return localizations.correct;
      case 'toplam':
        return localizations.total;
      case 'Tutarlılık puanı':
        return localizations.consistencyScore;
      case 'tekrarlar dahil':
        return localizations.includingDuplicates;
      case 'Benzersiz':
        return localizations.uniqueCorrections;
      case 'düzeltme bulundu':
        return localizations.correctionsFound;
      case 'satırda':
        return localizations.inLine;
      default:
        return key;
    }
  }

  /// Belgedeki tüm satırlar için düzeltme önerileri oluşturur
  List<Correction> generateCorrections(Document document) {
    final List<Correction> corrections = [];
    print(
        "${_getLocalizedString('Belge işleniyor')}: ${document.name}, ${document.lines.length} ${_getLocalizedString('satır')}");

    // Her satırı ayrı ayrı işleyerek tüm düzeltmeleri topluyoruz
    for (var line in document.lines) {
      try {
        final lineCorrections =
            generateCorrectionsForLine(document, line.lineNumber);
        if (lineCorrections.isNotEmpty) {
          print(
              "${line.lineNumber}. ${_getLocalizedString('satırda')} ${lineCorrections.length} ${_getLocalizedString('düzeltme bulundu')}");
        }
        corrections.addAll(lineCorrections);
      } catch (e) {
        print(
            '${_getLocalizedString('Satır işlenirken hata')}: Line ${line.lineNumber}, $e');
        // Hatayı yakalıyoruz ama işlemi durdurmuyoruz
      }
    }

    // Toplam düzeltme sayısı
    print(
        "${_getLocalizedString('Toplam')} ${corrections.length} ${_getLocalizedString('düzeltme bulundu')} (${_getLocalizedString('tekrarlar dahil')})");

    // Benzersiz düzeltmeleri filtreleyip dönüyoruz
    final uniqueCorrections = _deduplicateCorrections(corrections);
    print(
        "${_getLocalizedString('Benzersiz')} ${uniqueCorrections.length} ${_getLocalizedString('düzeltme bulundu')}");

    return uniqueCorrections;
  }

  /// Belgedeki belirli bir satır için düzeltme önerileri oluşturur
  List<Correction> generateCorrectionsForLine(
    Document document,
    int lineNumber,
  ) {
    final line = document.lines.firstWhere(
      (line) => line.lineNumber == lineNumber,
      orElse: () => throw Exception(
          '${_getLocalizedString('Satır bulunamadı')}: $lineNumber'),
    );

    print("$lineNumber. ${_getLocalizedString('satır işleniyor')}:");
    print("  Çince: ${line.chineseText}");
    print("  İngilizce: ${line.englishText}");

    // TermMatcher servisini kullanarak eşleşmeleri buluyoruz
    final matches = _termMatcher.findTermMatches(line);
    print(
        "  ${matches.length} ${_getLocalizedString('terim eşleşmesi bulundu')}");

    // Eşleşmeler yoksa boş liste dönüyoruz
    if (matches.isEmpty) {
      return [];
    }

    // Bulunan eşleşmeleri Correction nesnelerine dönüştürüyoruz
    final corrections = matches.map(
      (match) {
        // Satır numarasını doğrulayalım
        if (match.lineNumber != lineNumber) {
          print(
              "  ${_getLocalizedString('UYARI')}: ${_getLocalizedString('Eşleşme satır numarası')} (${match.lineNumber}) ve istenen satır numarası ($lineNumber) uyuşmuyor. ${_getLocalizedString('Düzeltiliyor')}.");
        }

        return Correction(
          documentId: document.id,
          lineNumber: lineNumber, // Her zaman istenen satır numarasını kullan
          chineseTerm: match.chineseTerm,
          incorrectEnglishTerm: match.incorrectEnglishTerm,
          correctEnglishTerm: match.correctEnglishTerm,
        );
      },
    ).toList();

    // Eşleşmelerin detayını göster
    for (var correction in corrections) {
      print(
          "  ${_getLocalizedString('Düzeltme')} (${_getLocalizedString('satır')} $lineNumber): '${correction.chineseTerm}' -> '${correction.incorrectEnglishTerm}' ${_getLocalizedString('olması gereken')}: '${correction.correctEnglishTerm}'");

      // Terimler satırda var mı kontrol edelim
      final hasIncorrectTerm = line.englishText
          .toLowerCase()
          .contains(correction.incorrectEnglishTerm.toLowerCase());
      if (!hasIncorrectTerm) {
        print(
            "  ${_getLocalizedString('UYARI')}: ${_getLocalizedString('Hatalı terim')} '${correction.incorrectEnglishTerm}' ${_getLocalizedString('satır')} $lineNumber ${_getLocalizedString('metninde bulunamadı')}!");
      }
    }

    return corrections;
  }

  /// Yinelenen düzeltmeleri kaldırır
  List<Correction> _deduplicateCorrections(List<Correction> corrections) {
    // Aynı terim çiftleri ve satır için yinelenen düzeltmeleri filtreliyoruz
    final uniqueKeys = <String>{};
    final uniqueCorrections = <Correction>[];

    for (var correction in corrections) {
      final key =
          '${correction.lineNumber}:${correction.chineseTerm}:${correction.incorrectEnglishTerm}';
      if (!uniqueKeys.contains(key)) {
        uniqueKeys.add(key);
        uniqueCorrections.add(correction);
      }
    }

    return uniqueCorrections;
  }

  /// Belgedeki düzeltmeleri uygular
  void applyCorrections(
    Document document,
    List<Correction> corrections,
    DocumentRepository repository,
  ) {
    // Uygulanmamış düzeltme sayısını kontrol et
    final unappliedCorrections = corrections.where((c) => !c.isApplied).length;

    if (unappliedCorrections > 0) {
      // Tüm düzeltmeleri tek seferde uygula
      repository.applyAllCorrections();
      print(
          "$unappliedCorrections ${_getLocalizedString('düzeltme uygulandı')}");
    } else {
      print("${_getLocalizedString('Uygulanacak düzeltme bulunamadı')}");
    }
  }

  /// Tutarlılık puanı hesaplar (0-100 arası)
  int calculateConsistencyScore(
    Document document,
    List<Correction> corrections,
  ) {
    if (document.lines.isEmpty) return 100;

    // Toplam terim sayısı
    int totalTerms = 0;
    int incorrectTerms = corrections.length;

    // Her satırdaki Çince terimleri sayar
    for (var line in document.lines) {
      final matches = _termMatcher.findTermMatches(line);
      // Yalnızca doğru eşleşmelerin sayısını toplam terim sayısına ekle
      final correctMatches = matches
          .where((m) => _isCorrectMatch(line.englishText, m.correctEnglishTerm))
          .length;
      totalTerms += correctMatches;
    }

    // Düzeltme gerektirmeyen terimleri ekle
    totalTerms += incorrectTerms;

    // Belge boşsa veya terim yoksa tam puan
    if (totalTerms == 0) return 100;

    // Tutarlılık yüzdesi
    final score = ((totalTerms - incorrectTerms) / totalTerms * 100).round();
    print(
        "${_getLocalizedString('Tutarlılık puanı')}: $score (${_getLocalizedString('doğru')}: ${totalTerms - incorrectTerms}, ${_getLocalizedString('toplam')}: $totalTerms)");
    return score;
  }

  /// Doğru eşleşme olup olmadığını kontrol eder
  bool _isCorrectMatch(String text, String term) {
    return text.toLowerCase().contains(term.toLowerCase());
  }
}
