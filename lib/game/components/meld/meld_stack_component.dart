import 'dart:math' as math;

import 'package:canasta_app/domain/models/meld.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';

class MeldStackComponent extends PositionComponent
{
  final Meld meld;

  final double maxStackHeight;

  final double naturalStep;

  final double cardScale;

  MeldStackComponent({required this.meld, required this.maxStackHeight, required this.naturalStep, required this.cardScale});


  @override
  Future<void> onLoad() async
  {
    final cards = meld.cards;
    final n = cards.length;

    final step = n <= 1 ? 0.0 : math.min(naturalStep, maxStackHeight / (n - 1));

    for (int i = 0; i < n; ++i)
    {
      final cardComponent = CardComponent(card: cards[i])
            ..scale = Vector2.all(cardScale)
            ..anchor = Anchor.bottomCenter
            ..position = Vector2(0, -i * step)
            ..priority = i;

      add(cardComponent);
    }
  }
}