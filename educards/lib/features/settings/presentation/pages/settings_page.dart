import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => switch (state) {
          SettingsInitial() || SettingsLoading() => const LoadingIndicator(),
          SettingsError(:final message) => Center(child: Text(message)),
          SettingsLoaded(:final settings) => _buildSettingsList(
              context, l10n, settings),
        },
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    AppLocalizations l10n,
    AppSettings settings,
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
        _ApiKeyField(
          initialValue: settings.claudeApiKey ?? '',
          onSaved: (key) => context
              .read<SettingsBloc>()
              .add(UpdateClaudeApiKey(key)),
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

class _ApiKeyField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSaved;

  const _ApiKeyField({required this.initialValue, required this.onSaved});

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  late final TextEditingController _controller;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: l10n.settingsClaudeApiKey,
        hintText: l10n.settingsClaudeApiKeyHint,
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => widget.onSaved(_controller.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}
