// lib/services/export_service.dart
import '../models/correction.dart';
import '../models/document.dart';
import '../models/term_pair.dart';

class ExportService {
  /// Terim çiftlerini CSV formatında dışa aktarır
  Future<String> exportTermsToCSV(List<TermPair> terms) async {
    final StringBuffer buffer = StringBuffer();

    // Başlık satırı
    buffer.writeln('Çince Terim,İngilizce Terim,Kategori,Notlar');

    // Terim satırları
    for (var term in terms) {
      final category = term.category.toString().split('.').last;
      final notes = term.notes?.replaceAll(',', ' ') ?? '';

      buffer.writeln(
        '${term.chineseTerm},${term.englishTerm},$category,$notes',
      );
    }

    return buffer.toString();
  }

  /// Düzeltme raporunu CSV formatında dışa aktarır
  Future<String> exportCorrectionsToCSV(List<Correction> corrections) async {
    final StringBuffer buffer = StringBuffer();

    // Başlık satırı
    buffer.writeln(
      'Satır No,Çince Terim,Yanlış İngilizce Terim,Doğru İngilizce Terim,Uygulandı',
    );

    // Düzeltme satırları
    for (var correction in corrections) {
      buffer.writeln(
        '${correction.lineNumber},${correction.chineseTerm},'
        '${correction.incorrectEnglishTerm},${correction.correctEnglishTerm},'
        '${correction.isApplied ? "Evet" : "Hayır"}',
      );
    }

    return buffer.toString();
  }

  /// Tutarlılık raporunu HTML formatında dışa aktarır
  Future<String> exportConsistencyReportToHTML(
    Document document,
    List<Correction> corrections,
    Map<String, int> termStats,
    int consistencyScore,
  ) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Terim Tutarlılık Raporu</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          h1, h2 { color: #333; }
          table { border-collapse: collapse; width: 100%; margin: 20px 0; }
          th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
          th { background-color: #f2f2f2; }
          tr:nth-child(even) { background-color: #f9f9f9; }
          .score { font-size: 24px; font-weight: bold; color: ${consistencyScore >= 90 ? 'green' : consistencyScore >= 70 ? 'orange' : 'red'}; }
        </style>
      </head>
      <body>
        <h1>Terim Tutarlılık Raporu</h1>
        <p>Belge: ${document.name}</p>
        <p>Oluşturulma Tarihi: ${DateTime.now().toString()}</p>
        
        <h2>Tutarlılık Puanı</h2>
        <p class="score">${consistencyScore}%</p>
        
        <h2>Özet</h2>
        <ul>
          <li>Toplam satır sayısı: ${document.lines.length}</li>
          <li>Düzeltilen satır sayısı: ${document.lines.where((l) => l.hasCorrections).length}</li>
          <li>Toplam düzeltme sayısı: ${corrections.length}</li>
          <li>Uygulanan düzeltme sayısı: ${corrections.where((c) => c.isApplied).length}</li>
        </ul>
        
        <h2>En Sık Yanlış Çevrilen Terimler</h2>
        <table>
          <tr>
            <th>Terim</th>
            <th>Sıklık</th>
          </tr>
    ''');

    // Terim istatistiklerini sırala ve işle
    final sortedStats = termStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedStats.take(10)) {
      buffer.writeln('''
        <tr>
          <td>${entry.key}</td>
          <td>${entry.value}</td>
        </tr>
      ''');
    }

    buffer.writeln('''
        </table>
        
        <h2>Düzeltme Detayları</h2>
        <table>
          <tr>
            <th>Satır No</th>
            <th>Çince Terim</th>
            <th>Yanlış İngilizce Terim</th>
            <th>Doğru İngilizce Terim</th>
            <th>Durum</th>
          </tr>
    ''');

    for (var correction in corrections) {
      buffer.writeln('''
        <tr>
          <td>${correction.lineNumber}</td>
          <td>${correction.chineseTerm}</td>
          <td>${correction.incorrectEnglishTerm}</td>
          <td>${correction.correctEnglishTerm}</td>
          <td>${correction.isApplied ? "Uygulandı" : "Beklemede"}</td>
        </tr>
      ''');
    }

    buffer.writeln('''
        </table>
      </body>
      </html>
    ''');

    return buffer.toString();
  }
}
