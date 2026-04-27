import 'package:flutter_card_swiper/flutter_card_swiper.dart';

sealed class SwipeEvent {
  const SwipeEvent();
}

class SwipeLoadRequested extends SwipeEvent {
  const SwipeLoadRequested();
}

class SwipeDragChanged extends SwipeEvent {
  const SwipeDragChanged({
    required this.dragX,
    required this.dragY,
  });

  final double dragX;
  final double dragY;
}

class SwipeCommitted extends SwipeEvent {
  const SwipeCommitted({
    required this.direction,
    required this.currentIndex,
  });

  final CardSwiperDirection direction;
  final int? currentIndex;
}
