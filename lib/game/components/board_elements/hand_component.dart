import 'package:canasta_app/domain/enums/enums.dart';
import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class HandComponent extends PositionComponent
{
  static const double _maxHandWidth = 440;

  static const double _stackStepCollapsed = 8;

  static const double _stackStepExpanded = 20;

  static final int _maxSlots = CardValue.values.length;

  final Vector2 anchorPosition;

  List<List<CardComponent>> _slots = [];

  HandComponent({required this.anchorPosition});


  void setHand(List<Card> newHand)
  {
    final Map<Card, CardComponent> existing = {
      for (final slot in _slots)
        for (final component in slot)
          component.card: component
    };

    final Map<CardValue, List<Card>> grouped = {};
    for (final card in newHand)
    {
      grouped.putIfAbsent(card.value, () => []).add(card);
    }

    final activeValues = CardValue.values.where((v) => grouped[v]?.isNotEmpty ?? false).toList();
    final List<List<CardComponent>> newSlots = [];

    for (final value in activeValues)
    {
      final cardsInSlot = grouped[value]!;
      final List<CardComponent> slotComponents = [];

      for (final card in cardsInSlot)
      {
        final component = existing.remove(card) ?? (CardComponent(card: card)..position = anchorPosition.clone());
        if (component.parent == null) add(component);

        component.interactive = true;
        component.onCardTapped = _handleCardTapped;

        slotComponents.add(component);
      }
      
      newSlots.add(slotComponents);
    }

    for (final leftover in existing.values) { leftover.removeFromParent(); }
    _slots = newSlots;
    _layoutSlots();
  }

  List<CardComponent> get selectedCards => _slots.expand((slot) => slot).where((c) => c.selected).toList();

  Vector2 getNextCardPosition()
  {
    return anchorPosition.clone();
  }

  void _handleCardTapped(CardComponent tapped)
  {
    final newSelected = !tapped.selected;

    if (newSelected) { _applySelectionRules(tapped); }
    else { tapped.setSelected(false); }

    _layoutSlots();
  }

  void _applySelectionRules(CardComponent card)
  {
    final cardValue = card.card.value;
    final isWildCard = card.card.isWildCard;

    final selectedCards = _slots.expand((slot) => slot).where((c) => c.selected).toList();
    if (selectedCards.isEmpty) { card.setSelected(true); }
    else
    {
      final baseCard = selectedCards.firstWhere((c) => !c.card.isWildCard, orElse: () => selectedCards.first);
      final baseValue = baseCard.card.value;

      if (cardValue == baseValue) { card.setSelected(true); }
      else if (isWildCard || baseCard.card.isWildCard) {card.setSelected(true); }
      else 
      {
        for (final c in selectedCards) { c.setSelected(false); }
        card.setSelected(true);
      }
    }
  }

  void _layoutSlots()
  {
    final slotCount = _slots.length;
    assert(slotCount <= _maxSlots, 'Hay más valores distintos en la mano ($slotCount) que slots previstos para el peor caso ($_maxSlots)');

    for (int i = 0; i < slotCount; ++i)
    {
      final slot = _slots[i];
      final selected = slot.isNotEmpty && slot.any((c) => c.selected);
      final slotPosition = _calculateSlotPosition(i, slotCount, selected: selected);

      for (int j = 0; j < slot.length; ++j)
      {
        final component = slot[j];
        final depth = j;
        final offset = _stackOffsetMagnitude(depth, selected);

        component.add(MoveToEffect(slotPosition + Vector2(0, -offset), EffectController(duration: 0.2)));
        component.priority = i * 100 + (slot.length - 1 - j);
      } 
    }
  }
  
  Vector2 _calculateSlotPosition(int slotIndex, int slotCount, {bool selected = false})
  {
    double x;

    if (slotCount <= 1)
    {
      x = anchorPosition.x;
    } else
    {
      final spacing = _maxHandWidth / (slotCount - 1);
      final startX = anchorPosition.x - _maxHandWidth / 2;
      x = startX + slotIndex * spacing;
    }

    final y = anchorPosition.y;

    return Vector2(x, y);
  }

  double _stackOffsetMagnitude(int depth, bool selected)
  {
    final stepSize = selected ? _stackStepExpanded : _stackStepCollapsed;
    return depth * stepSize;
  }
}