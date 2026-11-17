import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/core/widgets/error_display.dart';
import 'package:educards/core/widgets/loading_indicator.dart';
import 'package:educards/l10n/app_localizations.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../widgets/daily_trend_chart.dart';
import '../widgets/deck_progress_list.dart';
import '../widgets/mastery_pie_chart.dart';
import '../widgets/stats_card.dart';
import '../widgets/streak_counter.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.progressTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.progressTabOverview),
              Tab(text: l10n.progressTabTrend),
              Tab(text: l10n.progressTabByDeck),
            ],
          ),
        ),
        body: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) => switch (state) {
            ProgressInitial() => const LoadingIndicator(),
            ProgressLoading() =>
              LoadingIndicator(message: l10n.progressLoading),
            ProgressError(:final message) => ErrorDisplay(
                message: message,
                onRetry: () =>
                    context.read<ProgressBloc>().add(const LoadProgress()),
              ),
            ProgressLoaded(
              :final todayStats,
              :final streak,
              :final trend,
              :final deckProgressList
            ) =>
              TabBarView(
                children: [
                  // Tab 1: Overview
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreakCounter(streak: streak),
                          const SizedBox(height: 24),
                          Text(
                            l10n.progressTodayStudy,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  icon: Icons.style,
                                  label: l10n.progressCards,
                                  value: '${todayStats.cardsReviewed}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  icon: Icons.check_circle,
                                  label: l10n.progressCorrect,
                                  value: '${todayStats.correctCount}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatsCard(
                                  icon: Icons.percent,
                                  label: l10n.progressAccuracy,
                                  value: todayStats.cardsReviewed > 0
                                      ? '${(todayStats.accuracy * 100).round()}%'
                                      : '-',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.progressMasteryDistribution,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          MasteryPieChart(
                              deckProgressList: deckProgressList),
                        ],
                      ),
                    ),
                  ),
                  // Tab 2: Trend
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.progressLast7Days,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _LegendDot(
                                color: AppColors.of(context).chartCorrect,
                                label: l10n.progressCorrectLegend,
                              ),
                              const SizedBox(width: 16),
                              _LegendDot(
                                color: AppColors.of(context).chartIncorrect,
                                label: l10n.progressIncorrectLegend,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DailyTrendChart(trend: trend),
                          const SizedBox(height: 24),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _SummaryRow(
                                    label: l10n.progressTotalReviewed,
                                    value: '${trend.totalCardsReviewed}',
                                  ),
                                  _SummaryRow(
                                    label: l10n.progressTotalCorrect,
                                    value: '${trend.totalCorrect}',
                                  ),
                                  _SummaryRow(
                                    label: l10n.progressAverageAccuracy,
                                    value: trend.totalCardsReviewed > 0
                                        ? '${(trend.averageAccuracy * 100).round()}%'
                                        : '-',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tab 3: By Deck
                  DeckProgressList(deckProgressList: deckProgressList),
                ],
              ),
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
