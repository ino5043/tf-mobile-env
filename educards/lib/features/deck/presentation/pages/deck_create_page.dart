import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/l10n/app_localizations.dart';
import '../../domain/entities/card_type.dart';
import '../bloc/deck_create_bloc.dart';
import '../bloc/deck_create_event.dart';
import '../bloc/deck_create_state.dart';
import '../widgets/card_input_form.dart';

enum MediaSource { text, pdf, image }

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
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<DeckCreateBloc, DeckCreateState>(
      listener: (context, state) {
        if (state is DeckCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deckCreateSuccess)),
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
              title: Text(l10n.deckCreateTitle),
              bottom: TabBar(
                tabs: [
                  Tab(icon: const Icon(Icons.edit), text: l10n.deckCreateTabManual),
                  Tab(icon: const Icon(Icons.file_upload), text: l10n.deckCreateTabImport),
                  Tab(icon: const Icon(Icons.auto_awesome), text: l10n.deckCreateTabAI),
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
                    label: Text(l10n.deckCreateSave),
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
                        decoration: InputDecoration(
                          labelText: l10n.deckCreateDeckTitle,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) => context
                            .read<DeckCreateBloc>()
                            .add(UpdateTitle(v)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: l10n.deckCreateDescription,
                          border: const OutlineInputBorder(),
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
                          l10n.deckCreateCardsAdded(editing.cards.length),
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
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CardInputForm(
            onAdd: (front, back,
                    {cardType = CardType.basic, metadata = ''}) =>
                context.read<DeckCreateBloc>().add(AddCard(
                      front: front,
                      back: back,
                      cardType: cardType,
                      metadata: metadata,
                    )),
          ),
          const SizedBox(height: 16),
          if (cards.isNotEmpty) ...[
            Text(
              l10n.deckCreateCardsCount(cards.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...cards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final typeLabel = switch (card.cardType) {
                CardType.basic => '',
                CardType.cloze => l10n.cardTypeCloze,
                CardType.multiChoice => l10n.cardTypeMultiChoice,
                CardType.stepByStep => l10n.cardTypeStepByStep,
              };
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(card.front,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (typeLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Chip(
                            label: Text(typeLabel,
                                style: const TextStyle(fontSize: 14)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
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
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.file_upload_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            l10n.deckCreateImportTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.deckCreateImportSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.deckCreateImportFormats,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(l10n.deckCreateImportCsvFormat),
                  Text(l10n.deckCreateImportJsonFormat),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                context.read<DeckCreateBloc>().add(const ImportFile()),
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.deckCreateChooseFile),
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
  CardType _cardType = CardType.basic;
  MediaSource _source = MediaSource.text;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  String? _selectedFileMimeType;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final allowedExtensions = _source == MediaSource.pdf
        ? ['pdf']
        : ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    String mimeType;
    if (_source == MediaSource.pdf) {
      mimeType = 'application/pdf';
    } else {
      final ext = file.extension?.toLowerCase() ?? '';
      mimeType = switch (ext) {
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
    }

    setState(() {
      _selectedFileName = file.name;
      _selectedFileBytes = file.bytes;
      _selectedFileMimeType = mimeType;
    });
  }

  bool get _canGenerate {
    if (widget.isGenerating) return false;
    if (_source == MediaSource.text) {
      return _topicController.text.trim().isNotEmpty;
    }
    return _selectedFileBytes != null;
  }

  void _onGenerate() {
    if (_source == MediaSource.text) {
      context.read<DeckCreateBloc>().add(GenerateWithAI(
            topic: _topicController.text.trim(),
            cardCount: _cardCount,
            difficulty: _difficulty,
            cardType: _cardType,
          ));
    } else {
      context.read<DeckCreateBloc>().add(GenerateFromMedia(
            fileBytes: _selectedFileBytes!,
            fileName: _selectedFileName!,
            mimeType: _selectedFileMimeType!,
            cardCount: _cardCount,
            cardType: _cardType,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.auto_awesome, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n.deckCreateAITitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Source selector
          Text(l10n.deckCreateAISource, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          SegmentedButton<MediaSource>(
            segments: [
              ButtonSegment(
                  value: MediaSource.text,
                  label: Text(l10n.deckCreateAISourceText),
                  icon: const Icon(Icons.text_fields)),
              ButtonSegment(
                  value: MediaSource.pdf,
                  label: Text(l10n.deckCreateAISourcePdf),
                  icon: const Icon(Icons.picture_as_pdf)),
              ButtonSegment(
                  value: MediaSource.image,
                  label: Text(l10n.deckCreateAISourceImage),
                  icon: const Icon(Icons.image)),
            ],
            selected: {_source},
            onSelectionChanged: widget.isGenerating
                ? null
                : (v) => setState(() {
                      _source = v.first;
                      _selectedFileName = null;
                      _selectedFileBytes = null;
                      _selectedFileMimeType = null;
                    }),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          // Source-specific UI
          if (_source == MediaSource.text) ...[
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: l10n.deckCreateAITopic,
                hintText: l10n.deckCreateAITopicHint,
                border: const OutlineInputBorder(),
              ),
              enabled: !widget.isGenerating,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'easy', label: Text(l10n.deckCreateAIDifficultyEasy)),
                ButtonSegment(value: 'medium', label: Text(l10n.deckCreateAIDifficultyMedium)),
                ButtonSegment(value: 'hard', label: Text(l10n.deckCreateAIDifficultyHard)),
              ],
              selected: {_difficulty},
              onSelectionChanged: widget.isGenerating
                  ? null
                  : (v) => setState(() => _difficulty = v.first),
            ),
          ] else ...[
            // PDF / Image file picker
            OutlinedButton.icon(
              onPressed: widget.isGenerating ? null : _pickFile,
              icon: Icon(_source == MediaSource.pdf
                  ? Icons.picture_as_pdf
                  : Icons.image),
              label: Text(_selectedFileName ?? l10n.deckCreateChooseFile),
            ),
            if (_selectedFileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _selectedFileName!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() {
                        _selectedFileName = null;
                        _selectedFileBytes = null;
                        _selectedFileMimeType = null;
                      }),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          // Card count slider (always visible)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.deckCreateAICardsCount(_cardCount),
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
          // Card type (always visible)
          Text(l10n.deckCreateAICardType, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          SegmentedButton<CardType>(
            segments: [
              ButtonSegment(value: CardType.basic, label: Text(l10n.cardTypeBasic)),
              ButtonSegment(value: CardType.cloze, label: Text(l10n.cardTypeCloze)),
              ButtonSegment(
                  value: CardType.multiChoice, label: Text(l10n.cardTypeMultiChoice)),
              ButtonSegment(
                  value: CardType.stepByStep, label: Text(l10n.cardTypeStepByStep)),
            ],
            selected: {_cardType},
            onSelectionChanged: widget.isGenerating
                ? null
                : (v) => setState(() => _cardType = v.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _canGenerate ? _onGenerate : null,
            icon: widget.isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(widget.isGenerating ? l10n.deckCreateAIGenerating : l10n.deckCreateAIGenerate),
          ),
          if (widget.isGenerating)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _source == MediaSource.text
                    ? l10n.deckCreateAIGeneratingText
                    : l10n.deckCreateAIGeneratingMedia,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
