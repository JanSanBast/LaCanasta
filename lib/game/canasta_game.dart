
import 'package:canasta_app/domain/engine/game_engine.dart';
import 'package:canasta_app/game/animations/flying_card_component.dart';
import 'package:canasta_app/game/components/background/background_component.dart';
import 'package:canasta_app/game/components/board_elements/deck_component.dart';
import 'package:canasta_app/game/components/board_elements/discard_pile_component.dart';
import 'package:canasta_app/game/components/board_elements/hand_component.dart';
import 'package:canasta_app/game/components/background/table_component.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CanastaGame extends FlameGame 
{
  static final screenSize = Vector2(600, 400);

  late HandComponent handComponent;

  late DeckComponent deckComponent;

  late DiscardPileComponent discardPileComponent;

  late final GameEngine gameEngine;

  CanastaGame() : super(
    camera: CameraComponent.withFixedResolution(
      width: screenSize.x,
      height: screenSize.y
    ),
  );


  @override
  Future<void> onLoad() async
  {
    camera.moveTo(screenSize / 2);
    await images.loadAllImages();

    world.add(BackgroundComponent(screenSize: screenSize));
    world.add(TableComponent(screenSize: screenSize));

    gameEngine = GameEngine.newGame(['Jugador 1'], handSize: 11); // Cambiar el 11 por una variable según el número de cartas que requiera el modo

    deckComponent = DeckComponent(position: Vector2(screenSize.x / 2 + 35, screenSize.y / 2),)..priority = 1;
    world.add(deckComponent);

    handComponent = HandComponent(anchorPosition: Vector2(screenSize.x / 2, screenSize.y - 35),)..priority = 2..onCardDropped = _onHandCardDropped; // Con la priority = 2 nos aseguramos que las cartas de la mano se vean por encima de las de deck y discardPile
    world.add(handComponent);

    discardPileComponent = DiscardPileComponent(position: Vector2(screenSize.x / 2 - 35, screenSize.y / 2),)..priority = 1;
    world.add(discardPileComponent);

    handComponent.setHand(gameEngine.state.players.first.hand);
    _startInitialDiscard();
  }

  void _startInitialDiscard()
  {
    final card = gameEngine.state.board.deckPeekCard;

    final start = deckComponent.position;
    final end = discardPileComponent.position;

    world.add(
      FlyingCardComponent(card: card, startPosition: start, targetPosition: end,
        onComplete: () {
          gameEngine.startDiscardPile();
          discardPileComponent.addCard(card);
        }));
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

  void _onHandCardDropped(CardComponent cardComponent)
  {
    final droppedOnDiscardPile = world.componentsAtPoint(cardComponent.absoluteCenter).whereType<DiscardPileComponent>().isNotEmpty;

    if (droppedOnDiscardPile)
    {
      gameEngine.discardCard(cardComponent.card);

      cardComponent.removeFromParent();
      discardPileComponent.addCard(cardComponent.card);

      handComponent.setHand(gameEngine.state.currentPlayer.hand);

      print('Monton: ${gameEngine.state.board.discardPile}');
    } else
    {
      handComponent.returnCardToHand();
    }
  }
}