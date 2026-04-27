import 'package:dart_hw8/bloc/swipe/swipe_event.dart';
import 'package:dart_hw8/bloc/swipe/swipe_state.dart';
import 'package:dart_hw8/services/random_user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeBloc extends Bloc<SwipeEvent, SwipeState> {
  SwipeBloc({required RandomUserService service})
    : _service = service,
      super(SwipeState.initial()) {
    on<SwipeLoadRequested>(_onLoadRequested);
    on<SwipeDragChanged>(_onDragChanged);
    on<SwipeCommitted>(_onSwipeCommitted);
  }

  final RandomUserService _service;

  Future<void> _onLoadRequested(
    SwipeLoadRequested event,
    Emitter<SwipeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SwipeStatus.loading,
        errorMessage: '',
      ),
    );

    try {
      final users = await _service.fetchUsers(count: 12);
      if (users.isEmpty) {
        emit(
          state.copyWith(
            status: SwipeStatus.error,
            errorMessage: 'No users received from API.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: SwipeStatus.loaded,
          users: users,
          errorMessage: '',
          likedCount: 0,
          skippedCount: 0,
          superLikeCount: 0,
          isDeckFinished: false,
          dragX: 0,
          dragY: 0,
          likedPulseTick: 0,
          skippedPulseTick: 0,
          superPulseTick: 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SwipeStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onDragChanged(
    SwipeDragChanged event,
    Emitter<SwipeState> emit,
  ) {
    if ((state.dragX - event.dragX).abs() < 0.02 &&
        (state.dragY - event.dragY).abs() < 0.02) {
      return;
    }

    emit(
      state.copyWith(
        dragX: event.dragX,
        dragY: event.dragY,
      ),
    );
  }

  void _onSwipeCommitted(
    SwipeCommitted event,
    Emitter<SwipeState> emit,
  ) {
    var like = 0;
    var skip = 0;
    var superLike = 0;

    if (event.direction == CardSwiperDirection.right) {
      like = 1;
    } else if (event.direction == CardSwiperDirection.left) {
      skip = 1;
    } else if (event.direction == CardSwiperDirection.top) {
      superLike = 1;
    }

    emit(
      state.copyWith(
        dragX: 0,
        dragY: 0,
        likedCount: state.likedCount + like,
        skippedCount: state.skippedCount + skip,
        superLikeCount: state.superLikeCount + superLike,
        likedPulseTick: state.likedPulseTick + like,
        skippedPulseTick: state.skippedPulseTick + skip,
        superPulseTick: state.superPulseTick + superLike,
        isDeckFinished: event.currentIndex == null ? true : state.isDeckFinished,
      ),
    );
  }
}
