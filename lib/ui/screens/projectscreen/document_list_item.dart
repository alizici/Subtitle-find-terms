import 'package:chinese_english_term_corrector/models/document.dart';
import 'package:flutter/material.dart';

class DocumentListItem extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DocumentListItem({
    Key? key,
    required this.document,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasBeenProcessed = document.lastProcessedAt != null;
    final lineCount = document.lines.length;
    final correctionCount =
        document.lines.where((l) => l.hasCorrections).length;

    return ListTile(
      leading: Icon(
        hasBeenProcessed ? Icons.assignment_turned_in : Icons.assignment,
        color: hasBeenProcessed ? Colors.green : Colors.orange,
        size: 36,
      ),
      title: Text(
        document.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
