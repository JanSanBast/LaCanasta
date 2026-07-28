import 'package:uuid/uuid.dart';
import 'card.dart';

class Player 
{
  final String id;

  final String name;

  int score;

  final List<Card> _hand = [];

  static const _uuid = Uuid();

  Player({required this.name, this.score = 0}) : id = _uuid.v4();


  List<Card> get hand => List.unmodifiable(_hand);

  void addCard(Card card)
  {
    _hand.add(card);
  }

  void addCards(List<Card> cards)
  {
    _hand.addAll(cards);
  }

  void removeCard(Card card)
  {
    if (!_hand.remove(card)) {
      throw Exception('Card not found in hand');
    }
  }

  void removeCards(List<Card> cards)
  {
    for (final card in cards)
    {
      try {
        removeCard(card);
      } catch (e) {
        throw Exception('Card not found in hand: ${card.id}');
      }
    }
  }

  void moveCard(Card card, int newIndex)
  {
    final currentIndex = _hand.indexOf(card);

    if (currentIndex == -1) throw Exception('Card not found in hand');

    _hand.removeAt(currentIndex);

    final clampedIndex = newIndex.clamp(0, _hand.length);
    _hand.insert(clampedIndex, card);
  }

  bool hasCard(Card card)
  {
    return _hand.contains(card);
  }

  int get handSize => _hand.length;

  @override
  String toString()
  {
    return 'Player {id: $id, name: $name, score: $score, handSize: ${_hand.length}}';
  }
}