import 'package:flame/components.dart';

class DeckComponent extends PositionComponent
{
  final int stackSize;

  final Vector2 cardSize;

  DeckComponent({
    this.stackSize = 6,
    Vector2? cardSize,
    super.position,
    super.anchor = Anchor.center,
  }) : cardSize = cardSize ?? Vector2(40.3, 54);
  
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
        ..position = Vector2(-i * 1.0, -i * 1.0);

      add(card);
    }
  }
}