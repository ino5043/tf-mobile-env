import 'package:equatable/equatable.dart';

sealed class StudyPlanEvent extends Equatable {
  const StudyPlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudyPlan extends StudyPlanEvent {
  const LoadStudyPlan();
}
