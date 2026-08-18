
import 'package:canasta_app/domain/engine/game_engine.dart';
import 'package:canasta_app/game/animations/flying_card_component.dart';
import 'package:canasta_app/game/components/background/background_component.dart';
import 'package:canasta_app/game/components/board_elements/deck_component.dart';
import 'package:canasta_app/game/components/board_elements/discard_pile_component.dart';
import 'package:canasta_app/game/components/board_elements/hand_component.dart';
import 'package:canasta_app/game/components/board_elements/meld_zone_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CanastaGame extends FlameGame 
{
  static final screenSize = Vector2(540, 960);

  late HandComponent handComponent;

  late DeckComponent deckComponent;

  late DiscardPileComponent discardPileComponent;

  late MeldZoneComponent playerMeldZone;

  late MeldZoneComponent opponentMeldZone;

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

    gameEngine = GameEngine.newGame(['Jugador 1'], handSize: 11); // Cambiar el 11 por una variable según el número de cartas que requiera el modo

    final tableCenter = screenSize / 2;

    deckComponent = DeckComponent(position: Vector2(tableCenter.x - 50, tableCenter.y),)..priority = 1;
    world.add(deckComponent);

    discardPileComponent = DiscardPileComponent(position: Vector2(screenSize.x / 2 + 50, screenSize.y / 2),)..priority = 1;
    world.add(discardPileComponent);

    handComponent = HandComponent(anchorPosition: Vector2(screenSize.x / 2, screenSize.y - 55),)..priority = 2; // Con la priority = 2 nos aseguramos que las cartas de la mano se vean por encima de las de deck y discardPile
    world.add(handComponent);

    handComponent.setHand(gameEngine.state.players.first.hand);
    _startInitialDiscard();

    final zoneSize = Vector2(480, 280);

    playerMeldZone = MeldZoneComponent(zoneSize: zoneSize, interactive: true, position: Vector2(screenSize.x / 2, 692));
    world.add(playerMeldZone);

    opponentMeldZone = MeldZoneComponent(zoneSize: zoneSize, interactive: false, position: Vector2(screenSize.x / 2, 160));
    world.add(opponentMeldZone);
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
}