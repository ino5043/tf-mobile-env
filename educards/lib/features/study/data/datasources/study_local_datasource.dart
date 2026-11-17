import 'package:hive/hive.dart';

import 'package:educards/core/error/exceptions.dart';
import '../models/study_record_model.dart';

abstract class StudyLocalDataSource {
  Future<void> saveStudyRecord(StudyRecordModel record);
  List<StudyRecordModel> getRecordsByDeck(String deckId);
}

class StudyLocalDataSourceImpl implements StudyLocalDataSource {
  final Box<StudyRecordModel> _box;

  StudyLocalDataSourceImpl(this._box);

  @override
  Future<void> saveStudyRecord(StudyRecordModel record) async {
    try {
      await _box.add(record);
    } catch (e) {
      throw CacheException('Failed to save study record: $e');
    }
  }

  @override
  List<StudyRecordModel> getRecordsByDeck(String deckId) {
    try {
      return _box.values.where((r) => r.deckId == deckId).toList();
    } catch (e) {
      throw CacheException('Failed to load study records: $e');
    }
  }
}
