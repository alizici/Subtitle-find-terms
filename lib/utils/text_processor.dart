// lib/utils/text_processor.dart
import 'dart:convert';

class TextProcessor {
  /// Metindeki dil kodlarını tespit eder
  static List<String> detectLanguages(String text) {
    final List<String> result = [];

    // Çince karakterleri tespit etme
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(text)) {
      result.add('zh');
    }

    // İngilizce karakterleri tespit etme
    if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      result.add('en');
    }

    return result;
  }

  /// İki metin arasındaki benzerlik oranını hesaplar (0.0 - 1.0)
  static double calculateSimilarity(String text1, String text2) {
    if (text1 == text2) return 1.0;
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    final String shorter = text1.length < text2.length ? text1 : text2;
    final String longer = text1.length < text2.length ? text2 : text1;

    // Levenshtein mesafesi hesaplama
    final int distance = _levenshteinDistance(shorter, longer);

    // Benzerlik oranı: 1 - (mesafe / uzun metnin uzunluğu)
    return 1.0 - (distance / longer.length);
  }

  /// Metindeki terimleri vurgular
  static String highlightTerms(
      String text, List<String> terms, String highlightMark) {
    String result = text;

    for (var term in terms) {
      // Büyük/küçük harf duyarsız eşleştirme için regex kullanımı
      final pattern = RegExp(term, caseSensitive: false);
      result = result.replaceAllMapped(pattern, (match) {
        return '$highlightMark${match.group(0)}$highlightMark';
      });
    }

    return result;
  }

  /// UTF-8 metin kodlaması düzeltme
  static String fixUTF8Encoding(String text) {
    try {
      // UTF-8 olarak kodla ve sonra decode et
      final List<int> encoded = utf8.encode(text);
      return utf8.decode(encoded);
    } catch (e) {
      // Hata durumunda orijinal metni döndür
      return text;
    }
  }

  /// Levenshtein mesafesi algoritması
  static int _levenshteinDistance(String s1, String s2) {
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
