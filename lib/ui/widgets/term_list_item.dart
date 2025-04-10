// lib/ui/widgets/term_list_item.dart
import 'package:flutter/material.dart';
import '../../models/term_pair.dart';

class TermListItem extends StatelessWidget {
  final TermPair term;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TermListItem({
    Key? key,
    required this.term,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(term.category),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.chineseTerm,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoSansSC',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    term.englishTerm,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (term.notes != null && term.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        term.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Düzenle',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Sil',
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(TermCategory category) {
    switch (category) {
      case TermCategory.person:
        return Colors.blue;
      case TermCategory.place:
        return Colors.green;
      case TermCategory.organization:
        return Colors.purple;
      case TermCategory.technical:
        return Colors.orange;
      case TermCategory.general:
        return Colors.grey;
      case TermCategory.other:
        return Colors.brown;
    }
  }
}
