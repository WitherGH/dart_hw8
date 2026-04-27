import 'package:dart_hw8/models/user_profile.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.horizontalSwipe = 0,
    this.verticalSwipe = 0,
  });

  final UserProfile user;
  final double horizontalSwipe;
  final double verticalSwipe;

  @override
  Widget build(BuildContext context) {
    final horizontalIntensity = horizontalSwipe.abs().clamp(0.0, 1.0);
    final verticalIntensity = verticalSwipe.abs().clamp(0.0, 1.0);
    final totalIntensity = (horizontalIntensity + verticalIntensity).clamp(0.0, 1.0);
    final isLikeDirection = horizontalSwipe > 0;
    final isSuperDirection = verticalSwipe < 0;
    final isSuperDominant = verticalIntensity > horizontalIntensity;
    final showHorizontalBadge = horizontalIntensity > 0.05 && !isSuperDominant;
    final showSuperBadge = isSuperDirection && verticalIntensity > 0.05;

    Color ringColor = Colors.transparent;
    if (verticalIntensity > horizontalIntensity && isSuperDirection) {
      ringColor = Colors.lightBlueAccent.withValues(alpha: 0.85);
    } else if (horizontalIntensity > 0) {
      ringColor = isLikeDirection
          ? Colors.greenAccent.withValues(alpha: 0.85)
          : Colors.redAccent.withValues(alpha: 0.85);
    }

    return Card(
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            user.photoUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.black12),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.06),
                  Colors.black.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: totalIntensity),
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              builder: (context, animatedIntensity, child) {
                return Transform.scale(
                  scale: 1 - (animatedIntensity * 0.025),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: ringColor,
                        width: animatedIntensity > 0.08 ? 2.6 : 0,
                      ),
                      boxShadow: animatedIntensity > 0.08
                          ? [
                              BoxShadow(
                                color: ringColor.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 24,
            left: isLikeDirection ? 16 : null,
            right: isLikeDirection ? null : 16,
            child: Opacity(
              opacity: showHorizontalBadge ? horizontalIntensity : 0,
              child: Transform.rotate(
                angle: isLikeDirection ? -0.22 : 0.22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLikeDirection ? Colors.greenAccent : Colors.redAccent,
                      width: 2,
                    ),
                    color: Colors.black.withValues(alpha: 0.32),
                  ),
                  child: Text(
                    isLikeDirection ? 'LIKE' : 'NOPE',
                    style: TextStyle(
                      color: isLikeDirection ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: showSuperBadge ? verticalIntensity : 0,
                child: Transform.scale(
                  scale: 0.92 + (verticalIntensity * 0.14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.lightBlueAccent, width: 2),
                      color: Colors.black.withValues(alpha: 0.32),
                    ),
                    child: const Text(
                      'SUPER LIKE',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName}, ${user.age}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.city,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.distanceKm} km away',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
