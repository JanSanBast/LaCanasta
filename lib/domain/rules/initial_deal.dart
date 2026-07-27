// Class InitialDeal: Clase encargada de generar el repartimiento de cartas al iniciar una ronda

import 'dart:math';

import 'package:canasta_app/domain/models/board.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/domain/models/player.dart';

class InitialDeal
{
  static const int _minRoundSize = 1; 
  static const int _maxRoundSize = 3; // Las cartas se pueden repartir en bloques de 1, 2 o 3 cartas

  static void dealInitialHands(List<Player> players, Board board, {required int handSize, Random? random})
  {
    final rng = random ?? Random(); // Para debugar en los tests, se escoge una semilla random concreta. En ejecución real, se crea una nueva instáncia de Random.
    
    int dealt = 0;

    while (dealt < handSize)
    {
      final remaining = handSize - dealt;
      final cardsThisRound = _nextRoundSize(rng, remaining);

      for (final player in players)
      {
        player.addCards(_drawCardsFromDeck(board, cardsThisRound));
      }

      dealt += cardsThisRound;
    }
  }
  
  static int _nextRoundSize(Random rng, int remaining)
  {
    final maxThisRound = min(_maxRoundSize, remaining);

    return _minRoundSize + rng.nextInt(maxThisRound - _minRoundSize + 1);
  }

  static List<Card> _drawCardsFromDeck(Board board, int count)
  {
    return List.generate(count, (_) => board.drawFromDeck());
  }

  
} 