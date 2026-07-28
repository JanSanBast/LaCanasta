import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class HandComponent extends PositionComponent
{
  static const double _cardSpacing = 22;

  final Vector2 anchorPosition;

  List<CardComponent> _cardComponents = [];

  void Function(CardComponent card)? onCardDropped;

  int? _dragTargetIndex;

  HandComponent({required this.anchorPosition});


  void setHand(List<Card> newHand)
  {
    _dragTargetIndex = null;

    final Map<Card, CardComponent> existing = {
      for (CardComponent cardComponent in _cardComponents) cardComponent.card: cardComponent
    };

    final List<CardComponent> newComponents = [];

    for (int i = 0; i < newHand.length; ++i)
    {
      final card = newHand[i];

      final targetPosition = _calculateCardPosition(i, newHand.length);

      CardComponent component;

      if (existing.containsKey(card))
      {
        component = existing[card]!;

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
      component.onCardDropped = onCardDropped;
      component.onDragStarted = _updateDragPreview;
      component.onDragUpdated = _updateDragPreview;

      newComponents.add(component);
    }

    _cardComponents = newComponents;
  }

  Vector2 getNextCardPosition()
  {
    final index = _cardComponents.length;

    final startX = anchorPosition.x - (index * _cardSpacing) / 2;

    return Vector2(
      startX + index * _cardSpacing,
      anchorPosition.y
    );
  }
  
  Vector2 _calculateCardPosition(int index, int length)
  {
    final totalWidth = (length - 1) * _cardSpacing;

    final startX = anchorPosition.x - (totalWidth / 2);

    final x = startX + index * _cardSpacing;

    return Vector2(x, anchorPosition.y);
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

  void _updateDragPreview(CardComponent draggedCard)
  {
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
      final targetPosition = _calculateCardPosition(slot, totalSlots);

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
      final targetPosition = _calculateCardPosition(i, remaining.length);
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