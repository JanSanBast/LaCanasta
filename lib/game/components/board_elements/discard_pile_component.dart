import 'dart:math';

import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';

class DiscardPileComponent extends PositionComponent
{
  final List<Card> cards;

  DiscardPileComponent({
    required this.cards,
    super.position,
    super.anchor = Anchor.center,
  });

  @override
  Future<void> onLoad() async
  {
    final visible = min(cards.length, 5);

    for (int i = 0; i < visible; ++i) 
    {
      final card = cards[cards.length - 1 - i];

      final component = CardComponent(card: card)
        ..position = Vector2(i * 0.5, -i * 0.5)
        ..priority = i;

      add(component);
    }
  }
}