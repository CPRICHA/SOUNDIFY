import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../l10n/app_localizations.dart';
import '../app.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navTimer;

  late final AnimationController _ambientController;
  late final AnimationController _waveController;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Keep the existing splash duration unchanged.
    _navTimer = Timer(
      const Duration(milliseconds: 2400),
      _proceedToNext,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    if (reduceMotion == _reduceMotion &&
        (_ambientController.isAnimating || reduceMotion)) {
      return;
    }

    _reduceMotion = reduceMotion;

    if (reduceMotion) {
      _ambientController.stop();
      _ambientController.value = 0.45;

      _waveController.stop();
      _waveController.value = 0.0;
    } else {
      _ambientController.repeat(reverse: true);
      _waveController.repeat();
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ambientController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _proceedToNext() {
    if (!mounted) return;

    final state = context.read<AppState>();

    if (state.isOnboarded) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationShell(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);

    // Slightly larger than the previous version so the logo
    // has the same visual importance as in the reference.
    final logoSize =
        (size.shortestSide * 0.29).clamp(94.0, 122.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: InkWell(
        onTap: _proceedToNext,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft white / blue / lavender base.
            const ColoredBox(
              color: Color(0xFFF8FBFF),
            ),

            // Decorative background.
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SplashAtmospherePainter(
                      t: _ambientController.value,
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  children: [
                    // --------------------------------------------------
                    // TOP EMPTY / DECORATIVE AREA
                    // --------------------------------------------------
                    const Spacer(flex: 5),

                    // --------------------------------------------------
                    // LOGO
                    // --------------------------------------------------
                    _LogoGlow(
                      size: logoSize,
                      pulse: _ambientController,
                    ),

                    const SizedBox(height: 25),

                    // --------------------------------------------------
                    // APP NAME
                    // --------------------------------------------------
                    Text(
                      l10n?.appName ?? 'SoundSee',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF25168F),
                        letterSpacing: -0.7,
                        height: 1.05,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // --------------------------------------------------
                    // TAGLINE
                    // --------------------------------------------------
                    const Text(
                      'See every sound.\nFeel every moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        color: Color(0xFF6763A3),
                        letterSpacing: 0.05,
                      ),
                    ),

                    // --------------------------------------------------
                    // SPACE BEFORE LISTENING INDICATOR
                    // --------------------------------------------------
                    const Spacer(flex: 4),

                    // --------------------------------------------------
                    // WAVEFORM
                    // --------------------------------------------------
                    _AnimatedWaveform(
                      animation: _waveController,
                    ),

                    const SizedBox(height: 19),

                    // --------------------------------------------------
                    // LISTENING TEXT
                    // --------------------------------------------------
                    Text(
                      'Listening for sounds...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.05,
                        color: const Color(0xFF6763A3)
                            .withValues(alpha: 0.92),
                      ),
                    ),

                    SizedBox(
                      height: size.height < 640 ? 18 : 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// LOGO + SOFT HALO
// ================================================================

class _LogoGlow extends StatelessWidget {
  const _LogoGlow({
    required this.size,
    required this.pulse,
  });

  final double size;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glowOpacity =
            0.12 + (pulse.value * 0.05);

        final blur =
            22.0 + (pulse.value * 5.0);

        return Container(
          width: size + 32,
          height: size + 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB59AF4)
                    .withValues(alpha: glowOpacity),
                blurRadius: blur,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipOval(
        child: Image.asset(
          'assets/images/soundsee_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

// ================================================================
// ANIMATED LISTENING WAVEFORM
// ================================================================

class _AnimatedWaveform extends StatelessWidget {
  const _AnimatedWaveform({
    required this.animation,
  });

  final Animation<double> animation;

  // Symmetrical waveform similar to the reference.
  static const _phases = [
    0.0,
    0.55,
    1.05,
    1.55,
    2.10,
    2.65,
    3.15,
    3.70,
    4.25,
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          height: 42,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              _phases.length,
              (index) {
                final distance =
                    (index - 4).abs();

                final baseHeight =
                    9.0 + (4 - distance) * 4.0;

                final wave = math.sin(
                  animation.value *
                          2 *
                          math.pi +
                      _phases[index],
                );

                final height =
                    baseHeight +
                    wave * 5.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2.5,
                  ),
                  child: Container(
                    width: 4,
                    height: height.clamp(7.0, 34.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D28E8),
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// BACKGROUND ATMOSPHERE
// ================================================================

class _SplashAtmospherePainter extends CustomPainter {
  _SplashAtmospherePainter({
    required this.t,
  });

  final double t;

  static const Color _background =
      Color(0xFFF8FBFF);

  static const Color _veryLightBlue =
      Color(0xFFEAF4FF);

  static const Color _softBlue =
      Color(0xFFD6E8FF);

  static const Color _lavender =
      Color(0xFFC9B4FA);

  static const Color _lightLavender =
      Color(0xFFE5DAFF);

  static const Color _accent =
      Color(0xFF8C63E8);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final rect = Offset.zero & size;

    // ------------------------------------------------------------
    // VERY LIGHT BASE GRADIENT
    // ------------------------------------------------------------

    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEAF4FF),
          Color(0xFFF9FBFF),
          Color(0xFFF7F6FF),
          Color(0xFFEFF4FF),
        ],
        stops: [
          0.0,
          0.42,
          0.72,
          1.0,
        ],
      ).createShader(rect);

    canvas.drawRect(
      rect,
      basePaint,
    );

    // ------------------------------------------------------------
    // TOP LEFT — LARGE LAVENDER ORGANIC SHAPE
    // ------------------------------------------------------------

    _drawOrganicBlob(
      canvas,
      path: _topLeftBlob(size),
      color: _lavender.withValues(
        alpha: 0.82 + t * 0.025,
      ),
    );

    // Soft blue layer underneath the top-left blob.
    _drawOrganicBlob(
      canvas,
      path: _topLeftBlueBlob(size),
      color: _softBlue.withValues(
        alpha: 0.55,
      ),
    );

    // ------------------------------------------------------------
    // TOP RIGHT — VERY SOFT BLUE WASH
    // ------------------------------------------------------------

    _drawSoftOval(
      canvas,
      center: Offset(
        size.width * 0.82,
        size.height * 0.04,
      ),
      width: size.width * 0.78,
      height: size.height * 0.34,
      color: _veryLightBlue.withValues(
        alpha: 0.58,
      ),
      blur: 35,
    );

    // ------------------------------------------------------------
    // BOTTOM RIGHT — LARGE LAVENDER ORGANIC SHAPE
    // ------------------------------------------------------------

    _drawOrganicBlob(
      canvas,
      path: _bottomRightBlob(size),
      color: _lavender.withValues(
        alpha: 0.70 + t * 0.025,
      ),
    );

    // Slightly deeper lavender wash at the bottom-right.
    _drawSoftOval(
      canvas,
      center: Offset(
        size.width * 0.87,
        size.height * 0.94,
      ),
      width: size.width * 0.75,
      height: size.height * 0.48,
      color: _lightLavender.withValues(
        alpha: 0.42,
      ),
      blur: 38,
    );

    // ------------------------------------------------------------
    // BOTTOM LEFT — BLUE ORGANIC SHAPE
    // ------------------------------------------------------------

    _drawOrganicBlob(
      canvas,
      path: _bottomLeftBlob(size),
      color: _softBlue.withValues(
        alpha: 0.58,
      ),
    );

    // Small lavender overlap near the bottom center.
    _drawSoftOval(
      canvas,
      center: Offset(
        size.width * 0.50,
        size.height * 1.01,
      ),
      width: size.width * 0.62,
      height: size.height * 0.30,
      color: _lightLavender.withValues(
        alpha: 0.36,
      ),
      blur: 30,
    );

    // ------------------------------------------------------------
    // TOP RIGHT DOT GRID — 3 × 4
    // ------------------------------------------------------------

    _drawDotGrid(
      canvas,
      origin: Offset(
        size.width * 0.815,
        size.height * 0.087,
      ),
      columns: 3,
      rows: 4,
      spacingX: size.width * 0.052,
      spacingY: size.height * 0.019,
    );

    // ------------------------------------------------------------
    // BOTTOM LEFT DOT GRID — 3 × 4
    // ------------------------------------------------------------

    _drawDotGrid(
      canvas,
      origin: Offset(
        size.width * 0.048,
        size.height * 0.782,
      ),
      columns: 3,
      rows: 4,
      spacingX: size.width * 0.052,
      spacingY: size.height * 0.019,
    );

    // ------------------------------------------------------------
    // CONCENTRIC SOUND-WAVE ARCS
    // ------------------------------------------------------------

    _drawSoundArcs(
      canvas,
      size,
    );
  }

  // ==============================================================
  // TOP LEFT ORGANIC BLOB
  // ==============================================================

  Path _topLeftBlob(Size size) {
    final path = Path();

    path.moveTo(
      0,
      0,
    );

    path.lineTo(
      size.width * 0.50,
      0,
    );

    path.cubicTo(
      size.width * 0.51,
      size.height * 0.085,
      size.width * 0.48,
      size.height * 0.125,
      size.width * 0.37,
      size.height * 0.145,
    );

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.165,
      size.width * 0.23,
      size.height * 0.235,
      size.width * 0.17,
      size.height * 0.295,
    );

    path.cubicTo(
      size.width * 0.11,
      size.height * 0.365,
      size.width * 0.06,
      size.height * 0.405,
      0,
      size.height * 0.42,
    );

    path.close();

    return path;
  }

  // ==============================================================
  // TOP LEFT BLUE LAYER
  // ==============================================================

  Path _topLeftBlueBlob(Size size) {
    final path = Path();

    path.moveTo(
      0,
      size.height * 0.19,
    );

    path.cubicTo(
      size.width * 0.12,
      size.height * 0.175,
      size.width * 0.19,
      size.height * 0.13,
      size.width * 0.25,
      size.height * 0.06,
    );

    path.cubicTo(
      size.width * 0.30,
      size.height * 0.01,
      size.width * 0.35,
      0,
      size.width * 0.40,
      0,
    );

    path.lineTo(
      size.width * 0.48,
      0,
    );

    path.cubicTo(
      size.width * 0.48,
      size.height * 0.10,
      size.width * 0.43,
      size.height * 0.16,
      size.width * 0.33,
      size.height * 0.18,
    );

    path.cubicTo(
      size.width * 0.19,
      size.height * 0.21,
      size.width * 0.14,
      size.height * 0.29,
      0,
      size.height * 0.31,
    );

    path.close();

    return path;
  }

  // ==============================================================
  // BOTTOM RIGHT ORGANIC BLOB
  // ==============================================================

  Path _bottomRightBlob(Size size) {
    final path = Path();

    path.moveTo(
      size.width,
      size.height * 0.73,
    );

    path.cubicTo(
      size.width * 0.91,
      size.height * 0.75,
      size.width * 0.84,
      size.height * 0.80,
      size.width * 0.80,
      size.height * 0.88,
    );

    path.cubicTo(
      size.width * 0.77,
      size.height * 0.94,
      size.width * 0.68,
      size.height * 0.96,
      size.width * 0.60,
      size.height,
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.close();

    return path;
  }

  // ==============================================================
  // BOTTOM LEFT ORGANIC BLOB
  // ==============================================================

  Path _bottomLeftBlob(Size size) {
    final path = Path();

    path.moveTo(
      0,
      size.height * 0.91,
    );

    path.cubicTo(
      size.width * 0.10,
      size.height * 0.85,
      size.width * 0.22,
      size.height * 0.83,
      size.width * 0.32,
      size.height * 0.88,
    );

    path.cubicTo(
      size.width * 0.39,
      size.height * 0.92,
      size.width * 0.42,
      size.height * 0.97,
      size.width * 0.47,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    return path;
  }

  // ==============================================================
  // ORGANIC BLOB DRAWING
  // ==============================================================

  void _drawOrganicBlob(
    Canvas canvas, {
    required Path path,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      path,
      paint,
    );
  }

  // ==============================================================
  // SOFT OVAL
  // ==============================================================

  void _drawSoftOval(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required Color color,
    required double blur,
  }) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        blur,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: width,
        height: height,
      ),
      paint,
    );
  }

  // ==============================================================
  // DOT GRID
  // ==============================================================

  void _drawDotGrid(
    Canvas canvas, {
    required Offset origin,
    required int columns,
    required int rows,
    required double spacingX,
    required double spacingY,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var row = 0; row < rows; row++) {
      for (var column = 0;
          column < columns;
          column++) {
        paint.color = _accent.withValues(
          alpha: 0.42,
        );

        canvas.drawCircle(
          Offset(
            origin.dx +
                column * spacingX,
            origin.dy +
                row * spacingY,
          ),
          2.4,
          paint,
        );
      }
    }
  }

  // ==============================================================
  // CONCENTRIC SOUND ARCS
  // ==============================================================

  void _drawSoundArcs(
    Canvas canvas,
    Size size,
  ) {
    // This center is deliberately above the exact screen center,
    // matching the reference where the arcs surround the logo.
    final center = Offset(
      size.width * 0.50,
      size.height * 0.405,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Five increasingly large arcs.
    final arcSizes = [
      0.30,
      0.40,
      0.50,
      0.60,
      0.70,
    ];

    for (var i = 0;
        i < arcSizes.length;
        i++) {
      final subtleMotion =
          math.sin(
                t * math.pi * 2 +
                    i * 0.35,
              ) *
              0.008;

      final width =
          size.width *
          (arcSizes[i] + subtleMotion);

      final height =
          size.height *
          (0.135 + i * 0.045);

      final opacity = [
        0.17,
        0.15,
        0.12,
        0.10,
        0.075,
      ][i];

      paint
        ..color = const Color(0xFFB49AEF)
            .withValues(alpha: opacity)
        ..strokeWidth =
            i < 2 ? 1.65 : 1.35;

      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: width,
          height: height,
        ),
        math.pi * 1.10,
        math.pi * 0.80,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _SplashAtmospherePainter oldDelegate,
  ) {
    return oldDelegate.t != t;
  }
}