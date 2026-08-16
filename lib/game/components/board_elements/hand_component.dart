import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Card;

class HandComponent extends PositionComponent
{
  static const double _cardSpacing = 31;

  static const double _selectionLift = 20;

  static const int _maxVisibleFollowers = 3;

  final Vector2 anchorPosition;

  List<CardComponent> _cardComponents = [];

  void Function(CardComponent card)? onCardDropped;

  int? _dragTargetIndex;

  CardComponent? _dragLeader;

  List<CardComponent> _dragGroup = [];

  _DragCountBadge? _dragCountBadge;

  HandComponent({required this.anchorPosition});


  void setHand(List<Card> newHand)
  {
    _dragTargetIndex = null;
    _clearDragState();

    final Map<Card, CardComponent> existing = {
      for (CardComponent cardComponent in _cardComponents) cardComponent.card: cardComponent
    };

    final List<CardComponent> newComponents = [];

    for (int i = 0; i < newHand.length; ++i)
    {
      final card = newHand[i];
      final existingComponent = existing[card];
      final isSelected = existingComponent?.selected ?? false;

      final targetPosition = _calculateCardPosition(i, newHand.length, selected: isSelected);

      CardComponent component;

      if (existingComponent != null)
      {
        component = existingComponent;

        component.add(
          MoveToEffect(targetPosition,
          EffectController(duration: 0.3))
        );
      } else {
        component = CardComponent(card: card)..position = targetPosition;

        add(component);
      }

      component.draggable = true; // Indicamos que las cartas de la mano del jugador son arrastrables
      component.priority = i; // Mantiene el orden de pintado de las cartas (izquierda --> mas abajo, derecha --> mas arriba)
      component.onCardDropped = _handleCardDropped;
      component.onDragStarted = _handleDragStarted;
      component.onDragUpdated = _handleDragUpdated;
      component.onCardTapped = _handleCardTapped;

      newComponents.add(component);
    }

    _cardComponents = newComponents;
  }

  List<CardComponent> get selectedCards => _cardComponents.where((c) => c.selected).toList();

  List<CardComponent> get draggingGroup => List.unmodifiable(_dragGroup);

  Vector2 getNextCardPosition()
  {
    final index = _cardComponents.length;

    final startX = anchorPosition.x - (index * _cardSpacing) / 2;

    return Vector2(
      startX + index * _cardSpacing,
      anchorPosition.y
    );
  }
  
  Vector2 _calculateCardPosition(int index, int length, {bool selected = false})
  {
    final totalWidth = (length - 1) * _cardSpacing;

    final startX = anchorPosition.x - (totalWidth / 2);

    final x = startX + index * _cardSpacing;
    final y = anchorPosition.y - (selected ? _selectionLift : 0);

    return Vector2(x, y);
  }

  void returnCardToHand()
  {
    for (int i = 0; i < _cardComponents.length; ++i)
    {
      final component = _cardComponents[i];
      final targetPosition = _calculateCardPosition(i, _cardComponents.length);

      component.priority = i;
      component.add(
        MoveToEffect(targetPosition, EffectController(duration: 0.25))
      );
    }
  }

  void _handleCardTapped(CardComponent card)
  {
    card.setSelected(!card.selected);
    card.priority = _cardComponents.indexOf(card);
    _repositionCards();
  }

  void _repositionCards()
  {
    for (int i = 0; i < _cardComponents.length; ++i)
    {
      final component = _cardComponents[i];
      final targetPosition = _calculateCardPosition(i, _cardComponents.length, selected: component.selected);

      component.add(
        MoveToEffect(targetPosition, EffectController(duration: 0.15))
      );
    }
  }

  void _handleDragStarted(CardComponent leader)
  {
    _dragLeader = leader;

    final bool isMultiDrag = leader.selected && selectedCards.length > 1;
    _dragGroup = isMultiDrag ? selectedCards : [leader];

    if (isMultiDrag)
    {
      _layoutDragStack(leader);
      _attachDragCountBadge(leader, _dragGroup.length);
    }

    _updateDragPreview(leader);
  }

  void _handleDragUpdated(CardComponent leader)
  {
    if (leader != _dragLeader) return;

    _layoutDragStack(leader);
    _updateDragPreview(leader);
  }

  void _handleCardDropped(CardComponent leader)
  {
    final group = _dragGroup;
    _clearDragState();

    for (final card in group) { card.setSelected(false); }

    if (group.length > 1)
    {
      returnCardToHand();
      return;
    }

    onCardDropped?.call(leader);
  }

  void _layoutDragStack(CardComponent leader)
  {
    final followers = _dragGroup.where((c) => c != leader).toList();

    for (int i = 0; i < followers.length; ++i)
    {
      final follower = followers[i];
      final visible = i < _maxVisibleFollowers;

      follower.setOpacity(visible ? 1 : 0);
      if (!visible) continue;

      final depth = i + 1;
      final offset = _depthOffsetMagnitude(depth);

      follower.position = leader.position + Vector2(offset, offset);
      follower.priority = leader.priority - 1 - i; // Para que las cartas parezcan escaladas
    }
  }

  double _depthOffsetMagnitude(int depth)
  {
    const double step = 0.4;
    double offset = 0.0;
 
    for (int d = 1; d <= depth; ++d)
    {
      offset += step * d;
    }
 
    return offset;
  }

  void _clearDragState()
  {  
    _dragCountBadge?.removeFromParent();
    _dragCountBadge = null;

    for (final card in _dragGroup)
    {
      card.setOpacity(1);
    }

    _dragLeader = null;
    _dragGroup = [];
  }

  void _attachDragCountBadge(CardComponent card, int count)
  {
    _dragCountBadge?.removeFromParent();

    final badge = _DragCountBadge(count: count)
      ..position = Vector2(CardComponent.cardWidth, 0)
      ..priority = 1001;

    card.add(badge);
    _dragCountBadge = badge;
  }

  void _updateDragPreview(CardComponent draggedCard)
  {
    if (_dragGroup.length > 1) return;
    final remaining = _cardComponents.where((c) => c != draggedCard).toList();

    if (!isCardOverHand(draggedCard)) { _updateDragPreviewOutsideHand(draggedCard, remaining); }
    else { _updateDragPreviewInsideHand(draggedCard, remaining); }
  }

  void _updateDragPreviewInsideHand(CardComponent draggedCard, List<CardComponent> remaining)
  {
    final totalSlots = remaining.length + 1; // Añadimos el hueco donde quedaria la carta que arrastramos a la mano

    final targetIndex = _nearestSlot(draggedCard.position.x, totalSlots);

    if (targetIndex == _dragTargetIndex) return; // Si no ha cambiado respecto al update anterior, no se calcula la lógica

    _dragTargetIndex = targetIndex;

    for (int i = 0; i < remaining.length; ++i)
    {
      final slot = i < targetIndex ? i : i + 1;
      final targetPosition = _calculateCardPosition(slot, totalSlots, selected: remaining[i].selected);

      remaining[i].add(
        MoveToEffect(targetPosition, EffectController(duration: 0.2))
      );
    }
  }

  void _updateDragPreviewOutsideHand(CardComponent draggedCard, List<CardComponent> remaining)
  {
    if (_dragTargetIndex == null) return;

    _dragTargetIndex = null;

    for (int i = 0; i < remaining.length; ++i)
    {
      final targetPosition = _calculateCardPosition(i, remaining.length, selected: remaining[i].selected);
      remaining[i].add(
        MoveToEffect(targetPosition, EffectController(duration: 0.2))
      );
    }
  }

  int computeDropIndex(CardComponent draggedCard)
  {
    final remaining = _cardComponents.where((c) => c != draggedCard).toList();
    final totalSlots = remaining.length + 1;

    return _nearestSlot(draggedCard.position.x, totalSlots);
  }
  
  int _nearestSlot(double x, int totalSlots)
  {
    int bestSlot = 0;
    double bestDistance = double.infinity;

    for (int i = 0; i < totalSlots; ++i)
    {
      final distance = (_calculateCardPosition(i, totalSlots).x - x).abs();

      if (distance < bestDistance)
      {
        bestDistance = distance;
        bestSlot = i;
      }
    }

    return bestSlot;
  }  

  bool isCardOverHand(CardComponent card)
  {
    final double handAreaVerticalTolerance = CardComponent.cardHeight * 1.25;

    final verticalOk = (card.position.y - anchorPosition.y).abs() <= handAreaVerticalTolerance;
    if (!verticalOk) return false;

    final remainingCount = _cardComponents.where((c) => c != card).length;
    final totalSlots = remainingCount + 1;

    final totalWidth = (totalSlots - 1) * _cardSpacing;
    const horizontalMargin = CardComponent.cardWidth;

    final leftBound = anchorPosition.x - totalWidth / 2 - horizontalMargin;
    final rightBound = anchorPosition.x + totalWidth / 2 + horizontalMargin;

    return card.position.x >= leftBound && card.position.x <= rightBound;
  }
}

class _DragCountBadge extends PositionComponent
{
  final int count;

  _DragCountBadge({required this.count}) : super(size: Vector2.all(18), anchor: Anchor.center);

  @override
  Future<void> onLoad() async
  {
    add(CircleComponent(
      radius: 9,
      paint: Paint()..color = const Color(0xFFE53935),
      anchor: Anchor.center,
      position: size / 2,
    ));

    add(TextComponent(
      text: '$count',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }
}