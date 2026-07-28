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

  HandComponent({required this.anchorPosition});


  void setHand(List<Card> newHand)
  {
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
      component.onDragStarted = _onCardDragStarted;

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

  void _onCardDragStarted(CardComponent draggedCard)
  {
    final remaining = _cardComponents.where((c) => c != draggedCard).toList();

    for (int i = 0; i < remaining.length; ++i)
    {
      final targetPosition = _calculateCardPosition(i, remaining.length);

      remaining[i].add(
        MoveToEffect(targetPosition, EffectController(duration: 0.2))
      );
    }
  }
}