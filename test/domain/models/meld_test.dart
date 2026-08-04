import 'package:canasta_app/domain/enums/enums.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/domain/models/meld.dart';
import 'package:flutter_test/flutter_test.dart';

void main()
{
  group('Meld', ()
  {
    test('Se crea correctamente con 3 cartas naturales del mismo valor', () 
    {
      final meld = Meld(baseValue: CardValue.seven, 
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades)
        ]);
      
      expect(meld.totalCards, 3);
      expect(meld.wildCards, 0);
      expect(meld.naturalCards, 3);
      expect(meld.type, MeldType.clean);
      expect(meld.isClosed, isFalse);
    });

    test('addCards añade las cartas sin validar. La validación es responsabilidad de GameEngine', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
        ],
      );

      meld.addCards([Card(value: CardValue.eight, suit: CardSuit.hearts)]);

      expect(meld.totalCards, 2); // Se añade la carta porque no valida nada
    });

    test('isClosed se activa a partir de 7 cartas', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: List.generate(6, (i) => Card(value: CardValue.seven, suit: CardSuit.values[i % 4])),
      );

      expect(meld.isClosed, isFalse);

      meld.addCards([Card(value: CardValue.seven, suit: CardSuit.hearts)]);

      expect(meld.totalCards, 7);
      expect(meld.isClosed, isTrue);
    });

    test('Type devuelve clean cuando no hay comodines', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
        ],
      );

      expect(meld.type, MeldType.clean);
    });

    test('Type devuelve dirty cuando hay mezcla de naturales y comodines', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
          Card(value: CardValue.joker),
        ],
      );

      expect(meld.type, MeldType.dirty);
    });

    test('Type devuelve wild cuando la canasta es solo de comodines', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.joker),
          Card(value: CardValue.joker),
        ],
      );

      expect(meld.type, MeldType.wild);
    });
  });
}