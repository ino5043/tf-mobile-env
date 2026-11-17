import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:educards/l10n/app_localizations.dart';
import '../../domain/entities/card_type.dart';

class CardInputForm extends StatefulWidget {
  final void Function(
    String front,
    String back, {
    CardType cardType,
    String metadata,
  }) onAdd;

  const CardInputForm({super.key, required this.onAdd});

  @override
  State<CardInputForm> createState() => _CardInputFormState();
}

class _CardInputFormState extends State<CardInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  // Multi-choice fields
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;

  // Step-by-step fields
  final _hintController = TextEditingController();
  final _stepsControllers = [TextEditingController()];

  CardType _selectedType = CardType.basic;

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    _hintController.dispose();
    for (final c in _stepsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    String metadata = '';

    switch (_selectedType) {
      case CardType.basic:
        break;
      case CardType.cloze:
        final blanks = RegExp(r'\{\{(.+?)\}\}')
            .allMatches(front)
            .map((m) => m.group(1)!)
            .toList();
        if (blanks.isNotEmpty) {
          metadata = jsonEncode({'blanks': blanks});
        }
      case CardType.multiChoice:
        final options = _optionControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        metadata = jsonEncode({
          'options': options,
          'correctIndex': _correctIndex,
        });
      case CardType.stepByStep:
        final hint = _hintController.text.trim();
        final steps = _stepsControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        metadata = jsonEncode({
          'hints': hint.isNotEmpty ? [hint] : <String>[],
          'steps': steps,
        });
    }

    widget.onAdd(front, back, cardType: _selectedType, metadata: metadata);
    _clearForm();
  }

  void _clearForm() {
    _frontController.clear();
    _backController.clear();
    for (final c in _optionControllers) {
      c.clear();
    }
    _correctIndex = 0;
    _hintController.clear();
    for (final c in _stepsControllers) {
      c.clear();
    }
    setState(() {
      _stepsControllers
        ..clear()
        ..add(TextEditingController());
    });
  }

  String _cardTypeLabel(CardType type, AppLocalizations l10n) {
    return switch (type) {
      CardType.basic => l10n.cardTypeBasic,
      CardType.cloze => l10n.cardTypeCloze,
      CardType.multiChoice => l10n.cardTypeMultiChoice,
      CardType.stepByStep => l10n.cardTypeStepByStep,
    };
  }

  IconData _cardTypeIcon(CardType type) {
    return switch (type) {
      CardType.basic => Icons.quiz_outlined,
      CardType.cloze => Icons.text_fields,
      CardType.multiChoice => Icons.checklist,
      CardType.stepByStep => Icons.format_list_numbered,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.cardInputAddCard,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<CardType>(
                segments: CardType.values
                    .map((t) => ButtonSegment(
                          value: t,
                          label: Text(
                            _cardTypeLabel(t, l10n),
                            style: const TextStyle(fontSize: 11),
                          ),
                          icon: Icon(_cardTypeIcon(t), size: 16),
                        ))
                    .toList(),
                selected: {_selectedType},
                onSelectionChanged: (v) =>
                    setState(() => _selectedType = v.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frontController,
                decoration: InputDecoration(
                  labelText: _frontLabel(l10n),
                  helperText: _frontHelper(l10n),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.cardInputRequired : null,
              ),
              const SizedBox(height: 12),
              ..._buildTypeSpecificFields(context),
              TextFormField(
                controller: _backController,
                decoration: InputDecoration(
                  labelText: _backLabel(l10n),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.cardInputRequired : null,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: Text(l10n.cardInputAddCard),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _frontLabel(AppLocalizations l10n) => switch (_selectedType) {
        CardType.basic => l10n.cardInputFrontBasic,
        CardType.cloze => l10n.cardInputFrontCloze,
        CardType.multiChoice => l10n.cardInputFrontMultiChoice,
        CardType.stepByStep => l10n.cardInputFrontStepByStep,
      };

  String? _frontHelper(AppLocalizations l10n) => switch (_selectedType) {
        CardType.cloze => l10n.cardInputFrontClozeHint,
        _ => null,
      };

  String _backLabel(AppLocalizations l10n) => switch (_selectedType) {
        CardType.basic => l10n.cardInputBackBasic,
        CardType.cloze => l10n.cardInputBackCloze,
        CardType.multiChoice => l10n.cardInputBackMultiChoice,
        CardType.stepByStep => l10n.cardInputBackStepByStep,
      };

  List<Widget> _buildTypeSpecificFields(BuildContext context) {
    return switch (_selectedType) {
      CardType.basic => [],
      CardType.cloze => [],
      CardType.multiChoice => _buildMultiChoiceFields(context),
      CardType.stepByStep => _buildStepByStepFields(context),
    };
  }

  List<Widget> _buildMultiChoiceFields(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      Text(l10n.cardInputOptions, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      ...List.generate(4, (i) {
        final label = String.fromCharCode(65 + i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _correctIndex = i),
                child: Icon(
                  i == _correctIndex
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: i == _correctIndex
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(
                    labelText: l10n.cardInputOption(label),
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => i < 2 && (v == null || v.trim().isEmpty)
                      ? l10n.cardInputOptionsMin
                      : null,
                ),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 4),
    ];
  }

  List<Widget> _buildStepByStepFields(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      TextFormField(
        controller: _hintController,
        decoration: InputDecoration(
          labelText: l10n.cardInputHint,
          prefixIcon: const Icon(Icons.lightbulb_outline),
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      Text(l10n.cardInputSolutionSteps, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      ...List.generate(_stepsControllers.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _stepsControllers[i],
                    decoration: InputDecoration(
                      labelText: l10n.cardInputStep(i + 1),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                if (i > 0)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () {
                      setState(() {
                        _stepsControllers[i].dispose();
                        _stepsControllers.removeAt(i);
                      });
                    },
                  ),
              ],
            ),
          )),
      TextButton.icon(
        onPressed: () {
          setState(() => _stepsControllers.add(TextEditingController()));
        },
        icon: const Icon(Icons.add, size: 16),
        label: Text(l10n.cardInputAddStep),
      ),
      const SizedBox(height: 4),
    ];
  }
}
