import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class HandComponent extends PositionComponent
{
  static const double _cardSpacing = 22;

  final Vector2 anchorPosition;

  final List<CardComponent> _cardComponents = [];

  HandComponent({required this.anchorPosition});

  void setHand(List<Card> cards)
  {
    _cardComponents.removeWhere((component)
    {
      final stillInHand = cards.any((card) => card == component.card);
      if (!stillInHand) component.removeFromParent();
      return !stillInHand;
    });

    for (final card in cards) 
    {
      final alreadyShown = _cardComponents.any((component) => component.card == card);
      if (!alreadyShown)
      {
        final cardComponent = CardComponent(card: card)..position = anchorPosition.clone();
        _cardComponents.add(cardComponent);
        add(cardComponent);
      }
    }
    _layout();
  }

  void _layout()
  {
    final count = _cardComponents.length;
    if (count == 0) return;

    final totalWidth = (count - 1) * _cardSpacing + CardComponent.cardWidth;
    final startX = anchorPosition.x - totalWidth / 2 + CardComponent.cardWidth / 2;

    for (int i = 0; i < count; ++i)
    {
      final targetPosition = Vector2(startX + i * _cardSpacing, anchorPosition.y);

      _cardComponents[i].children.whereType<MoveToEffect>().toList().forEach((effect) => effect.removeFromParent());
      _cardComponents[i].add(MoveToEffect(targetPosition, EffectController(duration: 0.25)));
    }
  }
}