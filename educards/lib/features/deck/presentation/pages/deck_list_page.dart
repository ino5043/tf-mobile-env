import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/core/widgets/empty_state.dart';
import 'package:educards/core/widgets/error_display.dart';
import 'package:educards/core/widgets/loading_indicator.dart';
import 'package:educards/core/widgets/adaptive_layout.dart';
import '../bloc/deck_list_bloc.dart';
import '../bloc/deck_list_event.dart';
import '../bloc/deck_list_state.dart';
import '../widgets/deck_card.dart';

class DeckListPage extends StatelessWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduCards'),
      ),
      body: BlocBuilder<DeckListBloc, DeckListState>(
        builder: (context, state) => switch (state) {
          DeckListInitial() => const LoadingIndicator(),
          DeckListLoading() => const LoadingIndicator(message: 'Loading decks...'),
          DeckListError(:final message) => ErrorDisplay(
              message: message,
              onRetry: () =>
                  context.read<DeckListBloc>().add(const LoadDecks()),
            ),
          DeckListLoaded(:final decks) when decks.isEmpty => EmptyState(
              icon: Icons.style_outlined,
              title: 'No decks yet',
              subtitle: 'Create your first deck to start learning',
              action: FilledButton.icon(
                onPressed: () => context.push('/decks/create'),
                icon: const Icon(Icons.add),
                label: const Text('Create Deck'),
              ),
            ),
          DeckListLoaded(:final decks) => AdaptiveLayout(
              compact: (_) => _buildGrid(context, decks, 1),
              medium: (_) => _buildGrid(context, decks, 2),
              expanded: (_) => _buildGrid(context, decks, 3),
            ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/decks/create'),
        tooltip: 'Create new deck',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List decks, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return DeckCard(
          deck: deck,
          onTap: () async {
            await context.push('/decks/${deck.id}');
            if (context.mounted) {
              context.read<DeckListBloc>().add(const LoadDecks());
            }
          },
          onDelete: () =>
              context.read<DeckListBloc>().add(DeleteDeckRequested(deck.id)),
        );
      },
    );
  }

}
