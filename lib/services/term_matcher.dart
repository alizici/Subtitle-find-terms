// lib/services/term_matcher.dart
import '../models/document.dart';
import '../repositories/term_repository.dart';
import 'dart:math' as math;

class TermMatcher {
  final TermRepository _termRepository;
  // Dinamik varyasyon önbelleği - bir kez hesaplanıp çokça kullanılır
  final Map<String, List<String>> _dynamicVariations = {};

  TermMatcher(this._termRepository);

  /// Belgedeki bir satırda bulunan terimleri eşleştirir
  List<TermMatch> findTermMatches(DocumentLine line) {
    final List<TermMatch> matches = [];

    // Debug için bilgi yazdır
    print("Çince metin (Satır ${line.lineNumber}): ${line.chineseText}");
    print("İngilizce metin (Satır ${line.lineNumber}): ${line.englishText}");
    print("Terim sayısı: ${_termRepository.terms.length}");

    // Tüm mevcut terimleri kontrol et
    for (var term in _termRepository.terms) {
      print(
          "Terim kontrol ediliyor: ${term.chineseTerm} -> ${term.englishTerm} (Satır ${line.lineNumber})");

      // Çince metinde terimi ara
      if (line.chineseText.contains(term.chineseTerm)) {
        print(
            "Çince terim bulundu (Satır ${line.lineNumber}): ${term.chineseTerm}");

        // İngilizce metinde doğru terimi ara
        if (!_containsIgnoreCase(line.englishText, term.englishTerm)) {
          print(
              "İngilizce terim bulunamadı (Satır ${line.lineNumber}): ${term.englishTerm}");

          // Yanlış terim kullanılmış olabilir, direkt arama (home_page.dart benzeri)
          final List<String> possibleIncorrectTerms = [];

          // 1. Ön tanımlı ve dinamik olarak oluşturulmuş yaygın yanlış çeviriler
          final variations = _getTermVariations(term.englishTerm);

          // Her varyasyonu kontrol et
          for (var variation in variations) {
            if (_containsWholeWord(line.englishText, variation)) {
              print(
                  "Muhtemel yanlış varyasyon bulundu (Satır ${line.lineNumber}): $variation");
              possibleIncorrectTerms.add(variation);
            }
          }

          // 2. Eğer bilinen yanlış varyasyon bulunamadıysa, mevcut kelime grubu algoritması
          if (possibleIncorrectTerms.isEmpty) {
            final words = line.englishText
                .split(RegExp(r'[\s\p{P}]'))
                .where((w) => w.isNotEmpty)
                .toList();

            // Önce doğru terimin parçalarını al
            final targetTermParts = term.englishTerm
                .split(RegExp(r'[\s\p{P}]'))
                .where((w) => w.isNotEmpty)
                .toList();

            // Doğru terimin parçalarına benzer kelimeler ara
            for (int i = 0; i < words.length; i++) {
              // Tek kelimelik terimleri kontrol et
              if (targetTermParts.length == 1 &&
                  _isSimilar(words[i], targetTermParts[0])) {
                possibleIncorrectTerms.add(words[i]);
                continue;
              }

              // Çok kelimelik terimleri kontrol et
              if (i + targetTermParts.length <= words.length) {
                bool allPartsSimilar = true;
                for (int j = 0; j < targetTermParts.length; j++) {
                  if (!_isSimilar(words[i + j], targetTermParts[j])) {
                    allPartsSimilar = false;
                    break;
                  }
                }

                if (allPartsSimilar) {
                  final candidate =
                      words.sublist(i, i + targetTermParts.length).join(' ');
                  if (!possibleIncorrectTerms.contains(candidate)) {
                    possibleIncorrectTerms.add(candidate);
                  }
                }
              }
            }

            // 3. Son çare olarak kelime gruplarını tara
            if (possibleIncorrectTerms.isEmpty) {
              final termWords = term.englishTerm.split(' ');

              // Tek kelimelik terimler için tam metin arama
              if (termWords.length == 1) {
                final regex = RegExp(r'\b\w+\b');
                final matches = regex.allMatches(line.englishText);
                for (final match in matches) {
                  final candidate = match.group(0)!;
                  if (_isSimilarTerms(candidate, term.englishTerm) &&
                      !possibleIncorrectTerms.contains(candidate)) {
                    possibleIncorrectTerms.add(candidate);
                  }
                }
              } else {
                // Çok kelimeli terimler için n-gram yaklaşımı
                for (int n = termWords.length - 1;
                    n <= termWords.length + 1;
                    n++) {
                  final wordsInText = line.englishText.split(RegExp(r'\s+'));
                  if (wordsInText.length < n) continue;

                  for (int i = 0; i <= wordsInText.length - n; i++) {
                    final candidate = wordsInText.sublist(i, i + n).join(' ');
                    if (_isSimilarTerms(candidate, term.englishTerm) &&
                        !possibleIncorrectTerms.contains(candidate)) {
                      possibleIncorrectTerms.add(candidate);
                    }
                  }
                }
              }
            }
          }

          print(
              "Bulunan olası yanlış terimler (Satır ${line.lineNumber}): $possibleIncorrectTerms");

          // Bulunan yanlış terimleri eşleştirmelere ekle
          for (var incorrectTerm in possibleIncorrectTerms) {
            matches.add(TermMatch(
              chineseTerm: term.chineseTerm,
              correctEnglishTerm: term.englishTerm,
              incorrectEnglishTerm: incorrectTerm,
              lineNumber: line.lineNumber,
            ));

            print(
                "Eşleştirme eklendi (Satır ${line.lineNumber}): '${term.chineseTerm}' -> '$incorrectTerm' olması gereken: '${term.englishTerm}'");
          }

          // Eğer hiçbir yanlış terim bulunamadıysa ama Çince terim varsa,
          // en yakın kelimeyi/ifadeyi bulmaya çalış - son çare
          if (possibleIncorrectTerms.isEmpty) {
            print(
                "Yanlış terim bulunamadı (Satır ${line.lineNumber}), tam metin kontrol ediliyor");

            // Çince terimi içeren satırlarda daha yüksek olasılıkla uyarı göster
            final englishTerms =
                _findEnglishTermsInLine(line.englishText, term.englishTerm);
            if (englishTerms.isNotEmpty) {
              // İngilizce metindeki en uzun olası terimi seç
              final longestTerm =
                  englishTerms.reduce((a, b) => a.length > b.length ? a : b);
              print(
                  "Olası terim bulundu (Satır ${line.lineNumber}): $longestTerm");
              matches.add(TermMatch(
                chineseTerm: term.chineseTerm,
                correctEnglishTerm: term.englishTerm,
                incorrectEnglishTerm: longestTerm,
                lineNumber: line.lineNumber,
              ));
            } else {
              // Hiçbir benzer terim bulunamadıysa tüm satırı işaretle
              final trimmedEnglish = line.englishText.length > 50
                  ? "${line.englishText.substring(0, 50)}..."
                  : line.englishText;

              matches.add(TermMatch(
                chineseTerm: term.chineseTerm,
                correctEnglishTerm: term.englishTerm,
                incorrectEnglishTerm: trimmedEnglish,
                lineNumber: line.lineNumber,
              ));
            }
          }
        } else {
          print(
              "İngilizce terim zaten doğru (Satır ${line.lineNumber}): ${term.englishTerm}");
        }
      }
    }

    return matches;
  }

  /// Tam kelime eşleşmesi kontrolü
  bool _containsWholeWord(String text, String term) {
    final pattern = RegExp(r'\b' + term.replaceAll(r'$', r'\$') + r'\b',
        caseSensitive: false);
    return pattern.hasMatch(text);
  }

  /// Terimin olası varyasyonlarını oluştur ve önbellekle
  List<String> _getTermVariations(String term) {
    // Önbellekte varsa kullan
    if (_dynamicVariations.containsKey(term)) {
      return _dynamicVariations[term]!;
    }

    // Dinamik varyasyonlar oluştur
    List<String> variations = _generateDynamicVariations(term);

    // Benzersiz varyasyonları filtrele ve önbellekle
    variations = variations.toSet().toList();
    _dynamicVariations[term] = variations;

    return variations;
  }

  /// Terimin dinamik varyasyonlarını oluştur
  List<String> _generateDynamicVariations(String term) {
    final variations = <String>[];
    // Burada terimin dinamik varyasyonları oluşturulabilir
    // ancak sabit varyasyonlar ve transliterasyon kontrolleri kaldırıldı
    return variations;
  }

  /// İngilizce metinde olası terimleri bulur
  List<String> _findEnglishTermsInLine(String text, String correctTerm) {
    final result = <String>[];
    final words = text.split(RegExp(r'\s+'));

    // Doğru terimin kelime sayısından bir az/fazla olabilecek kelime gruplarını dene
    final targetWordCount = correctTerm.split(' ').length;
    final minWordCount = math.max(1, targetWordCount - 1);
    final maxWordCount = targetWordCount + 1;

    for (int count = minWordCount; count <= maxWordCount; count++) {
      for (int i = 0; i <= words.length - count; i++) {
        final candidateTerm = words.sublist(i, i + count).join(' ');
        if (_isSimilarTerms(candidateTerm, correctTerm)) {
          result.add(candidateTerm);
        }
      }
    }

    return result;
  }

  /// Büyük/küçük harf gözetmeksizin bir metinde bir terimi arar
  bool _containsIgnoreCase(String text, String term) {
    return text.toLowerCase().contains(term.toLowerCase());
  }

  /// İki terimin benzer olup olmadığını kontrol eder
  bool _isSimilarTerms(String term1, String term2) {
    // Uzunluk farkı çok büyükse benzer değil
    if ((term1.length - term2.length).abs() > term2.length / 2) {
      return false;
    }

    // Küçük harfe çevir
    final t1 = term1.toLowerCase();
    final t2 = term2.toLowerCase();

    // Tam eşleşme
    if (t1 == t2) return true;

    // Biri diğerinin alt dizisi mi?
    if (t1.contains(t2) || t2.contains(t1)) return true;

    // Levenshtein mesafesini uzunluğa göre oranla
    final maxLength = math.max(t1.length, t2.length);
    final distance = _levenshteinDistance(t1, t2);

    // Uzunluğa göre uyarlanmış bir benzerlik eşiği
    // Daha esnek bir eşik belirleyelim
    return distance <= (maxLength * 0.4).round();
  }

  /// İki kelimenin benzer olup olmadığını kontrol eder
  bool _isSimilar(String word1, String word2) {
    final w1 = word1.toLowerCase();
    final w2 = word2.toLowerCase();

    // Tam eşleşme veya prefix kontrolü
    if (w1 == w2 || w1.startsWith(w2) || w2.startsWith(w1)) {
      return true;
    }

    // Levenshtein mesafesi hesaplama
    int distance = _levenshteinDistance(w1, w2);
    int maxLength = math.max(w1.length, w2.length);

    // Daha esnek bir benzerlik kriteri - uzunluğa göre uyarlanmış
    return distance <= math.min(3, (maxLength * 0.4).ceil());
  }

  /// İki string arasındaki Levenshtein mesafesini hesaplar
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }
}

class TermMatch {
  final String chineseTerm;
  final String correctEnglishTerm;
  final String incorrectEnglishTerm;
  final int lineNumber;

  TermMatch({
    required this.chineseTerm,
    required this.correctEnglishTerm,
    required this.incorrectEnglishTerm,
    required this.lineNumber,
  });
}
