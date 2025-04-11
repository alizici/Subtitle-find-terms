// lib/services/export_service.dart
import 'package:flutter/material.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import '../models/correction.dart';
import '../models/document.dart';
import '../models/term_pair.dart';

class ExportService {
  /// Exports term pairs to CSV format
  Future<String> exportTermsToCSV(
      List<TermPair> terms, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final StringBuffer buffer = StringBuffer();

    // Header row
    buffer.writeln(
        '${l10n.chineseTerm},${l10n.englishTerm},${l10n.category},${l10n.notes}');

    // Term rows
    for (var term in terms) {
      final category = term.getCategoryName(context);
      final notes = term.notes?.replaceAll(',', ' ') ?? '';

      buffer.writeln(
        '${term.chineseTerm},${term.englishTerm},$category,$notes',
      );
    }

    return buffer.toString();
  }

  /// Exports correction report to CSV format
  Future<String> exportCorrectionsToCSV(
      List<Correction> corrections, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final StringBuffer buffer = StringBuffer();

    // Header row
    buffer.writeln(
      '${l10n.lineNumber1},${l10n.chineseTerm},${l10n.incorrectEnglishTerm},${l10n.correctEnglishTerm},${l10n.statusLabel}',
    );

    // Correction rows
    for (var correction in corrections) {
      buffer.writeln(
        '${correction.lineNumber},${correction.chineseTerm},'
        '${correction.incorrectEnglishTerm},${correction.correctEnglishTerm},'
        '${correction.isApplied ? l10n.appliedStatus : l10n.pendingStatus}',
      );
    }

    return buffer.toString();
  }

  /// Exports consistency report to HTML format
  Future<String> exportConsistencyReportToHTML(
    Document document,
    List<Correction> corrections,
    Map<String, int> termStats,
    int consistencyScore,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>${l10n.consistencyReportTitle}</title>
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
        <h1>${l10n.consistencyReportTitle}</h1>
        <p>${l10n.document}: ${document.name}</p>
        <p>${l10n.creationDate}: ${DateTime.now().toString()}</p>
        
        <h2>${l10n.consistencyScore}</h2>
        <p class="score">$consistencyScore%</p>
        
        <h2>${l10n.summary}</h2>
        <ul>
          <li>${l10n.totalLinesReport}: ${document.lines.length}</li>
          <li>${l10n.correctedLinesReport}: ${document.lines.where((l) => l.hasCorrections).length}</li>
          <li>${l10n.totalCorrectionsReport}: ${corrections.length}</li>
          <li>${l10n.appliedCorrectionsReport}: ${corrections.where((c) => c.isApplied).length}</li>
        </ul>
        
        <h2>${l10n.mostFrequentlyMistranslatedTerms}</h2>
        <table>
          <tr>
            <th>${l10n.termLabel}</th>
            <th>${l10n.frequencyLabel}</th>
          </tr>
    ''');

    // Sort and process term statistics
    final sortedStats = termStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedStats.take(10)) {
      buffer.writeln('''
        <tr>
          <td>${entry.key}</td>
          <td>${entry.value} ${entry.value == 1 ? l10n.correct : l10n.correctionsApplied}</td>
        </tr>
      ''');
    }

    buffer.writeln('''
        </table>
        
        <h2>${l10n.correctionDetails}</h2>
        <table>
          <tr>
            <th>${l10n.lineNumber1}</th>
            <th>${l10n.chineseTerm}</th>
            <th>${l10n.incorrectEnglishTerm}</th>
            <th>${l10n.correctEnglishTerm}</th>
            <th>${l10n.statusLabel}</th>
          </tr>
    ''');

    for (var correction in corrections) {
      buffer.writeln('''
        <tr>
          <td>${correction.lineNumber}</td>
          <td>${correction.chineseTerm}</td>
          <td>${correction.incorrectEnglishTerm}</td>
          <td>${correction.correctEnglishTerm}</td>
          <td>${correction.isApplied ? l10n.appliedStatus : l10n.pendingStatus}</td>
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
