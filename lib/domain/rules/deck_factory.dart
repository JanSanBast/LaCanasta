import 'package:canasta_app/domain/enums/enums.dart';
import 'package:canasta_app/domain/models/card.dart';

// Class DeckFactory: Clase encargada de generar la baraja inicial de una ronda

class DeckFactory
{
  static const int _deckCounts = 3; // Se juega con tres barajas enteras

  static const int _jokersPerDeck = 3; // Cada baraja tiene 3 jokers

  static List<Card> createCanastaDeck()
  {
    final cards = <Card>[];

    for (final value in CardValue.values)
    {
      if (value == CardValue.joker) continue; // Como los Joker no tiene palo, los tratamos a parte
      for (final suit in CardSuit.values)
      {
        for (int i = 0; i < _deckCounts; ++i) { cards.add(Card(value: value, suit: suit)); }
      }
    }

    final totalJokers = _deckCounts * _jokersPerDeck;

    for ( int i = 0; i < totalJokers; ++i) { cards.add(Card(value: CardValue.joker)); }

    return cards;
  }
}