// lib/ui/screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import '../../repositories/document_repository.dart';
import '../../services/term_matcher.dart';
import '../../services/correction_service.dart';
import '../../services/export_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DocumentRepository _documentRepo = DocumentRepository();
  final ExportService _exportService = ExportService();
  int? _consistencyScore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: l10n.exportReport,
            onPressed:
                _documentRepo.currentDocument != null ? _exportReport : null,
          ),
        ],
      ),
      body: _documentRepo.currentDocument == null
          ? Center(
              child: Text(
                l10n.pleaseUploadDocument,
              ),
            )
          : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    final l10n = AppLocalizations.of(context)!;

    if (_documentRepo.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documentRepo.error != null) {
      return Center(
        child: Text(
          l10n.errorWithMessage(_documentRepo.error!),
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final termStats = _documentRepo.getTermCorrectionStats();

    if (_consistencyScore == null) {
      final termMatcher = Provider.of<TermMatcher>(context, listen: false);
      final correctionService = CorrectionService(termMatcher);

      _consistencyScore ??= correctionService.calculateConsistencyScore(
        _documentRepo.currentDocument!,
        _documentRepo.corrections,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildConsistencyScoreCard(),
          const SizedBox(height: 16),
          _buildTopIncorrectTermsCard(termStats),
          const SizedBox(height: 16),
          _buildCorrectionsListCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.summary,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  l10n.totalLines,
                  _documentRepo.currentDocument!.lines.length.toString(),
                  Icons.format_list_numbered,
                ),
                _buildSummaryItem(
                  l10n.correctedLines,
                  _documentRepo.currentDocument!.lines
                      .where((l) => l.hasCorrections)
                      .length
                      .toString(),
                  Icons.edit,
                ),
                _buildSummaryItem(
                  l10n.totalCorrections,
                  _documentRepo.corrections.length.toString(),
                  Icons.auto_fix_high,
                ),
                _buildSummaryItem(
                  l10n.appliedCorrections,
                  _documentRepo.corrections
                      .where((c) => c.isApplied)
                      .length
                      .toString(),
                  Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildConsistencyScoreCard() {
    final l10n = AppLocalizations.of(context)!;

    Color scoreColor;

    if (_consistencyScore! >= 90) {
      scoreColor = Colors.green;
    } else if (_consistencyScore! >= 70) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.consistencyScore,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          startDegreeOffset: 270,
                          sections: [
                            PieChartSectionData(
                              color: scoreColor,
                              value: _consistencyScore!.toDouble(),
                              title: '',
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              color: Colors.grey.shade200,
                              value: (100 - _consistencyScore!).toDouble(),
                              title: '',
                              radius: 20,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$_consistencyScore%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_consistencyScore%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      _getScoreDescription(_consistencyScore!),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getScoreDescription(int score) {
    final l10n = AppLocalizations.of(context)!;

    if (score >= 90) {
      return l10n.excellentConsistency;
    } else if (score >= 80) {
      return l10n.goodConsistency;
    } else if (score >= 70) {
      return l10n.mediumConsistency;
    } else if (score >= 50) {
      return l10n.lowConsistency;
    } else {
      return l10n.veryLowConsistency;
    }
  }

  Widget _buildTopIncorrectTermsCard(Map<String, int> termStats) {
    final l10n = AppLocalizations.of(context)!;

    final sortedStats = termStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topStats = sortedStats.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mostFrequentlyMistranslatedTerms,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            topStats.isEmpty
                ? Center(child: Text(l10n.noMistranslatedTermsFound))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topStats.length,
                    itemBuilder: (context, index) {
                      final entry = topStats[index];
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Text(
                          l10n.timesOccurred(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectionsListCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.correctionDetails,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  l10n.totalCorrections2(_documentRepo.corrections.length),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _documentRepo.corrections.isEmpty
                ? Center(child: Text(l10n.noCorrectionSuggestions))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _documentRepo.corrections.length,
                    itemBuilder: (context, index) {
                      final correction = _documentRepo.corrections[index];
                      return ListTile(
                        leading: Icon(
                          correction.isApplied
                              ? Icons.check_circle
                              : Icons.pending,
                          color: correction.isApplied
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(
                          '${correction.chineseTerm}: ${correction.incorrectEnglishTerm} → ${correction.correctEnglishTerm}',
                        ),
                        subtitle: Text(l10n.line(correction.lineNumber)),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final termMatcher = Provider.of<TermMatcher>(context, listen: false);
      final correctionService = CorrectionService(termMatcher);

      _consistencyScore ??= correctionService.calculateConsistencyScore(
        _documentRepo.currentDocument!,
        _documentRepo.corrections,
      );

      final termStats = _documentRepo.getTermCorrectionStats();

      final htmlReport = await _exportService.exportConsistencyReportToHTML(
        _documentRepo.currentDocument!,
        _documentRepo.corrections,
        termStats,
        _consistencyScore!,
        context, // Added the missing context parameter
      );

      final result = await FilePicker.platform.saveFile(
        dialogTitle: l10n.saveReport,
        fileName: l10n.consistencyReportFileName,
        type: FileType.custom,
        allowedExtensions: ['html'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(htmlReport);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportSavedSuccessfully)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))));
    }
  }
}
