import 'package:canasta_app/domain/enums/card_value.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/domain/models/meld.dart';

class MeldRules
{
  static const int minCardsToOpen = 3;

  static CardValue validateNewMeldCards(List<Card> cards)
  {
    if (cards.length < minCardsToOpen) throw Exception('Se necesitan al menos $minCardsToOpen cartas para abrir un canasta.');

    final naturals = cards.where((card) => !card.isWildCard).toList();
    final wildCount = cards.length - naturals.length;

    if (naturals.isEmpty) return CardValue.joker;

    final baseValue = naturals.first.value;
    final sameValue = naturals.every((card) => card.value == baseValue);

    if (!sameValue) throw Exception('Todas las cartas naturales deben tener el mismo valor.');
    if (wildCount >= naturals.length) throw Exception('El número de comodines no puede ser mayor o igual al número de cartas naturales.');

    return baseValue;
  }

  static bool canAddSingleCard(Meld meld, Card card)
  {
    return _canAccept(meld.baseValue, card, meld.wildCards, meld.naturalCards);
  }

  static void validateCardsToAddToMeld(Meld meld, List<Card> cards)
  {
    int meldWildCards = meld.wildCards;
    int naturalCards = meld.naturalCards;

    for (final card in cards)
    {
      if (!_canAccept(meld.baseValue, card, meldWildCards, naturalCards)) throw Exception('No se puede añadir la carta: ${card.value} al canasta.');
      if (card.isWildCard) { meldWildCards++; } else { naturalCards++; }
    }
  }

  static bool _canAccept(CardValue baseValue, Card card, int wildCards, int naturalCards)
  {
    if (baseValue == CardValue.joker) { return card.isWildCard; }
    if (card.isWildCard) { return wildCards + 1 < naturalCards; } // Si la carta es un comodin, solo se puede añadir si el número de comodines será menor que el número de cartas naturales.
    return card.value == baseValue; // Si la carta no es un comodin, solo se puede añadir si el valor de la carta coincide con el valor base del canasta.
  }
}