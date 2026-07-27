import 'package:uuid/uuid.dart';
import '../enums/enums.dart';
import 'card.dart';

class Meld 
{
  final String id;

  final CardValue baseValue;

  final List<Card> _cards;

  static const _uuid = Uuid();

  Meld({required this.baseValue, required List<Card> cards}) : id = _uuid.v4(), _cards = List.unmodifiable(cards);


  List<Card> get cards => List.unmodifiable(_cards);

  int get wildCards => _cards.where((card) => card.isWildCard).length;

  int get naturalCards => _cards.where((card) => !card.isWildCard).length;

  int get totalCards => _cards.length;

  bool get isClosed => _cards.length >= 7;

  void addCards(List<Card> cards) // Para simplificar funciones, solo se añadirán cartas mediante una Lista, ya sea de uno o más elementos.
  {
    for (final card in cards) {
      if (!canAcceptCard(card)) {
        throw Exception('Cannot add card to meld: ${card.toString()}'); // Si no se puede añadir una carta, no se añade ninguna de las cartas a la canasta.
      }
    }
    _cards.addAll(cards);
  }

  MeldType get type
  {
    if (wildCards == 0) return MeldType.clean; // No hay comodines, por lo que es un canasta limpia.

    if (naturalCards == 0) return MeldType.wild; // Todos son comodines.

    return MeldType.dirty; // Hay una mezcla de comodines y cartas naturales, por tanto, es un canasta sucia.
  }

  bool canAcceptCard(Card card)
  {
    if (card.isWildCard) return wildCards + 1 < naturalCards; // Si la carta es un comodin, solo se puede añadir si el número de comodines será menor que el número de cartas naturales.

    return card.value == baseValue; // Si la carta no es un comodin, solo se puede añadir si el valor de la carta coincide con el valor base del canasta.
  }
}