import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import 'package:chinese_english_term_corrector/models/document.dart';
import 'package:chinese_english_term_corrector/models/project.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ReportScreenForProject extends StatelessWidget {
  final Project project;

  const ReportScreenForProject({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 16),
          _buildConsistencyScoreCard(context),
          const SizedBox(height: 16),
          _buildTopIncorrectTermsCard(context),
          const SizedBox(height: 16),
          _buildCorrectionsListCard(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.summary,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  localizations.totalLines,
                  '${project.documents.length}',
                  Icons.description,
                ),
                _buildSummaryItem(
                  localizations.totalCorrections,
                  '${project.corrections.length}',
                  Icons.auto_fix_high,
                ),
                _buildSummaryItem(
                  localizations.termLabel,
                  '${_getTermCount()}',
                  Icons.library_books,
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
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildConsistencyScoreCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.consistencyScore,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  height: 100,
                  width: 100,
                  child: Center(
                    child: Text(
                      "70%",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.mediumConsistency,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      localizations.clickButtonForCorrections,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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

  Widget _buildTopIncorrectTermsCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.mostFrequentlyMistranslatedTerms,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Örnek veri gösterimi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.corrections.isEmpty
                  ? 1
                  : min(5, project.corrections.length),
              itemBuilder: (context, index) {
                if (project.corrections.isEmpty) {
                  return ListTile(
                    title: Text(localizations.noMistranslatedTermsFound),
                  );
                }

                final correction = project.corrections[index];
                return ListTile(
                  title: Text(
                      '${correction.chineseTerm} - ${correction.incorrectEnglishTerm}'),
                  trailing: Text(
                    localizations.timesOccurred(1),
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

  Widget _buildCorrectionsListCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                  localizations.correctionDetails,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  localizations.totalCorrections2(project.corrections.length),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            project.corrections.isEmpty
                ? Center(child: Text(localizations.noCorrectionSuggestions))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: min(10, project.corrections.length),
                    itemBuilder: (context, index) {
                      final correction = project.corrections[index];
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
                        subtitle: Text(
                            '${localizations.document}: ${_getDocumentName(correction.documentId)}'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  int _getTermCount() {
    // Proje için terim sayısını al
    return 0; // Şimdilik sabit değer, TermRepository entegrasyonu sonra eklenecek
  }

  String _getDocumentName(String documentId) {
    // Düzeltmenin hangi belgeye ait olduğunu bul
    final document = project.documents.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => Document(name: 'Unknown Document', lines: []),
    );

    return document.name;
  }
}
