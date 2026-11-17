import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/core/di/injection_container.dart';
import 'package:educards/features/audio/domain/tts_service.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/study/presentation/widgets/card_content_renderer.dart';
import 'package:educards/l10n/app_localizations.dart';
import '../bloc/listen_mode_bloc.dart';
import '../bloc/listen_mode_event.dart';
import '../bloc/listen_mode_state.dart';

class ListenModePage extends StatefulWidget {
  const ListenModePage({super.key});

  @override
  State<ListenModePage> createState() => _ListenModePageState();
}

class _ListenModePageState extends State<ListenModePage> {
  final TtsService _tts = sl<TtsService>();

  /// Generation counter to cancel stale playback cycles.
  int _playbackGeneration = 0;

  @override
  void dispose() {
    _playbackGeneration++;
    _tts.stop();
    super.dispose();
  }

  Future<void> _runPlayback(ListenModeActive state) async {
    _playbackGeneration++;
    final generation = _playbackGeneration;

    await _tts.stop();
    await _tts.setRate(state.speed);

    final text = _getTextForState(state);
    if (text.isEmpty) {
      if (mounted && _playbackGeneration == generation) {
        context.read<ListenModeBloc>().add(const AdvancePhase());
      }
      return;
    }

    await _tts.speak(text);

    if (!mounted || _playbackGeneration != generation) return;

    // Pause between front→back or between cards
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted || _playbackGeneration != generation) return;

    context.read<ListenModeBloc>().add(const AdvancePhase());
  }

  String _getTextForState(ListenModeActive state) {
    final card = state.currentCard;
    final renderer = getRenderer(card.cardType);
    return renderer.getTextForTts(card, isFlipped: !state.isShowingFront);
  }

  void _onSkipNext() {
    _playbackGeneration++;
    _tts.stop();
    context.read<ListenModeBloc>().add(const SkipNext());
  }

  void _onSkipPrevious() {
    _playbackGeneration++;
    _tts.stop();
    context.read<ListenModeBloc>().add(const SkipPrevious());
  }

  void _onTogglePlayPause() {
    final state = context.read<ListenModeBloc>().state;
    if (state is ListenModeActive && state.isPlaying) {
      _playbackGeneration++;
      _tts.stop();
    }
    context.read<ListenModeBloc>().add(const TogglePlayPause());
  }

  void _onSpeedChanged(double speed) {
    _tts.setRate(speed);
    context.read<ListenModeBloc>().add(UpdateSpeed(speed));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListenModeBloc, ListenModeState>(
      listener: (context, state) {
        if (state is ListenModeActive && state.isPlaying) {
          _runPlayback(state);
        } else if (state is ListenModeActive && !state.isPlaying) {
          _playbackGeneration++;
          _tts.stop();
        } else if (state is ListenModeComplete) {
          _playbackGeneration++;
          _tts.stop();
        }
      },
      child: BlocBuilder<ListenModeBloc, ListenModeState>(
        builder: (context, state) => switch (state) {
          ListenModeInitial() => const SizedBox.shrink(),
          ListenModeLoading() => _buildLoading(context),
          ListenModeActive() => _buildActive(context, state),
          ListenModeComplete() => _buildComplete(context, state),
          ListenModeError() => _buildError(context, state),
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.listenModeTitle)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildActive(BuildContext context, ListenModeActive state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = state.currentCard;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.listenModeTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _playbackGeneration++;
            _tts.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Deck title and progress
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  Text(
                    state.deckTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.listenModeCardProgress(state.currentIndex + 1, state.totalCards),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (state.currentIndex + 1) / state.totalCards,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildCardContent(context, card, state),
              ),
            ),

            // Speed selector
            _buildSpeedSelector(context, state.speed),

            const SizedBox(height: 8),

            // Playback controls
            _buildControls(context, state),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    Flashcard card,
    ListenModeActive state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Side indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: state.isShowingFront
                      ? colorScheme.primaryContainer
                      : colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  state.isShowingFront ? l10n.listenModeFront : l10n.listenModeBack,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: state.isShowingFront
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Card text
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    state.isShowingFront ? card.front : card.back,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Speaking indicator
              if (state.isPlaying) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volume_up,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.listenModeSpeaking,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSelector(BuildContext context, double currentSpeed) {
    final l10n = AppLocalizations.of(context);
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.listenModeSpeed, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          ...speeds.map((speed) {
            final isSelected = (currentSpeed - speed).abs() < 0.01;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ChoiceChip(
                label: Text('${speed}x'),
                selected: isSelected,
                onSelected: (_) => _onSpeedChanged(speed),
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, ListenModeActive state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton.filled(
          onPressed: state.currentIndex > 0 ? _onSkipPrevious : null,
          icon: const Icon(Icons.skip_previous),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        // Play / Pause
        IconButton.filled(
          onPressed: _onTogglePlayPause,
          icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
          iconSize: 48,
        ),
        const SizedBox(width: 16),
        // Next
        IconButton.filled(
          onPressed: _onSkipNext,
          icon: const Icon(Icons.skip_next),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildComplete(BuildContext context, ListenModeComplete state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.listenModeTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.listenModeComplete,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.listenModeCompleteSummary(state.totalCards, state.deckTitle),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.listenModeClose),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, ListenModeError state) {
    return switch (state.errorType) {
      ListenModeErrorType.deckEmpty => l10n.errorDeckNoCards,
      ListenModeErrorType.unknown => state.detail ?? l10n.errorUnknown,
    };
  }

  Widget _buildError(BuildContext context, ListenModeError errorState) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.listenModeTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_errorMessage(l10n, errorState), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.listenModeClose),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
