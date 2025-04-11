// lib/ui/widgets/correction_item.dart
import 'package:flutter/material.dart';
import '../../models/correction.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';

class CorrectionItem extends StatelessWidget {
  final Correction correction;
  final VoidCallback onApply;

  const CorrectionItem({
    Key? key,
    required this.correction,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(builder: (context, constraints) {
      final isVerySmallWidth = constraints.maxWidth < 300;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: correction.isApplied
                ? Colors.green.shade300
                : Colors.orange.shade300,
            width: 1.0,
          ),
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                isVerySmallWidth
                    ? _buildCompactHeader(context)
                    : _buildWideHeader(context),
                const SizedBox(height: 8),
                _buildChineseTermContainer(context),
                const SizedBox(height: 8),
                constraints.maxWidth < 450
                    ? _buildVerticalTranslationSection(context)
                    : _buildHorizontalTranslationSection(context),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCompactHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: correction.isApplied ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${correction.lineNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                correction.chineseTerm,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!correction.isApplied)
              SizedBox(
                height: 28,
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.done, size: 14),
                  label: Text(
                    l10n.applyButton,
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    minimumSize: Size.zero,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            if (correction.isApplied)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  l10n.appliedStatus,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: correction.isApplied ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '${correction.lineNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.lineNumber(correction.lineNumber),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        if (!correction.isApplied)
          SizedBox(
            height: 24,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Icon(Icons.done, size: 16),
            ),
          ),
        if (correction.isApplied)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade300, width: 1),
            ),
            child: Icon(
              Icons.check,
              color: Colors.green.shade800,
              size: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildChineseTermContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.translate, size: 14, color: Colors.blue),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              correction.chineseTerm,
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTranslationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTranslationSection(
          context,
          l10n.incorrectLabel,
          correction.incorrectEnglishTerm,
          Icons.error_outline,
          Colors.red,
          isWrong: true,
        ),
        const SizedBox(height: 4),
        Center(
          child: Icon(
            Icons.arrow_downward,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        _buildTranslationSection(
          context,
          l10n.correctLabel,
          correction.correctEnglishTerm,
          Icons.check_circle_outline,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildHorizontalTranslationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTranslationSection(
            context,
            l10n.incorrectLabel,
            correction.incorrectEnglishTerm,
            Icons.error_outline,
            Colors.red,
            isWrong: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.arrow_forward,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: _buildTranslationSection(
            context,
            l10n.correctLabel,
            correction.correctEnglishTerm,
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color, {
    bool isWrong = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Icon(icon, color: color, size: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: isWrong
                  ? color
                  : (color == Colors.green ? Colors.green.shade800 : color),
              decoration: isWrong ? TextDecoration.lineThrough : null,
              fontWeight: isWrong ? FontWeight.normal : FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
