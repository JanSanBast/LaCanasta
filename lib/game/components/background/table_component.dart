import 'package:flame/components.dart';

class TableComponent extends SpriteComponent
{
  final Vector2 _screenSize;

  TableComponent({required this._screenSize});

  @override
  Future<void> onLoad() async
  {
    sprite = await Sprite.load('tables/table_green.png');
    size = Vector2(_screenSize.x - 50, _screenSize.y - 50);
    position = _screenSize / 2;
    anchor = Anchor.center;
  }
}