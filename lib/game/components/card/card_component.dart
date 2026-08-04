import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_sprite_resolver.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';

class CardComponent extends SpriteComponent with DragCallbacks, TapCallbacks
{
  final Card card;

  static const double cardWidth = 47; // Pixels del sprite original: 47

  static const double cardHeight = 63; // Pixels del sprite original: 63

  bool draggable = false; // Por defecto las cartas no son arrastrables. Solo lo serán las cartas de la mano del jugador

  bool selected = false;

  bool _isDragging = false;

  RectangleComponent? _selectionHighlight;

  void Function(CardComponent card)? onCardDropped;

  void Function(CardComponent card)? onDragStarted;

  void Function(CardComponent card)? onDragUpdated;

  void Function(CardComponent card)? onCardTapped;

  CardComponent({required this.card})
    : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.center);

  @override
  Future<void> onLoad() async
  {
    sprite = await Sprite.load(CardSpriteResolver.pathFor(card));
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

  @override
  void onTapDown(TapDownEvent event)
  {
    if (!draggable) return;

    onCardTapped?.call(this);
  }

  @override
  void onDragStart(DragStartEvent event)
  {
    if (!draggable) return;

    super.onDragStart(event);

    _isDragging = true;
    priority = 1000; // Esto hará que se pinte la carta que se esta desplazando por encima de las demás
    onDragStarted?.call(this);
  }

  @override
  void onDragUpdate(DragUpdateEvent event)
  {
    if (!_isDragging) return;

    position += event.localDelta;
    onDragUpdated?.call(this);
  }

  @override
  void onDragEnd(DragEndEvent event)
  {
    super.onDragEnd(event);

    if (!_isDragging) return;

    _isDragging = false;
    onCardDropped?.call(this);
  }
}