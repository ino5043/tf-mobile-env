import 'dart:convert';

import '../entities/card_type.dart';
import '../entities/deck.dart';

class ExportDeckUseCase {
  String call(Deck deck) {
    final data = {
      'title': deck.title,
      'description': deck.description,
      'exportedAt': DateTime.now().toIso8601String(),
      'cards': deck.cards.map((c) {
        final cardMap = <String, dynamic>{
          'front': c.front,
          'back': c.back,
        };
        if (c.cardType != CardType.basic) {
          cardMap['cardType'] = c.cardType.name;
          if (c.metadata.isNotEmpty) {
            cardMap['metadata'] = c.metadata;
          }
        }
        return cardMap;
      }).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
