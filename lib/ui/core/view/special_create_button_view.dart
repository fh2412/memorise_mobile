import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedMagicCreateButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedMagicCreateButton({super.key, required this.onTap});

  @override
  State<AnimatedMagicCreateButton> createState() =>
      _AnimatedMagicCreateButtonState();
}

class _AnimatedMagicCreateButtonState extends State<AnimatedMagicCreateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // We define the animation here without 'late' by using the 'drive' method later
  late final Animation<double> _animation;

  static const Color _primaryColor = Color(0xFF305EA0);
  static const Color _secondaryColor = Color(0xFFFFA500);
  static const Color _errorColor = Color(0xFFBA1A1A);
  static const Color _surfaceColor = Color(0xFFF9F9FF);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // .drive() combines the controller with a Curve and a Tween
    // This is safer than using a separate late variable
    _animation = _controller.drive(CurveTween(curve: Curves.easeInOutCubic));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation, // Listening to the driven animation
      builder: (context, child) {
        return Container(
          height: 44, // Slightly shorter as requested
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GlowBorderPainter(
              progress: _animation.value, // Using the curved value
              colors: const [
                _primaryColor,
                _secondaryColor,
                _errorColor,
                _primaryColor,
              ],
            ),
            child: Material(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_to_photos_outlined,
                        size: 18,
                        color: _primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "START A MEMORY",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _primaryColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlowBorderPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _GlowBorderPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 3.0;
    final Rect rect = Offset.zero & size;
    final RRect rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.height / 2),
    );

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // The rotation uses 2 * pi for a full circle
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: _GradientRotation(progress * 2 * math.pi),
    ).createShader(rect);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GradientRotation extends GradientTransform {
  final double radians;
  const _GradientRotation(this.radians);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double centerWidth = bounds.width / 2;
    final double centerHeight = bounds.height / 2;

    // 1. Start with a translation matrix to move to the center
    // 2. Rotate
    // 3. Translate back
    // The '0.0' is for the Z-axis (3D depth), which we don't need for 2D.
    return Matrix4.translationValues(centerWidth, centerHeight, 0.0)
      ..rotateZ(radians)
      ..translate(-centerWidth, -centerHeight);
  }
}
