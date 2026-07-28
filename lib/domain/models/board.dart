import 'package:collection/collection.dart';
import '../enums/enums.dart';
import 'card.dart';
import 'meld.dart';

// Class Board: Modelo de comportamiento de la clase Board. Simula el tablero de juego.

class Board
{
  final List<Card> _deck = [];

  final List<Card> _discardPile = [];

  final Map<String, List<Meld>> _meldsByOwner = {}; // Canastas que tiene el jugador (o equipo). Identificadas por el ID del jugador (o equipo).

  Board();


  List<Card> get deck => _deck;

  Card get deckPeekCard => _deck.last;

  List<Card> get discardPile => _discardPile;

  void discard(Card card)
  {
    _discardPile.add(card);
  }

  Card drawFromDeck()
  {
    if (_deck.isEmpty) throw Exception('The deck is empty. A card can not be drawed');
    return _deck.removeLast();
  }

  void initializeDiscardPile(List<Card> discardPile)
  {
    _discardPile.addAll(discardPile);
  }

  void discardCard(Card card)
  {
    _discardPile.add(card);
  }

  Card getLastDiscard()
  {
    if (_discardPile.isEmpty) {
      throw Exception('Discard pile is empty');
    }

    return _discardPile.last;
  }

  List<Card> takeDiscardPile()
  {
    if (_discardPile.isEmpty)
    {
      throw Exception('Discard pile is empty');
    }

    _discardPile.removeLast(); // Borramos la última carta porqué no se añade a la mano del jugador que toma el descarte, sino que se queda en la mesa.

    final cardsToTake = _discardPile;
    _discardPile.clear(); // Limpiamos los descartes después de que el jugador tome la pila de descarte.

    return cardsToTake;
  }

  Meld? findMeldByIdValue(String id, CardValue value)
  {
    final melds = _meldsByOwner[id];

    if (melds == null) return null;

    return melds.firstWhereOrNull(
      (meld) => meld.baseValue == value,
    );
  }

  void addCardsToDeck(List<Card> cards)
  {
    _deck.addAll(cards);
  }

  void shuffleDeck()
  {
    _deck.shuffle();
  }
}