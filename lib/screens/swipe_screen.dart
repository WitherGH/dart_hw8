import 'package:dart_hw8/models/user_profile.dart';
import 'package:dart_hw8/services/random_user_service.dart';
import 'package:dart_hw8/widgets/user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

enum ViewState { loading, loaded, error }

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final RandomUserService _service = RandomUserService();
  final CardSwiperController _swiperController = CardSwiperController();

  ViewState _state = ViewState.loading;
  List<UserProfile> _users = const [];
  String _errorMessage = '';
  int _likedCount = 0;
  int _skippedCount = 0;
  int _superLikeCount = 0;
  bool _isDeckFinished = false;
  double _dragX = 0;
  double _dragY = 0;
  int _likedPulseTick = 0;
  int _skippedPulseTick = 0;
  int _superPulseTick = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _state = ViewState.loading;
      _errorMessage = '';
    });

    try {
      final users = await _service.fetchUsers(count: 12);
      setState(() {
        _users = users;
        _likedCount = 0;
        _skippedCount = 0;
        _superLikeCount = 0;
        _isDeckFinished = false;
        _likedPulseTick = 0;
        _skippedPulseTick = 0;
        _superPulseTick = 0;
        _state = users.isEmpty ? ViewState.error : ViewState.loaded;
        _errorMessage = users.isEmpty ? 'No users received from API.' : '';
      });
    } catch (e) {
      setState(() {
        _state = ViewState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    var like = 0;
    var skip = 0;
    var superLike = 0;
    if (direction == CardSwiperDirection.right) {
      HapticFeedback.lightImpact();
      like = 1;
    } else if (direction == CardSwiperDirection.left) {
      HapticFeedback.selectionClick();
      skip = 1;
    } else if (direction == CardSwiperDirection.top) {
      HapticFeedback.mediumImpact();
      superLike = 1;
    }

    setState(() {
      _dragX = 0;
      _dragY = 0;
      _likedCount += like;
      _skippedCount += skip;
      _superLikeCount += superLike;
      _likedPulseTick += like;
      _skippedPulseTick += skip;
      _superPulseTick += superLike;
      if (currentIndex == null) {
        _isDeckFinished = true;
      }
    });
    return true;
  }

  void _updateDrag(double x, double y) {
    if ((_dragX - x).abs() < 0.02 && (_dragY - y).abs() < 0.02) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _dragX = x;
        _dragY = y;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const _AppLogo(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh users',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1538),
              Color(0xFF2D1F5B),
              Color(0xFF0F1020),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: switch (_state) {
              ViewState.loading => const _LoadingState(),
              ViewState.error => _ErrorState(
                  message: _errorMessage,
                  onRetry: _loadUsers,
                ),
              ViewState.loaded => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CounterBadge(
                          label: 'Liked',
                          value: _likedCount,
                          color: Colors.greenAccent,
                          pulseTick: _likedPulseTick,
                        ),
                        _CounterBadge(
                          label: 'Skipped',
                          value: _skippedCount,
                          color: Colors.redAccent,
                          pulseTick: _skippedPulseTick,
                        ),
                        _CounterBadge(
                          label: 'Super',
                          value: _superLikeCount,
                          color: Colors.lightBlueAccent,
                          pulseTick: _superPulseTick,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _HintPanel(dragX: _dragX, dragY: _dragY),
                    const SizedBox(height: 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        child: _isDeckFinished
                            ? _DeckFinishedState(onReload: _loadUsers)
                            : CardSwiper(
                                key: const ValueKey('deck'),
                                controller: _swiperController,
                                cardsCount: _users.length,
                                onSwipe: _onSwipe,
                                numberOfCardsDisplayed: 3,
                                scale: 0.93,
                                backCardOffset: const Offset(0, 18.0),
                                padding: const EdgeInsets.all(4),
                                allowedSwipeDirection:
                                    const AllowedSwipeDirection.only(
                                      left: true,
                                      right: true,
                                      up: true,
                                    ),
                                cardBuilder: (
                                  context,
                                  index,
                                  horizontalThresholdPercentage,
                                  verticalThresholdPercentage,
                                ) {
                                  _updateDrag(
                                    horizontalThresholdPercentage.toDouble(),
                                    verticalThresholdPercentage.toDouble(),
                                  );
                                  return UserCard(
                                    user: _users[index],
                                    horizontalSwipe:
                                        horizontalThresholdPercentage.toDouble(),
                                    verticalSwipe:
                                        verticalThresholdPercentage.toDouble(),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _HintPanel extends StatelessWidget {
  const _HintPanel({required this.dragX, required this.dragY});

  final double dragX;
  final double dragY;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x331A243A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x6654678A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _HintItem(
            icon: CupertinoIcons.xmark,
            label: 'Left: Skip',
            color: Colors.redAccent,
            isActive: dragX < -0.12 && dragX.abs() >= dragY.abs(),
          ),
          _HintItem(
            icon: CupertinoIcons.heart_fill,
            label: 'Right: Like',
            color: Colors.greenAccent,
            isActive: dragX > 0.12 && dragX.abs() >= dragY.abs(),
          ),
          _HintItem(
            icon: CupertinoIcons.star_fill,
            label: 'Up: Super',
            color: Colors.lightBlueAccent,
            isActive: dragY < -0.12 && dragY.abs() > dragX.abs(),
          ),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x2B131B2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x6654678A)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, size: 16, color: Colors.pinkAccent),
          SizedBox(width: 6),
          Text(
            'SwipeUA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintItem extends StatelessWidget {
  const _HintItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      scale: isActive ? 1.08 : 1,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 130),
        opacity: isActive ? 1 : 0.72,
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 14),
          Text(
            'Loading fresh profiles...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.pulseTick,
  });

  final String label;
  final int value;
  final Color color;
  final int pulseTick;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('pulse-$label-$pulseTick'),
      tween: Tween<double>(begin: 1.18, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0x2B131B2E),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color.withValues(alpha: 0.2),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  return Text(
                    animatedValue.round().toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckFinishedState extends StatelessWidget {
  const _DeckFinishedState({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('deck-finished'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x2B131B2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x6654678A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 36, color: Colors.amberAccent),
            const SizedBox(height: 10),
            const Text(
              'Deck finished',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You reviewed all profiles, load fresh ones to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text('Load more'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x2B131B2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x6654678A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
