import 'package:equatable/equatable.dart';

sealed class ListenModeEvent extends Equatable {
  const ListenModeEvent();

  @override
  List<Object?> get props => [];
}

/// Load deck and start auto-playing cards.
class StartListenMode extends ListenModeEvent {
  final String deckId;

  const StartListenMode(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

/// Toggle between playing and paused.
class TogglePlayPause extends ListenModeEvent {
  const TogglePlayPause();
}

/// Skip to next card (resets to front side).
class SkipNext extends ListenModeEvent {
  const SkipNext();
}

/// Go back to previous card (resets to front side).
class SkipPrevious extends ListenModeEvent {
  const SkipPrevious();
}

/// Update playback speed.
class UpdateSpeed extends ListenModeEvent {
  final double speed;

  const UpdateSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// Advance to next phase (front→back or back→next card).
/// Triggered by the UI after TTS + delay completes.
class AdvancePhase extends ListenModeEvent {
  const AdvancePhase();
}
