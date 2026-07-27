import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FlyingCardComponent extends CardComponent
{
  final Vector2 targetPosition;

  final VoidCallback onComplete;

  FlyingCardComponent({
    required super.card,
    required Vector2 startPosition,
    required this.targetPosition,
    required this.onComplete,
  }) {
    position = startPosition;
  }

  @override
  Future<void> onLoad() async
  {
    await super.onLoad();

    add(
      MoveToEffect(targetPosition,
       EffectController( duration: 0.4, curve: Curves.easeOutCubic),
       onComplete: () {
        onComplete();
        removeFromParent();
       })
    );

    add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(duration: 0.2, reverseDuration: 0.2))
    );

    add(
      RotateEffect.to(
        0.1,
        EffectController(duration: 0.4))
    );
  }
}