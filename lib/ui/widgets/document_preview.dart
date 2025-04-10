// lib/ui/widgets/document_preview.dart
import 'package:flutter/material.dart';
import '../../models/document.dart';
import '../../models/correction.dart';

class DocumentPreview extends StatelessWidget {
  final Document document;
  final List<Correction> corrections;
  final bool showSideBySide;
  final Function(int) onLineSelected;

  const DocumentPreview({
    Key? key,
    required this.document,
    required this.corrections,
    required this.showSideBySide,
    required this.onLineSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showSideBySide
        ? _buildSideBySideView(context)
        : _buildStackedView(context);
  }

  Widget _buildSideBySideView(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildColumnView(
            context,
            '源文本 (Kaynak Metin)',
            (line) => line.chineseText,
            true,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildColumnView(
            context,
            'İngilizce Çeviri',
            (line) => line.englishText,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildStackedView(BuildContext context) {
    return ListView.builder(
      itemCount: document.lines.length,
      itemBuilder: (context, index) {
        final line = document.lines[index];
        final lineCorrections =
            corrections.where((c) => c.lineNumber == line.lineNumber).toList();
        final hasActiveCorrections = lineCorrections.any((c) => !c.isApplied);
        final hasAppliedCorrections = lineCorrections.any((c) => c.isApplied);

        return InkWell(
          onTap: () => onLineSelected(line.lineNumber),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: hasActiveCorrections
                  ? Colors.amber.withOpacity(0.2)
                  : hasAppliedCorrections
                      ? Colors.green.withOpacity(0.1)
                      : null,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hasActiveCorrections
                            ? Colors.amber
                            : hasAppliedCorrections
                                ? Colors.green
                                : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${line.lineNumber}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        line.chineseText,
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (hasActiveCorrections)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${lineCorrections.where((c) => !c.isApplied).length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (hasAppliedCorrections && !hasActiveCorrections)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Düzeltildi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 52, top: 6),
                  child: _buildEnglishTextWithHighlights(
                      line.englishText, lineCorrections, context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnglishTextWithHighlights(
      String text, List<Correction> lineCorrections, BuildContext context) {
    // Metin içerisinde düzeltme yoksa normal text widget'ı döndür
    if (lineCorrections.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 15, color: Colors.grey),
      );
    }

    // Düzeltme varsa, RichText ile özelleştirilmiş metin göster
    final spans = <TextSpan>[];
    String remainingText = text;

    // Aktif ve uygulanmış düzeltmeleri ayrı gruplandır
    final activeCorrections =
        lineCorrections.where((c) => !c.isApplied).toList();
    final appliedCorrections =
        lineCorrections.where((c) => c.isApplied).toList();

    // Önce aktif düzeltmeleri işle
    for (var correction in activeCorrections) {
      final index = remainingText
          .toLowerCase()
          .indexOf(correction.incorrectEnglishTerm.toLowerCase());
      if (index >= 0) {
        // Düzeltmeden önceki metni ekle
        spans.add(TextSpan(
          text: remainingText.substring(0, index),
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ));

        // Düzeltme gereken metni vurgulu şekilde ekle
        spans.add(TextSpan(
          text: remainingText.substring(
              index, index + correction.incorrectEnglishTerm.length),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.red,
            backgroundColor: Color(0xFFFFEEEE),
            decoration: TextDecoration.lineThrough,
            fontWeight: FontWeight.bold,
          ),
        ));

        // Doğru terimi tooltip olarak göster
        spans.add(TextSpan(
          text: ' → ${correction.correctEnglishTerm}',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ));

        // Kalan metni güncelle
        remainingText = remainingText
            .substring(index + correction.incorrectEnglishTerm.length);
      }
    }

    // Uygulanmış düzeltmeleri işle
    for (var correction in appliedCorrections) {
      final index = remainingText
          .toLowerCase()
          .indexOf(correction.correctEnglishTerm.toLowerCase());
      if (index >= 0) {
        // Düzeltmeden önceki metni ekle
        spans.add(TextSpan(
          text: remainingText.substring(0, index),
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ));

        // Düzeltilmiş metni vurgulu şekilde ekle
        spans.add(TextSpan(
          text: remainingText.substring(
              index, index + correction.correctEnglishTerm.length),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.green,
            backgroundColor: Color(0xFFEEFFEE),
            fontWeight: FontWeight.bold,
          ),
        ));

        // Kalan metni güncelle
        remainingText = remainingText
            .substring(index + correction.correctEnglishTerm.length);
      }
    }

    // Kalan metni ekle
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(
        text: remainingText,
        style: const TextStyle(fontSize: 15, color: Colors.grey),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildColumnView(
    BuildContext context,
    String title,
    String Function(DocumentLine) textSelector,
    bool isChinese,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isChinese ? Icons.translate : Icons.language,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: document.lines.length,
            itemBuilder: (context, index) {
              final line = document.lines[index];
              final lineCorrections = corrections
                  .where((c) => c.lineNumber == line.lineNumber)
                  .toList();
              final hasActiveCorrections =
                  lineCorrections.any((c) => !c.isApplied);
              final hasAppliedCorrections =
                  lineCorrections.any((c) => c.isApplied);

              return InkWell(
                onTap: () => onLineSelected(line.lineNumber),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: hasActiveCorrections
                        ? Colors.amber.withOpacity(0.2)
                        : hasAppliedCorrections
                            ? Colors.green.withOpacity(0.1)
                            : null,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasActiveCorrections
                              ? Colors.amber
                              : hasAppliedCorrections
                                  ? Colors.green
                                  : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${line.lineNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isChinese
                            ? Text(
                                textSelector(line),
                                style: TextStyle(
                                  fontFamily: 'NotoSansSC',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              )
                            : _buildEnglishTextWithHighlights(
                                textSelector(line), lineCorrections, context),
                      ),
                      if (!isChinese && hasActiveCorrections)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${lineCorrections.where((c) => !c.isApplied).length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
