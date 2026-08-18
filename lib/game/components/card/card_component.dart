import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_sprite_resolver.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';

class CardComponent extends SpriteComponent with TapCallbacks
{
  final Card card;

  static const double cardWidth = 66; // Pixels del sprite original: 47

  static const double cardHeight = 88; // Pixels del sprite original: 63

  bool interactive = false; // Por defecto las cartas no son interactivas. Solo lo serán las cartas de la mano del jugador

  bool selected = false;

  RectangleComponent? _selectionHighlight;

  void Function(CardComponent card)? onCardTapped;

  CardComponent({required this.card})
    : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.center);

  @override
  Future<void> onLoad() async
  {
    sprite = await Sprite.load(CardSpriteResolver.pathFor(card));
  }

  @override
  void setOpacity(double opacity, {Object? paintId})
  {
    super.setOpacity(opacity);
    _selectionHighlight?.setOpacity(opacity);
  }

  @override
  void onTapDown(TapDownEvent event)
  {
    if (!interactive) return;
    onCardTapped?.call(this);
  }

  void setSelected(bool value)
  {
    if (selected == value) return;
    selected = value;

    if (selected)
    {
      _selectionHighlight ??= RectangleComponent(
        size: size + Vector2.all(6),
        position: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0x664FC3F7),
        priority: -1
      );

      add(_selectionHighlight!);
    } else {
      _selectionHighlight?.removeFromParent();
      _selectionHighlight = null;
    }
  }
}