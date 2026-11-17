import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';

/// カードの面の見出し（「問題」「解答」など）を示す丸い札。
///
/// すべてのカードの種類で同じ見た目にする（UI/UX 標準 3-9）。
/// 薄いミントの面に濃い字で 4.5:1 以上（4-1）。
class CardSideLabel extends StatelessWidget {
  final String text;

  const CardSideLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
