import 'dart:math' as math;

import 'package:canasta_app/domain/models/meld.dart';
import 'package:canasta_app/domain/rules/game_rules.dart';
import 'package:canasta_app/game/components/meld/meld_stack_component.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';

class MeldZoneComponent extends PositionComponent
{
  static const Color _borderColor = Color(0xFF9E9E9E);

  static const double _borderWidth = 2;

  static const double _scoreGapWidth = 64;

  static const double _scoreGapHeight = 26;

  static const double _scoreReserve = 34;

  static const double _padding = 14;

  static const double _naturalMeldSpacing = 76;

  static const double _naturalCardStep = 9;

  static const double _cardScale = 0.55;

  final bool interactive;

  int requiredScore;

  int currentScore = 0;

  bool hasOpenedMeld = false;

  List<MeldStackComponent> _meldStacks = [];

  MeldZoneComponent({required Vector2 zoneSize, required this.interactive, this.requiredScore = GameRules.minScoreToOpenFirstMeld, super.position, super.anchor = Anchor.center})
  {
    size = zoneSize;
  }

  @override
  void render(Canvas canvas)
  {
    super.render(canvas);
    _renderBorder(canvas);
    _renderScoreCorner(canvas);
  }

  void setMelds(List<Meld> melds)
  {
    for (final stack in _meldStacks) { stack.removeFromParent(); }
    _meldStacks.clear();

    final contentWidth = size.x - _padding * 2;
    final contentHeight = size.y - _padding - _scoreReserve;

    final n = melds.length;
    final horizontalSpacing = n <= 1 ? 0.0 : math.min(_naturalMeldSpacing, contentWidth / (n - 1));

    final baseline = size.y - _scoreReserve;

    for (int i = 0; i < n; ++i)
    {
      final x = _padding + i * horizontalSpacing;
      final stack = MeldStackComponent(
        meld: melds[i],
        maxStackHeight: contentHeight,
        naturalStep: _naturalCardStep,
        cardScale: _cardScale
      )
      ..position = Vector2(x, baseline)
      ..anchor = Anchor.bottomCenter;

      add(stack);
      _meldStacks.add(stack);
    }

    currentScore = melds.fold<int>(0, (sum, meld) => sum + meld.cards.fold<int>(0, (s, c) => s + c.score));
    hasOpenedMeld = melds.isNotEmpty;
  }

  void _renderBorder(Canvas canvas)
  {
    final paint = Paint()
                  ..color = _borderColor
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = _borderWidth;
    
    final w = size.x;
    final h = size.y;

    canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, h - _scoreGapHeight), paint);
    canvas.drawLine(Offset(0, h), Offset(w - _scoreGapWidth, h), paint);
  }

  void _renderScoreCorner(Canvas canvas)
  {
    final text = hasOpenedMeld ? '$currentScore' : '$currentScore / $requiredScore';

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr
    )..layout();

    final position = Offset(size.x - textPainter.width - 10, size.y - textPainter.height);
    textPainter.paint(canvas, position);
  }
}
