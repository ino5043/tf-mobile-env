import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';

/// 習熟度ごとの色。どの画面（デッキ詳細・グラフ・進捗）でも同じ色にする。
///
/// 色の意味をいつも同じにすると、思い出しやすくなる（色分けの一貫性）。
/// 色だけで伝えず、必ず文字と組で使う（UI/UX 標準 4-3）。
extension MasteryColors on AppColors {
  Color forMastery(MasteryLevel level) => switch (level) {
        MasteryLevel.newCard => masteryNew,
        MasteryLevel.learning => masteryLearning,
        MasteryLevel.review => masteryReview,
        MasteryLevel.mastered => masteryMastered,
      };
}
