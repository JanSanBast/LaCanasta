
import 'dart:math';

import 'package:canasta_app/domain/engine/game_engine.dart';
import 'package:canasta_app/domain/enums/enums.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/animations/flying_card_component.dart';
import 'package:canasta_app/game/components/background/background_component.dart';
import 'package:canasta_app/game/components/board_elements/deck_component.dart';
import 'package:canasta_app/game/components/board_elements/discard_pile_component.dart';
import 'package:canasta_app/game/components/board_elements/hand_component.dart';
import 'package:canasta_app/game/components/background/table_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CanastaGame extends FlameGame 
{
  static final screenSize = Vector2(600, 400);

  late HandComponent handComponent;

  late DeckComponent deckComponent;

  CanastaGame() : super(
    camera: CameraComponent.withFixedResolution(
      width: screenSize.x,
      height: screenSize.y
    ),
  );

  late final GameEngine gameEngine;

  List<String> deck = [];

  List<String> playerHand = [];
  
  @override
  Future<void> onLoad() async
  {
    camera.moveTo(screenSize / 2);
    await images.loadAllImages();

    world.add(BackgroundComponent(screenSize: screenSize));
    world.add(TableComponent(screenSize: screenSize));

    deckComponent = DeckComponent(position: Vector2(screenSize.x / 2 + 35, screenSize.y / 2),);
    world.add(deckComponent);

    world.add(DiscardPileComponent(cards: _generateCards(), position: Vector2(screenSize.x / 2 - 35, screenSize.y / 2),));

    handComponent = HandComponent(anchorPosition: Vector2(screenSize.x / 2, screenSize.y - 35),);
    world.add(handComponent);

    gameEngine = GameEngine.newGame(['Jugador 1'], handSize: 11); // Cambiar el 11 por una variable según el número de cartas que requiera el modo

    handComponent.setHand(gameEngine.state.players.first.hand);
  }

  List<Card> _generateCards()
  {
    final random = Random();
    
    return List.generate(8, (index)
    {
      final value = CardValue.values[random.nextInt(CardValue.values.length)];
      final suit = value != CardValue.joker ? CardSuit.values[random.nextInt(CardSuit.values.length)] : null;

      return Card(value: value, suit: suit);
    });
  }

  void onDeckTapped()
  {
    final card = gameEngine.state.board.deckPeekCard;

    final start = deckComponent.position;
    final end = handComponent.getNextCardPosition();

    world.add(
      FlyingCardComponent(card: card, startPosition: start, targetPosition: end,
       onComplete: () {
        gameEngine.drawFromDeck();

        handComponent.setHand(
          gameEngine.state.currentPlayer.hand,
        );
       }
      )
    );
  }
}