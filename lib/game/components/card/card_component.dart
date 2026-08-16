import 'dart:async' as async;

import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_sprite_resolver.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';

class CardComponent extends SpriteComponent with DragCallbacks, TapCallbacks
{
  final Card card;

  static const double cardWidth = 66; // Pixels del sprite original: 47

  static const double cardHeight = 88; // Pixels del sprite original: 63

  static const Duration _tapConfirmDelay = Duration(milliseconds: 70);

  bool draggable = false; // Por defecto las cartas no son arrastrables. Solo lo serán las cartas de la mano del jugador

  bool selected = false;

  int _originalPriority = 0;

  async.Timer? _tapConfirmTimer;

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

  @override
  void onRemove()
  {
    _tapConfirmTimer?.cancel();
    _tapConfirmTimer = null;
    super.onRemove();
  }

  @override
  void setOpacity(double opacity, {Object? paintId})
  {
    super.setOpacity(opacity);
    _selectionHighlight?.setOpacity(opacity);
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

    _tapConfirmTimer?.cancel();
    _tapConfirmTimer = async.Timer(_tapConfirmDelay, _confirmTap);
  }

  void _confirmTap()
  {
    _tapConfirmTimer = null;
    if (!isMounted) return;
    if (isDragged) return;

    onCardTapped?.call(this);
  }

  @override
  void onDragStart(DragStartEvent event)
  {
    if (!draggable) return;

    _tapConfirmTimer?.cancel();
    _tapConfirmTimer = null;

    super.onDragStart(event);

    _originalPriority = priority;
    priority = 1000;

    onDragStarted?.call(this);
  }

  @override
  void onDragUpdate(DragUpdateEvent event)
  {
    position += event.localDelta;
    onDragUpdated?.call(this);
  }

  @override
  void onDragEnd(DragEndEvent event)
  {
    super.onDragEnd(event);
    onCardDropped?.call(this);
  }

  @override
  void onDragCancel(DragCancelEvent event)
  {
    super.onDragCancel(event);

    priority = _originalPriority;
    onCardDropped?.call(this);
  }
}