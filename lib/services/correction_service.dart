// lib/services/correction_service.dart
import '../models/document.dart';
import '../models/correction.dart';
import '../repositories/document_repository.dart';
import 'term_matcher.dart';

class CorrectionService {
  final TermMatcher _termMatcher;

  CorrectionService(this._termMatcher);

  /// Belgedeki tüm satırlar için düzeltme önerileri oluşturur
  List<Correction> generateCorrections(Document document) {
    final List<Correction> corrections = [];
    print("Belge işleniyor: ${document.name}, ${document.lines.length} satır");

    // Her satırı ayrı ayrı işleyerek tüm düzeltmeleri topluyoruz
    for (var line in document.lines) {
      try {
        final lineCorrections =
            generateCorrectionsForLine(document, line.lineNumber);
        if (lineCorrections.isNotEmpty) {
          print(
              "${line.lineNumber}. satırda ${lineCorrections.length} düzeltme bulundu");
        }
        corrections.addAll(lineCorrections);
      } catch (e) {
        print('Satır işlenirken hata: Line ${line.lineNumber}, Hata: $e');
        // Hatayı yakalıyoruz ama işlemi durdurmuyoruz
      }
    }

    // Toplam düzeltme sayısı
    print("Toplam ${corrections.length} düzeltme bulundu (tekrarlar dahil)");

    // Benzersiz düzeltmeleri filtreleyip dönüyoruz
    final uniqueCorrections = _deduplicateCorrections(corrections);
    print("Benzersiz ${uniqueCorrections.length} düzeltme bulundu");

    return uniqueCorrections;
  }

  /// Belgedeki belirli bir satır için düzeltme önerileri oluşturur
  List<Correction> generateCorrectionsForLine(
    Document document,
    int lineNumber,
  ) {
    final line = document.lines.firstWhere(
      (line) => line.lineNumber == lineNumber,
      orElse: () => throw Exception('Satır bulunamadı: $lineNumber'),
    );

    print("$lineNumber. satır işleniyor:");
    print("  Çince: ${line.chineseText}");
    print("  İngilizce: ${line.englishText}");

    // TermMatcher servisini kullanarak eşleşmeleri buluyoruz
    final matches = _termMatcher.findTermMatches(line);
    print("  ${matches.length} terim eşleşmesi bulundu");

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
              "  UYARI: Eşleşme satır numarası (${match.lineNumber}) ve istenen satır numarası ($lineNumber) uyuşmuyor. Düzeltiliyor.");
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
          "  Düzeltme (Satır $lineNumber): '${correction.chineseTerm}' -> '${correction.incorrectEnglishTerm}' olması gereken: '${correction.correctEnglishTerm}'");

      // Terimler satırda var mı kontrol edelim
      final hasIncorrectTerm = line.englishText
          .toLowerCase()
          .contains(correction.incorrectEnglishTerm.toLowerCase());
      if (!hasIncorrectTerm) {
        print(
            "  UYARI: Hatalı terim '${correction.incorrectEnglishTerm}' satır $lineNumber metninde bulunamadı!");
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
      print("$unappliedCorrections düzeltme uygulandı");
    } else {
      print("Uygulanacak düzeltme bulunamadı");
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
        "Tutarlılık puanı: $score (doğru: ${totalTerms - incorrectTerms}, toplam: $totalTerms)");
    return score;
  }

  /// Doğru eşleşme olup olmadığını kontrol eder
  bool _isCorrectMatch(String text, String term) {
    return text.toLowerCase().contains(term.toLowerCase());
  }
}
