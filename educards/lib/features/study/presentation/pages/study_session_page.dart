import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/core/widgets/loading_indicator.dart';
import '../bloc/study_session_bloc.dart';
import '../bloc/study_session_event.dart';
import '../bloc/study_session_state.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/rating_buttons.dart';

class StudySessionPage extends StatelessWidget {
  const StudySessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
          tooltip: 'End study session',
        ),
      ),
      body: BlocBuilder<StudySessionBloc, StudySessionState>(
        builder: (context, state) => switch (state) {
          StudySessionInitial() => const LoadingIndicator(),
          StudySessionLoading() =>
            const LoadingIndicator(message: 'Loading cards...'),
          StudySessionEmpty() => _buildEmptyState(context),
          StudySessionError(:final message) => _buildError(context, message),
          CardPresented() => _buildStudyCard(context, state),
          StudySessionComplete() => _buildComplete(context, state),
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'No cards due for review right now.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Decks'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildStudyCard(BuildContext context, CardPresented state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress indicator
            Semantics(
              label: 'Card ${state.currentIndex + 1} of ${state.totalCards}',
              child: LinearProgressIndicator(
                value: (state.currentIndex + 1) / state.totalCards,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.currentIndex + 1} / ${state.totalCards}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 16),
            // Flashcard
            Expanded(
              child: FlashcardWidget(
                card: state.card,
                isFlipped: state.isFlipped,
                onFlip: () =>
                    context.read<StudySessionBloc>().add(const FlipCard()),
              ),
            ),
            const SizedBox(height: 16),
            // Rating buttons (visible only when flipped)
            if (state.isFlipped)
              RatingButtons(
                onRate: (rating) =>
                    context.read<StudySessionBloc>().add(RateCard(rating)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete(BuildContext context, StudySessionComplete state) {
    final accuracy = state.cardsReviewed > 0
        ? (state.correctCount / state.cardsReviewed * 100).round()
        : 0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, size: 64),
          const SizedBox(height: 16),
          Text(
            'Session Complete!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Cards reviewed: ${state.cardsReviewed}'),
          Text('Accuracy: $accuracy%'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
