import 'package:chinese_english_term_corrector/models/document.dart';
import 'package:chinese_english_term_corrector/models/project.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Proje için Raporlar Widget'ı
class ReportScreenForProject extends StatelessWidget {
  final Project project;

  const ReportScreenForProject({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Burada ReportScreen'deki yapıyı proje bazlı olarak adapte et
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildConsistencyScoreCard(),
          const SizedBox(height: 16),
          _buildTopIncorrectTermsCard(),
          const SizedBox(height: 16),
          _buildCorrectionsListCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    // ReportScreen'deki özet kartı uyarla
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Özet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Toplam Belge',
                  '${project.documents.length}',
                  Icons.description,
                ),
                _buildSummaryItem(
                  'Toplam Düzeltme',
                  '${project.corrections.length}',
                  Icons.auto_fix_high,
                ),
                _buildSummaryItem(
                  'Toplam Terim',
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

  Widget _buildConsistencyScoreCard() {
    // ReportScreen'deki tutarlılık puanı kartını uyarla
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutarlılık Puanı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
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
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orta düzeyde tutarlılık',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Daha fazla düzeltme için belgeleri işleyin',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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

  Widget _buildTopIncorrectTermsCard() {
    // ReportScreen'deki yanlış terimler kartını uyarla
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'En Sık Yanlış Çevrilen Terimler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return const ListTile(
                    title: Text('Henüz düzeltme yapılmadı'),
                  );
                }

                final correction = project.corrections[index];
                return ListTile(
                  title: Text(
                      '${correction.chineseTerm} - ${correction.incorrectEnglishTerm}'),
                  trailing: const Text(
                    '1 kez',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
    // ReportScreen'deki düzeltmeler listesi kartını uyarla
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Düzeltme Detayları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toplam: ${project.corrections.length} düzeltme',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            project.corrections.isEmpty
                ? const Center(child: Text('Henüz düzeltme önerisi yok'))
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
                            'Belge: ${_getDocumentName(correction.documentId)}'),
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
      orElse: () => Document(name: 'Bilinmeyen Belge', lines: []),
    );

    return document.name;
  }
}
