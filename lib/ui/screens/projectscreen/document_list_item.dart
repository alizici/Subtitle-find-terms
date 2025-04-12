import 'package:chinese_english_term_corrector/models/document.dart';
import 'package:flutter/material.dart';

class DocumentListItem extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(bool) onCompletedToggle;
  final bool isLastAccessed;

  const DocumentListItem({
    Key? key,
    required this.document,
    required this.onTap,
    required this.onDelete,
    required this.onCompletedToggle,
    this.isLastAccessed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasBeenProcessed = document.lastProcessedAt != null;
    final lineCount = document.lines.length;
    final correctionCount =
        document.lines.where((l) => l.hasCorrections).length;

    return Container(
      decoration: isLastAccessed
          ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: document.isCompleted,
              onChanged: (value) {
                if (value != null) {
                  onCompletedToggle(value);
                }
              },
              activeColor: Colors.green,
            ),
            Icon(
              hasBeenProcessed ? Icons.assignment_turned_in : Icons.assignment,
              color: hasBeenProcessed ? Colors.green : Colors.orange,
              size: 36,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                document.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isLastAccessed)
              const Tooltip(
                message: 'Son erişilen altyazı',
                child: Icon(
                  Icons.access_time,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Satır sayısı: $lineCount | ${correctionCount > 0 ? '$correctionCount satırda düzeltme' : 'Henüz düzeltme yok'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              'Eklenme: ${_formatDate(document.importedAt)} ${hasBeenProcessed ? '| Son işlem: ${_formatDate(document.lastProcessedAt!)}' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (document.isCompleted)
              const Text(
                'Durum: Tamamlandı',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
