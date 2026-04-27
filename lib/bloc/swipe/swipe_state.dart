import 'package:dart_hw8/models/user_profile.dart';

enum SwipeStatus { loading, loaded, error }

class SwipeState {
  const SwipeState({
    required this.status,
    required this.users,
    required this.errorMessage,
    required this.likedCount,
    required this.skippedCount,
    required this.superLikeCount,
    required this.isDeckFinished,
    required this.dragX,
    required this.dragY,
    required this.likedPulseTick,
    required this.skippedPulseTick,
    required this.superPulseTick,
  });

  factory SwipeState.initial() {
    return const SwipeState(
      status: SwipeStatus.loading,
      users: [],
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
    );
  }

  final SwipeStatus status;
  final List<UserProfile> users;
  final String errorMessage;
  final int likedCount;
  final int skippedCount;
  final int superLikeCount;
  final bool isDeckFinished;
  final double dragX;
  final double dragY;
  final int likedPulseTick;
  final int skippedPulseTick;
  final int superPulseTick;

  SwipeState copyWith({
    SwipeStatus? status,
    List<UserProfile>? users,
    String? errorMessage,
    int? likedCount,
    int? skippedCount,
    int? superLikeCount,
    bool? isDeckFinished,
    double? dragX,
    double? dragY,
    int? likedPulseTick,
    int? skippedPulseTick,
    int? superPulseTick,
  }) {
    return SwipeState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      likedCount: likedCount ?? this.likedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      superLikeCount: superLikeCount ?? this.superLikeCount,
      isDeckFinished: isDeckFinished ?? this.isDeckFinished,
      dragX: dragX ?? this.dragX,
      dragY: dragY ?? this.dragY,
      likedPulseTick: likedPulseTick ?? this.likedPulseTick,
      skippedPulseTick: skippedPulseTick ?? this.skippedPulseTick,
      superPulseTick: superPulseTick ?? this.superPulseTick,
    );
  }
}
