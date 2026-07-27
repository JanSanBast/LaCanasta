import 'package:canasta_app/domain/models/board.dart';
import 'package:canasta_app/domain/models/player.dart';

class GameState
{
  final List<Player> players;

  final Board board;

  int currentPlayerIndex;

  GameState({
    required this.players,
    required this.board,
    this.currentPlayerIndex = 0,
  });

  Player get currentPlayer => players[currentPlayerIndex];
}