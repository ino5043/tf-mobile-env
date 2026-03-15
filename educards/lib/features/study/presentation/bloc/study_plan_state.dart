import 'package:equatable/equatable.dart';

import '../../domain/entities/study_queue.dart';

sealed class StudyPlanState extends Equatable {
  const StudyPlanState();

  @override
  List<Object?> get props => [];
}

class StudyPlanInitial extends StudyPlanState {
  const StudyPlanInitial();
}

class StudyPlanLoading extends StudyPlanState {
  const StudyPlanLoading();
}

class StudyPlanLoaded extends StudyPlanState {
  final StudyQueue queue;

  const StudyPlanLoaded(this.queue);

  @override
  List<Object?> get props => [queue];
}

class StudyPlanError extends StudyPlanState {
  final String message;

  const StudyPlanError(this.message);

  @override
  List<Object?> get props => [message];
}
