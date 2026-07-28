import 'package:canasta_app/domain/models/card.dart';
import 'package:canasta_app/game/components/card/card_sprite_resolver.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class CardComponent extends SpriteComponent with DragCallbacks
{
  final Card card;

  static const double cardWidth = 40.3; // Pixels del sprite original: 47

  static const double cardHeight = 54; // Pixels del sprite original: 63

  bool draggable = false; // Por defecto las cartas no son arrastrables. Solo lo serán las cartas de la mano del jugador

  bool _isDragging = false;

  void Function(CardComponent card)? onCardDropped;

  void Function(CardComponent card)? onDragStarted;

  void Function(CardComponent card)? onDragUpdated;

  CardComponent({required this.card})
    : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.center);

  @override
  Future<void> onLoad() async
  {
    sprite = await Sprite.load(CardSpriteResolver.pathFor(card));
  }

  @override
  void onDragStart(DragStartEvent event)
  {
    if (!draggable) return;

    super.onDragStart(event);

    _isDragging = true;
    priority = 1000; // Esto hará que se pinte la carta que se esta desplazando por encima de las demás
    onDragStarted?.call(this);
  }

  @override
  void onDragUpdate(DragUpdateEvent event)
  {
    if (!_isDragging) return;

    position += event.localDelta;
    onDragUpdated?.call(this);
  }

  @override
  void onDragEnd(DragEndEvent event)
  {
    super.onDragEnd(event);

    if (!_isDragging) return;

    _isDragging = false;
    onCardDropped?.call(this);
  }
}