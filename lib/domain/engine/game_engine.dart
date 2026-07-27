import 'package:canasta_app/domain/models/board.dart';
import 'package:canasta_app/domain/models/player.dart';
import 'package:canasta_app/domain/rules/deck_factory.dart';
import 'package:canasta_app/domain/rules/initial_deal.dart';
import 'package:canasta_app/domain/state/game_state.dart';

// Class GameEngine: Clase encargada del motor del juego

class GameEngine 
{
  final GameState state;

  GameEngine({required this.state});

  factory GameEngine.newGame(List<String> playerNames, {required int handSize})
  {
    final board = Board()
        ..addCardsToDeck(DeckFactory.createCanastaDeck())
        ..shuffleDeck();

    final players = playerNames.map((name) => Player(name: name)).toList();

    final engine = GameEngine(state: GameState(players: players, board: board));
    
    engine._startRound(handSize);

    return engine;
  }

  void _startRound(int handSize)
  {
    InitialDeal.dealInitialHands(state.players, state.board, handSize: handSize);
  }

  void drawFromDeck()
  {
    final card = state.board.drawFromDeck();
    state.currentPlayer.addCard(card);
  }
}