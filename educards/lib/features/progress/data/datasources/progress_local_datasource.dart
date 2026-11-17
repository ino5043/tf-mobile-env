import 'package:hive/hive.dart';

import 'package:educards/core/error/exceptions.dart';
import '../models/study_stats_model.dart';

abstract class ProgressLocalDataSource {
  StudyStatsModel? getStatsByDate(DateTime date);
  Future<void> saveStats(StudyStatsModel stats);
  List<StudyStatsModel> getAllStats();
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final Box<StudyStatsModel> _box;

  ProgressLocalDataSourceImpl(this._box);

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  StudyStatsModel? getStatsByDate(DateTime date) {
    try {
      return _box.get(_dateKey(date));
    } catch (e) {
      throw CacheException('Failed to load stats: $e');
    }
  }

  @override
  Future<void> saveStats(StudyStatsModel stats) async {
    try {
      await _box.put(_dateKey(stats.date), stats);
    } catch (e) {
      throw CacheException('Failed to save stats: $e');
    }
  }

  @override
  List<StudyStatsModel> getAllStats() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to load all stats: $e');
    }
  }
}
