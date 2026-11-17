import 'package:equatable/equatable.dart';

sealed class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadProgress extends ProgressEvent {
  const LoadProgress();
}
