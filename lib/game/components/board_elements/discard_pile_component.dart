import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';

class DiscardPileComponent extends PositionComponent
{
  final List<Card> _cards;

  final List<CardComponent> _visibleComponents = [];

  static const _maxVisibleCards = 4;

  int _nextPriority = 0;

  DiscardPileComponent({
    List<Card>? cards,
    super.position,
    super.anchor = Anchor.center,
  }) : _cards = cards != null ? List.of(cards) : []
  {
    size = Vector2(CardComponent.cardWidth, CardComponent.cardHeight);
  }


  List<Card> get cards => List.unmodifiable(_cards);

  bool get isEmpty => _cards.isEmpty;

  /*void addCard(Card card)
  {
    _cards.add(card);
    _render();
  }*/

  void addCard(Card card)
  {
    _cards.add(card);
    _addVisibleComponent(card);
    _layout();
  }

  @override
  Future<void> onLoad() async
  {
    for (final card in _cards)
    {
      _addVisibleComponent(card);
    }

    _layout();
  }

  void _addVisibleComponent(Card card)
  {
    final component = CardComponent(card: card)
        ..position = size / 2
        ..priority = _nextPriority++;

    _visibleComponents.add(component);
    add(component);

    if (_visibleComponents.length > _maxVisibleCards)
    {
      _visibleComponents.removeAt(0).removeFromParent();
    }
  }

  void _layout()
  {
    final n = _visibleComponents.length;

    for (int i = 0; i < n; ++i)
    {
      final depth = n - 1 - i;
      final offset = _depthOffsetMagnitude(depth); // Creamos el efecto de profundidad en función del número de cartas que haya
      _visibleComponents[i].position = size / 2 + Vector2(offset, offset);
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
}