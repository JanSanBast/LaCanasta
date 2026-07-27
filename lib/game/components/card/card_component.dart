import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_sprite_resolver.dart';
import 'package:flame/components.dart';

class CardComponent extends SpriteComponent
{
  final Card card;

  static const double cardWidth = 40.3; // Pixels del sprite original: 47

  static const double cardHeight = 54; // Pixels del sprite original: 63

  CardComponent({required this.card})
    : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.center);

  @override
  Future<void> onLoad() async
  {
    sprite = await Sprite.load(CardSpriteResolver.pathFor(card));
  }
}