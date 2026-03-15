import 'dart:convert';

import 'package:csv/csv.dart';

class DeckImportService {
  /// Parse CSV content into a list of {front, back} maps.
  /// Supports optional header row (front,back).
  List<Map<String, String>> parseCSV(String content) {
    const converter = CsvToListConverter(eol: '\n');
    final rows = converter.convert(content);
    if (rows.isEmpty) return [];

    int startRow = 0;
    final firstRow = rows[0];
    if (firstRow.length >= 2) {
      final col0 = firstRow[0].toString().trim().toLowerCase();
      final col1 = firstRow[1].toString().trim().toLowerCase();
      if (col0 == 'front' && col1 == 'back') {
        startRow = 1;
      }
    }

    final cards = <Map<String, String>>[];
    for (int i = startRow; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 2) {
        final front = row[0].toString().trim();
        final back = row[1].toString().trim();
        if (front.isNotEmpty && back.isNotEmpty) {
          cards.add({'front': front, 'back': back});
        }
      }
    }
    return cards;
  }

  /// Parse JSON content into a list of {front, back} maps.
  /// Expects: [{"front":"Q","back":"A"}, ...]
  List<Map<String, String>> parseJSON(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('JSON must be an array of objects');
    }

    final cards = <Map<String, String>>[];
    for (final item in decoded) {
      if (item is Map) {
        final front = (item['front'] ?? '').toString().trim();
        final back = (item['back'] ?? '').toString().trim();
        if (front.isNotEmpty && back.isNotEmpty) {
          cards.add({'front': front, 'back': back});
        }
      }
    }
    return cards;
  }

  /// Detect format from file extension and parse accordingly.
  List<Map<String, String>> parseFile(String fileName, String content) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.csv')) {
      return parseCSV(content);
    } else if (lower.endsWith('.json')) {
      return parseJSON(content);
    } else {
      throw FormatException('Unsupported file format: $fileName');
    }
  }
}
