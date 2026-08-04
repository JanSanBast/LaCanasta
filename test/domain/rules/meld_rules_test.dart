import 'package:canasta_app/domain/enums/card_suit.dart';
import 'package:canasta_app/domain/enums/card_value.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/domain/models/meld.dart';
import 'package:canasta_app/domain/rules/meld_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main()
{
  group('MeldRules.validateNewMeldCards', ()
  {
    test('Acepta 3 jokers', ()
    {
      final baseValue = MeldRules.validateNewMeldCards([
        Card(value: CardValue.joker),
        Card(value: CardValue.joker),
        Card(value: CardValue.joker)
      ]);

      expect(baseValue, CardValue.joker);
    });
    test('Acepta combinación de jokers y doses', ()
    {
      final baseValue = MeldRules.validateNewMeldCards([
        Card(value: CardValue.joker),
        Card(value: CardValue.two, suit: CardSuit.hearts),
        Card(value: CardValue.two, suit: CardSuit.clubs)
      ]);

      expect(baseValue, CardValue.joker);
    });

    test('Rechaza abrir canasta de comodines con menos de 3 cartas', ()
    {
    expect(
      () => MeldRules.validateNewMeldCards([
        Card(value: CardValue.joker),
        Card(value: CardValue.two, suit: CardSuit.hearts),
      ]),
      throwsException,
    );
  });
    test('Acepta 3 cartas naturales del mismo valor', ()
    {
      final baseValue = MeldRules.validateNewMeldCards([
        Card(value: CardValue.nine, suit: CardSuit.hearts),
        Card(value: CardValue.nine, suit: CardSuit.clubs),
        Card(value: CardValue.nine, suit: CardSuit.spades),
      ]);

      expect(baseValue, CardValue.nine);
    });

    test('Acepta 2 naturales + 1 comodín', ()
    {
      final baseValue = MeldRules.validateNewMeldCards([
        Card(value: CardValue.nine, suit: CardSuit.hearts),
        Card(value: CardValue.nine, suit: CardSuit.clubs),
        Card(value: CardValue.two, suit: CardSuit.spades), // comodín
      ]);

      expect(baseValue, CardValue.nine);
    });

    test('Rechaza menos de 3 cartas', ()
    {
      expect(
        () => MeldRules.validateNewMeldCards([
          Card(value: CardValue.nine, suit: CardSuit.hearts),
          Card(value: CardValue.nine, suit: CardSuit.clubs),
        ]),
        throwsException,
      );
    });

    test('Rechaza si hay igual o más comodines que cartas naturales', ()
    {
      expect(
        () => MeldRules.validateNewMeldCards([
          Card(value: CardValue.nine, suit: CardSuit.hearts),
          Card(value: CardValue.two, suit: CardSuit.clubs), // comodín
          Card(value: CardValue.joker), // comodín
        ]),
        throwsException,
      );
    });

    test('Rechaza cartas naturales de valores distintos', ()
    {
      expect(
        () => MeldRules.validateNewMeldCards([
          Card(value: CardValue.nine, suit: CardSuit.hearts),
          Card(value: CardValue.ten, suit: CardSuit.clubs),
          Card(value: CardValue.two, suit: CardSuit.spades),
        ]),
        throwsException,
      );
    });

    test('Si todas las cartas son comodines, el baseValue es un joker', ()
    {
      final baseValue = MeldRules.validateNewMeldCards([
        Card(value: CardValue.joker),
        Card(value: CardValue.two, suit: CardSuit.clubs),
        Card(value: CardValue.two, suit: CardSuit.spades),
      ]);

      expect(baseValue, CardValue.joker);
    });
  });

  group('MeldRules.canAddSingleCard', () 
  {
    test('Acepta un joker en una canasta de comodines', ()
    {
    final wildMeld = Meld(
      baseValue: CardValue.joker,
      cards: [
        Card(value: CardValue.joker),
        Card(value: CardValue.two, suit: CardSuit.hearts),
        Card(value: CardValue.two, suit: CardSuit.clubs),
      ],
    );

    expect(MeldRules.canAddSingleCard(wildMeld, Card(value: CardValue.joker)), isTrue);
  });

  test('Acepta un dos en una canasta de comodines', ()
  {
    final wildMeld = Meld(
      baseValue: CardValue.joker,
      cards: [
        Card(value: CardValue.joker),
        Card(value: CardValue.joker),
        Card(value: CardValue.joker),
      ],
    );

    expect(MeldRules.canAddSingleCard(wildMeld, Card(value: CardValue.two, suit: CardSuit.spades)), isTrue);
  });

  test('Rechaza una carta natural en una canasta de comodines', ()
  {
    final wildMeld = Meld(
      baseValue: CardValue.joker,
      cards: [
        Card(value: CardValue.joker),
        Card(value: CardValue.joker),
        Card(value: CardValue.joker),
      ],
    );

    expect(
      MeldRules.canAddSingleCard(wildMeld, Card(value: CardValue.seven, suit: CardSuit.hearts)),
      isFalse,
    );
  });
    test('Acepta una carta natural del mismo valor que la canasta', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
        ],
      );

      expect(
        MeldRules.canAddSingleCard(meld, Card(value: CardValue.seven, suit: CardSuit.diamonds)),
        isTrue,
      );
    });

    test('Rechaza una carta natural de valor distinto', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
        ],
      );

      expect(
        MeldRules.canAddSingleCard(meld, Card(value: CardValue.eight, suit: CardSuit.hearts)),
        isFalse,
      );
    });

    test('Rechaza un comodín si ya hay igual o más comodines que naturales', ()
    {
      // 2 naturales + 1 comodín: añadir otro comodín dejaría 2 comodines >= 2 naturales -> inválido
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.two, suit: CardSuit.spades), // comodín
        ],
      );

      expect(
        MeldRules.canAddSingleCard(meld, Card(value: CardValue.joker)),
        isFalse,
      );
    });
  });

  group('MeldRules.validateCardsToAddToMeld', ()
  {
    test('Permite añadir varios comodines de golpe sin restricción de ratio', ()
    {
      final wildMeld = Meld(
        baseValue: CardValue.joker,
        cards: [
          Card(value: CardValue.joker),
          Card(value: CardValue.joker),
          Card(value: CardValue.joker),
        ],
      );

      expect(
        () => MeldRules.validateCardsToAddToMeld(wildMeld, [
          Card(value: CardValue.two, suit: CardSuit.hearts),
          Card(value: CardValue.two, suit: CardSuit.clubs),
          Card(value: CardValue.joker),
        ]),
        returnsNormally,
      );
    });

    test('Rechaza el grupo si alguna carta es natural', ()
    {
      final wildMeld = Meld(
        baseValue: CardValue.joker,
        cards: [
          Card(value: CardValue.joker),
          Card(value: CardValue.joker),
          Card(value: CardValue.joker),
        ],
      );

      expect(
        () => MeldRules.validateCardsToAddToMeld(wildMeld, [
          Card(value: CardValue.two, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.spades), // natural, no debería colarse
        ]),
        throwsException,
      );
    });
    test('Permite añadir varias cartas naturales válidas', () 
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
        ],
      );

      expect(
        () => MeldRules.validateCardsToAddToMeld(meld, [
          Card(value: CardValue.seven, suit: CardSuit.diamonds),
        ]),
        returnsNormally,
      );
    });

    test('Rechaza varios comodines de golpe si rompen el ratio, aunque de uno en uno pareciera válido', () 
    {
      // 3 naturales + 1 comodín ya en la canasta (ratio 1 < 3, válido)
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
          Card(value: CardValue.two, suit: CardSuit.diamonds), // comodín
        ],
      );

      // Añadir 2 comodines más de golpe dejaría wildCards=3, naturalCards=3 -> inválido (3 >= 3)
      expect(
        () => MeldRules.validateCardsToAddToMeld(meld, [
          Card(value: CardValue.joker),
          Card(value: CardValue.joker),
        ]),
        throwsException,
      );
    });

    test('Rechaza si alguna carta del grupo no es del valor de la canasta', ()
    {
      final meld = Meld(
        baseValue: CardValue.seven,
        cards: [
          Card(value: CardValue.seven, suit: CardSuit.hearts),
          Card(value: CardValue.seven, suit: CardSuit.clubs),
          Card(value: CardValue.seven, suit: CardSuit.spades),
        ],
      );

      expect(
        () => MeldRules.validateCardsToAddToMeld(meld, [
          Card(value: CardValue.seven, suit: CardSuit.diamonds),
          Card(value: CardValue.eight, suit: CardSuit.hearts),
        ]),
        throwsException,
      );
    });
  });
}