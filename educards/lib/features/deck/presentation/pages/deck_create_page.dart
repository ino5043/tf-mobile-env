import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/deck_create_bloc.dart';
import '../bloc/deck_create_event.dart';
import '../bloc/deck_create_state.dart';
import '../widgets/card_input_form.dart';

class DeckCreatePage extends StatefulWidget {
  const DeckCreatePage({super.key});

  @override
  State<DeckCreatePage> createState() => _DeckCreatePageState();
}

class _DeckCreatePageState extends State<DeckCreatePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeckCreateBloc, DeckCreateState>(
      listener: (context, state) {
        if (state is DeckCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deck created successfully!')),
          );
          context.pop();
        } else if (state is DeckCreateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state is DeckCreateEditing && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        final editing = state is DeckCreateEditing ? state : null;
        final isGenerating = editing?.isGenerating ?? false;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Create Deck'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.edit), text: 'Manual'),
                  Tab(icon: Icon(Icons.file_upload), text: 'Import'),
                  Tab(icon: Icon(Icons.auto_awesome), text: 'AI Generate'),
                ],
              ),
              actions: [
                if (editing != null)
                  TextButton.icon(
                    onPressed: editing.canSubmit && !isGenerating
                        ? () =>
                            context.read<DeckCreateBloc>().add(const SubmitDeck())
                        : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Deck info (always visible)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Deck Title *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => context
                            .read<DeckCreateBloc>()
                            .add(UpdateTitle(v)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => context
                            .read<DeckCreateBloc>()
                            .add(UpdateDescription(v)),
                      ),
                    ],
                  ),
                ),
                if (editing != null && editing.cards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${editing.cards.length} card(s) added',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Tab content
                Expanded(
                  child: TabBarView(
                    children: [
                      _ManualTab(cards: editing?.cards ?? []),
                      const _ImportTab(),
                      _AIGenerateTab(isGenerating: isGenerating),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Tab 1: Manual card entry ---
class _ManualTab extends StatelessWidget {
  final List<CardEntry> cards;

  const _ManualTab({required this.cards});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CardInputForm(
            onAdd: (front, back) => context
                .read<DeckCreateBloc>()
                .add(AddCard(front: front, back: back)),
          ),
          const SizedBox(height: 16),
          if (cards.isNotEmpty) ...[
            Text(
              'Cards (${cards.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...cards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(card.front, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(card.back, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => context
                        .read<DeckCreateBloc>()
                        .add(RemoveCard(index)),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// --- Tab 2: Import from CSV/JSON ---
class _ImportTab extends StatelessWidget {
  const _ImportTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.file_upload_outlined, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Import from File',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Import cards from CSV or JSON files.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Supported formats:',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const Text('CSV: front,back (one card per row)'),
                  const Text('JSON: [{"front":"Q","back":"A"}, ...]'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                context.read<DeckCreateBloc>().add(const ImportFile()),
            icon: const Icon(Icons.folder_open),
            label: const Text('Choose File'),
          ),
        ],
      ),
    );
  }
}

// --- Tab 3: AI Generate ---
class _AIGenerateTab extends StatefulWidget {
  final bool isGenerating;

  const _AIGenerateTab({required this.isGenerating});

  @override
  State<_AIGenerateTab> createState() => _AIGenerateTabState();
}

class _AIGenerateTabState extends State<_AIGenerateTab> {
  final _topicController = TextEditingController();
  int _cardCount = 10;
  String _difficulty = 'medium';

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.auto_awesome, size: 48),
          const SizedBox(height: 16),
          Text(
            'Generate with Claude AI',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(
              labelText: 'Topic',
              hintText: 'e.g., Docker basics, Japanese JLPT N3',
              border: OutlineInputBorder(),
            ),
            enabled: !widget.isGenerating,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cards: $_cardCount',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Slider(
                      value: _cardCount.toDouble(),
                      min: 5,
                      max: 30,
                      divisions: 5,
                      label: '$_cardCount',
                      onChanged: widget.isGenerating
                          ? null
                          : (v) => setState(() => _cardCount = v.round()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'easy', label: Text('Easy')),
              ButtonSegment(value: 'medium', label: Text('Medium')),
              ButtonSegment(value: 'hard', label: Text('Hard')),
            ],
            selected: {_difficulty},
            onSelectionChanged: widget.isGenerating
                ? null
                : (v) => setState(() => _difficulty = v.first),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.isGenerating ||
                    _topicController.text.trim().isEmpty
                ? null
                : () => context.read<DeckCreateBloc>().add(GenerateWithAI(
                      topic: _topicController.text.trim(),
                      cardCount: _cardCount,
                      difficulty: _difficulty,
                    )),
            icon: widget.isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(widget.isGenerating ? 'Generating...' : 'Generate'),
          ),
          if (widget.isGenerating)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Claude AI is generating your flashcards...\nThis may take a few seconds.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
