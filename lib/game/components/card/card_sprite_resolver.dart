import 'package:canasta_app/domain/enums/enums.dart';
import 'package:canasta_app/domain/models/card.dart';

class CardSpriteResolver
{
  static const _basePath = 'cards';

  static String pathFor(Card card)
  {
    if (card.value == CardValue.joker) return '$_basePath/joker/joker_1.png';

    final suitFolder = card.suit!.name;
    final valueFileName = _valueFileName(card.value); // Como los assets tienen nombre diferente al del enum CardValue, se hace una conversión
    
    return '$_basePath/$suitFolder/${suitFolder}_card_$valueFileName.png';
  }
  
  static String? _valueFileName(CardValue value)
  {
    switch(value)
    {
      case CardValue.ace: return '1';
      case CardValue.two: return '2';
      case CardValue.three: return '3';
      case CardValue.four: return '4';
      case CardValue.five: return '5';
      case CardValue.six: return '6';
      case CardValue.seven: return '7';
      case CardValue.eight: return '8';
      case CardValue.nine: return '9';
      case CardValue.ten: return '10';
      case CardValue.jack: return 'jack';
      case CardValue.queen: return 'queen';
      case CardValue.king: return 'king';
      default: throw ArgumentError('Error en el value para resolver el nombre del asset de la crata');
    }
  }
}