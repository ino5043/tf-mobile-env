import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/l10n/app_localizations.dart';
import '../../domain/entities/card_type.dart';
import '../bloc/deck_edit_bloc.dart';
import '../bloc/deck_edit_event.dart';
import '../bloc/deck_edit_state.dart';
import '../widgets/card_input_form.dart';

class DeckEditPage extends StatelessWidget {
  const DeckEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<DeckEditBloc, DeckEditState>(
      listener: (context, state) {
        if (state is DeckEditSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deckEditSaved)),
          );
          context.pop();
        } else if (state is DeckEditFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is DeckEditEditing && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) => switch (state) {
        DeckEditLoading() => Scaffold(
            appBar: AppBar(title: Text(l10n.deckEditTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
        DeckEditFailure(:final message) => Scaffold(
            appBar: AppBar(title: Text(l10n.deckEditTitle)),
            body: Center(child: Text(message)),
          ),
        DeckEditSuccess() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        DeckEditEditing() => _DeckEditForm(state: state),
      },
    );
  }
}

class _DeckEditForm extends StatefulWidget {
  final DeckEditEditing state;

  const _DeckEditForm({required this.state});

  @override
  State<_DeckEditForm> createState() => _DeckEditFormState();
}

class _DeckEditFormState extends State<_DeckEditForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _editingIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.title);
    _descriptionController =
        TextEditingController(text: widget.state.description);
  }

  @override
  void didUpdateWidget(covariant _DeckEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.deckId != widget.state.deckId) {
      _titleController.text = widget.state.title;
      _descriptionController.text = widget.state.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = widget.state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deckEditTitle),
        actions: [
          FilledButton(
            onPressed: state.canSave && !state.isSaving
                ? () =>
                    context.read<DeckEditBloc>().add(const SaveDeckEdit())
                : null,
            child: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.deckEditSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.deckEditFieldTitle,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                context
                    .read<DeckEditBloc>()
                    .add(UpdateEditTitle(value));
              },
            ),
            const SizedBox(height: 12),
            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.deckEditFieldDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                context
                    .read<DeckEditBloc>()
                    .add(UpdateEditDescription(value));
              },
            ),
            const SizedBox(height: 24),
            // Cards header
            Row(
              children: [
                Text(
                  l10n.deckEditCardsCount(state.cards.length),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            // Cards list
            ...state.cards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final isEditing = _editingIndices.contains(index);

              return isEditing
                  ? _EditableCardTile(
                      card: card,
                      onSave: (front, back) {
                        context.read<DeckEditBloc>().add(UpdateEditCard(
                              index: index,
                              front: front,
                              back: back,
                            ));
                        setState(() => _editingIndices.remove(index));
                      },
                      onCancel: () {
                        setState(() => _editingIndices.remove(index));
                      },
                    )
                  : _ViewCardTile(
                      card: card,
                      onEdit: () {
                        setState(() => _editingIndices.add(index));
                      },
                      onDelete: () {
                        context
                            .read<DeckEditBloc>()
                            .add(RemoveEditCard(index));
                        _editingIndices.remove(index);
                      },
                    );
            }),
            const SizedBox(height: 16),
            // Add new card
            CardInputForm(
              onAdd: (front, back,
                      {cardType = CardType.basic, metadata = ''}) {
                context.read<DeckEditBloc>().add(AddEditCard(
                      front: front,
                      back: back,
                      cardType: cardType,
                      metadata: metadata,
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewCardTile extends StatelessWidget {
  final EditableCard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ViewCardTile({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.front,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                  tooltip: l10n.deckEditEditCard,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  tooltip: l10n.deckEditDeleteCard,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
            Text(
              card.back,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (!card.isNew && card.srData != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.deckEditRepetitions(card.srData!.repetitions),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableCardTile extends StatefulWidget {
  final EditableCard card;
  final void Function(String front, String back) onSave;
  final VoidCallback onCancel;

  const _EditableCardTile({
    required this.card,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_EditableCardTile> createState() => _EditableCardTileState();
}

class _EditableCardTileState extends State<_EditableCardTile> {
  late final TextEditingController _frontController;
  late final TextEditingController _backController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card.front);
    _backController = TextEditingController(text: widget.card.back);
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final frontChanged =
        !widget.card.isNew &&
        _frontController.text.trim() != widget.card.originalFront;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _frontController,
              decoration: InputDecoration(
                labelText: l10n.deckEditFront,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            if (frontChanged) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  // 警告は警告の色・形・文字をそろえる（7-11）
                  Icon(Icons.warning_amber_rounded,
                      size: 20, color: AppColors.of(context).warningText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.deckEditSrResetWarning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).warningText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _backController,
              decoration: InputDecoration(
                labelText: l10n.deckEditBack,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(l10n.deckEditCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final front = _frontController.text.trim();
                    final back = _backController.text.trim();
                    if (front.isNotEmpty && back.isNotEmpty) {
                      widget.onSave(front, back);
                    }
                  },
                  child: Text(l10n.deckEditDone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
