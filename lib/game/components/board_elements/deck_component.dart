import 'package:canasta_app/game/canasta_game.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class DeckComponent extends PositionComponent with HasGameReference<CanastaGame>, TapCallbacks
{
  final int stackSize;

  final Vector2 cardSize;

  DeckComponent({
    this.stackSize = 6,
    Vector2? cardSize,
    super.position,
    super.anchor = Anchor.center,
  }) : cardSize = cardSize ?? Vector2(CardComponent.cardWidth, CardComponent.cardHeight)
  {
    size = this.cardSize;
  }
  
  @override
  Future<void> onLoad() async
  {
    final sprite = await Sprite.load('cards/backs/card_back_6.png');

    for (int i = 0; i < stackSize; ++i)
    {
      final card = SpriteComponent()
        ..sprite = sprite
        ..size = cardSize
        ..anchor = Anchor.center
        ..position = size / 2 - Vector2(i * 1.0, i * 1.0);

      add(card);
    }
  }

  @override
  void onTapDown(TapDownEvent event)
  {
    game.onDeckTapped();
  }
}