import 'package:uuid/uuid.dart';
import '../enums/enums.dart';

class Card
{
  final String id;

  final CardSuit? suit; // Los Jokers no tienen palo, por eso es nullable.

  final CardValue value;

  static const _uuid = Uuid();

  Card({required this.value, CardSuit? suit}) : id = _uuid.v4(), suit = value == CardValue.joker ? null : suit; // Los Jokers no tienen palo, por eso se asigna null si el valor es Joker.


  int get score
  {
    if (value == CardValue.joker) return 50;

    if (value == CardValue.ace || value == CardValue.two) return 20;

    if (value == CardValue.three && _isRedCard()) return 100;

    if (_lessThanEight) return 5; // 3 (negro), 4, 5, 6, 7

    return 10; // 8, 9, 10, J, Q, K
  }

  bool get isWildCard
  {
    return value == CardValue.joker || value == CardValue.two;
  }

  bool get isRedThree
  {
    return value == CardValue.three && _isRedCard();
  }

  bool get isBlackThree
  {
    return value == CardValue.three && _isBlackCard();
  }

  bool get _lessThanEight
  {
    return [
      CardValue.four,
      CardValue.five,
      CardValue.six,
      CardValue.seven,
    ].contains(value) || isBlackThree;
  }

  bool _isRedCard()
  {
    return (suit == CardSuit.diamonds) || (suit == CardSuit.hearts);
  }

  bool _isBlackCard()
  {
    return (suit == CardSuit.clubs) || (suit == CardSuit.spades);
  }

  @override
  String toString()
  {
    return 'Card {suit: ${suit?.name}, value: ${value.name}}';
  }

  @override
  bool operator ==(Object other)
  {
    if (identical(this, other)) return true;

    return other is Card && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

}