import 'package:flame/components.dart';

class BackgroundComponent extends SpriteComponent
{
  final Vector2 _screenSize;

  BackgroundComponent({required this._screenSize});

  @override
  Future<void> onLoad() async
  {
    sprite = await Sprite.load('backgrounds/background_4.png');
    size = _screenSize;
  }
}