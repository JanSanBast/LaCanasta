
import 'package:canasta_app/domain/engine/game_engine.dart';
import 'package:canasta_app/game/components/background_component.dart';
import 'package:canasta_app/game/components/deck_component.dart';
import 'package:canasta_app/game/components/hand_component.dart';
import 'package:canasta_app/game/components/table_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class LaCanastaGame extends FlameGame
{
  static final screenSize = Vector2(600, 400);

  LaCanastaGame() : super(
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
    world.add(DeckComponent(position: Vector2(screenSize.x / 2 + 50, screenSize.y / 2),));

    gameEngine = GameEngine.newGame(['Jugador 1'], handSize: 11); // Cambiar el 11 por una variable según el número de cartas que requiera el modo

    final playerHand = HandComponent(anchorPosition: Vector2(screenSize.x / 2, screenSize.y - 35),);

    world.add(playerHand);
    playerHand.setHand(gameEngine.state.players.first.hand);
  }
}