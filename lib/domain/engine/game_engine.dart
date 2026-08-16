import 'package:canasta_app/domain/enums/enums.dart';
import 'package:canasta_app/domain/models/board.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/domain/models/player.dart';
import 'package:canasta_app/domain/rules/deck_factory.dart';
import 'package:canasta_app/domain/rules/game_rules.dart';
import 'package:canasta_app/domain/rules/initial_deal.dart';
import 'package:canasta_app/domain/rules/meld_rules.dart';
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

  Card startDiscardPile()
  {
    final card = state.board.drawFromDeck();
    state.board.discardCard(card);
    return card;
  }

  void drawFromDeck()
  {
    final card = state.board.drawFromDeck();
    state.currentPlayer.addCard(card);
  }

  void discardCard(Card card)
  {
    state.currentPlayer.removeCard(card);
    state.board.discardCard(card);
  }

  void reorderHandCard(Card card, int newIndex)
  {
    state.currentPlayer.moveCard(card, newIndex);
  }

  void openMeld(List<Card> cards)
  {
    final baseValue = MeldRules.validateNewMeldCards(cards);
    final isFirstMeldOfRound = state.board.meldsFor(state.currentPlayer.id).isEmpty;

    if (isFirstMeldOfRound)
    {
      final score = cards.fold<int>(0, (sum, card) => sum + card.score);
      if (score < GameRules.minScoreToOpenFirstMeld) throw Exception('Puntuación insuficiente para jugar la primera canasta');
    }

    _ensurePlayerHasCards(cards);

    state.currentPlayer.removeCards(cards);
    state.board.openMeld(ownerId: state.currentPlayer.id, baseValue: baseValue, cards: cards);
  }

  void addCardsToMeld(CardValue value, List<Card> cards)
  {
    final meld = state.board.findMeldByIdValue(state.currentPlayer.id, value);
    if (meld == null) throw Exception('No existe una canasta abierta con valor ${value.name} para este jugador');

    _ensurePlayerHasCards(cards);

    MeldRules.validateCardsToAddToMeld(meld, cards);
    meld.addCards(cards);
    state.currentPlayer.removeCards(cards);
  }

  void _ensurePlayerHasCards(List<Card> cards)
  {
    for (final card in cards)
    {
      if (!state.currentPlayer.hasCard(card)) throw Exception('La carta: ${card.id} no está en la mano del jugador');
    }
  }
}