import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/core/widgets/loading_indicator.dart';
import 'package:educards/l10n/app_localizations.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        // キーの保存の結果は、保存が終わってから知らせる（失敗も含めて）
        listenWhen: (previous, current) =>
            current is SettingsLoaded &&
            current.keyNotice != null &&
            (previous is! SettingsLoaded ||
                previous.keyNotice != current.keyNotice),
        listener: (context, state) =>
            _showKeyNotice(context, l10n, (state as SettingsLoaded).keyNotice!),
        builder: (context, state) => switch (state) {
          SettingsInitial() || SettingsLoading() => const LoadingIndicator(),
          SettingsError(:final message) => Center(child: Text(message)),
          SettingsLoaded(:final settings, :final configuredProviders) =>
            _buildSettingsList(context, l10n, settings, configuredProviders),
        },
      ),
    );
  }

  void _showKeyNotice(
    BuildContext context,
    AppLocalizations l10n,
    KeySaveNotice notice,
  ) {
    final name = notice.provider.displayName;
    final message = switch (notice.result) {
      KeySaveResult.saved => l10n.settingsApiKeySavedMessage(name),
      KeySaveResult.deleted => l10n.settingsApiKeyDeletedMessage(name),
      KeySaveResult.failed => l10n.settingsApiKeySaveFailedMessage(name),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSettingsList(
    BuildContext context,
    AppLocalizations l10n,
    AppSettings settings,
    Set<AiProvider> configuredProviders,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.settingsStudyPlan,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildSliderTile(
          context: context,
          title: l10n.settingsDailyNewCards,
          subtitle: l10n.settingsCardsPerDay(settings.dailyNewCardLimit),
          value: settings.dailyNewCardLimit.toDouble(),
          min: 1,
          max: 50,
          onChanged: (value) => context
              .read<SettingsBloc>()
              .add(UpdateDailyNewCardLimit(value.round())),
        ),
        _buildSliderTile(
          context: context,
          title: l10n.settingsDailyReviewCards,
          subtitle: l10n.settingsCardsPerDay(settings.dailyReviewCardLimit),
          value: settings.dailyReviewCardLimit.toDouble(),
          min: 5,
          max: 100,
          onChanged: (value) => context
              .read<SettingsBloc>()
              .add(UpdateDailyReviewCardLimit(value.round())),
        ),
        const Divider(height: 32),
        Text(
          l10n.settingsAIGeneration,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsAiProvider,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<AiProvider>(
          segments: [
            for (final provider in AiProvider.values)
              ButtonSegment(
                value: provider,
                label: Text(provider.displayName),
              ),
          ],
          selected: {settings.aiProvider},
          showSelectedIcon: false,
          onSelectionChanged: (selected) => context
              .read<SettingsBloc>()
              .add(UpdateAiProvider(selected.single)),
        ),
        const SizedBox(height: 16),
        _ApiKeyField(
          // AI を選び直したら入力欄を作り直し、前の AI のキーが残らないようにする
          key: ValueKey(settings.aiProvider),
          provider: settings.aiProvider,
          isSaved: configuredProviders.contains(settings.aiProvider),
          onSaved: (key) => context
              .read<SettingsBloc>()
              .add(UpdateApiKey(settings.aiProvider, key)),
        ),
        const Divider(height: 32),
        Text(
          l10n.settingsTts,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildSliderTile(
          context: context,
          title: l10n.settingsSpeechSpeed,
          subtitle: '${settings.ttsSpeed.toStringAsFixed(1)}x',
          value: settings.ttsSpeed,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: '${settings.ttsSpeed.toStringAsFixed(1)}x',
          onChanged: (value) => context
              .read<SettingsBloc>()
              .add(UpdateTtsSpeed(
                double.parse(value.toStringAsFixed(1)),
              )),
        ),
        SwitchListTile(
          title: Text(l10n.settingsAutoReadAloud),
          subtitle: Text(l10n.settingsAutoReadAloudSubtitle),
          value: settings.autoReadAloud,
          onChanged: (value) => context
              .read<SettingsBloc>()
              .add(UpdateAutoReadAloud(value)),
        ),
        const Divider(height: 32),
        Text(
          l10n.settingsLanguage,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(l10n.settingsLanguage),
          trailing: DropdownButton<String?>(
            value: settings.locale,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.settingsLanguageSystem),
              ),
              DropdownMenuItem<String?>(
                value: 'en',
                child: Text(l10n.settingsLanguageEn),
              ),
              DropdownMenuItem<String?>(
                value: 'ja',
                child: Text(l10n.settingsLanguageJa),
              ),
            ],
            onChanged: (value) => context
                .read<SettingsBloc>()
                .add(UpdateLocale(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
    String? label,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? (max - min).round(),
            label: label ?? value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// API キーの入力欄。
///
/// 保存済みのキーは画面に戻さない（入力欄は常に空から始める）。
/// キーボードの予測や学習にキーが残らないよう、候補と自動修正を切る。
class _ApiKeyField extends StatefulWidget {
  final AiProvider provider;
  final bool isSaved;
  final ValueChanged<String> onSaved;

  const _ApiKeyField({
    super.key,
    required this.provider,
    required this.isSaved,
    required this.onSaved,
  });

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  final _controller = TextEditingController();
  bool _obscured = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(String value) {
    widget.onSaved(value);
    _controller.clear();
    setState(() => _obscured = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = widget.provider.displayName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          obscureText: _obscured,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) _save(value.trim());
          },
          decoration: InputDecoration(
            labelText: l10n.settingsApiKeyLabel(name),
            hintText: widget.isSaved
                ? l10n.settingsApiKeyHintSaved
                : l10n.settingsApiKeyHintEmpty,
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: _obscured
                      ? l10n.settingsApiKeyShow
                      : l10n.settingsApiKeyHide,
                  icon:
                      Icon(_obscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
                IconButton(
                  tooltip: l10n.settingsApiKeySave,
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    final value = _controller.text.trim();
                    if (value.isEmpty) return;
                    _save(value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsApiKeyHelp(widget.provider.apiKeyPageUrl),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (widget.provider == AiProvider.gemini) ...[
          const SizedBox(height: 4),
          Text(
            l10n.settingsApiKeyGeminiNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (widget.isSaved)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.settingsApiKeyDelete),
              onPressed: () => _save(''),
            ),
          ),
      ],
    );
  }
}
