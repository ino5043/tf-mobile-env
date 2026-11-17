import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../../domain/usecases/get_study_queue_usecase.dart';
import 'study_plan_event.dart';
import 'study_plan_state.dart';

class StudyPlanBloc extends Bloc<StudyPlanEvent, StudyPlanState> {
  final GetStudyQueueUseCase getStudyQueue;

  StudyPlanBloc({required this.getStudyQueue})
      : super(const StudyPlanInitial()) {
    on<LoadStudyPlan>(_onLoadStudyPlan);
  }

  Future<void> _onLoadStudyPlan(
    LoadStudyPlan event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(const StudyPlanLoading());
    try {
      final queue = await getStudyQueue(const NoParams());
      emit(StudyPlanLoaded(queue));
    } catch (e) {
      emit(StudyPlanError(e.toString()));
    }
  }
}
