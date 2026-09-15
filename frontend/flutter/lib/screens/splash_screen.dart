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
    _navTimer = Timer(const Duration(milliseconds: 2400), _proceedToNext);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
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
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final logoSize = (size.shortestSide * 0.22).clamp(76.0, 96.0);

    return Scaffold(
      body: InkWell(
        onTap: _proceedToNext,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3A348F),
                Color(0xFF5148D0),
                Color(0xFF665BE0),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _ambientController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _SoundWaveBackgroundPainter(
                        t: _ambientController.value,
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      _LogoGlow(
                        size: logoSize,
                        pulse: _ambientController,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n?.appName ?? 'SoundSee',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'See every sound.\nFeel every moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: const Color(0xFFEDE9FE).withValues(alpha: 0.92),
                        ),
                      ),
                      const Spacer(flex: 4),
                      _AnimatedWaveform(animation: _waveController),
                      const SizedBox(height: 12),
                      Text(
                        'Listening for sounds...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                      SizedBox(height: size.height < 640 ? 20 : 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        final glow = 0.22 + (pulse.value * 0.10);
        final blur = 22.0 + (pulse.value * 8.0);
        return Container(
          width: size + 36,
          height: size + 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4B5FD).withValues(alpha: glow),
                blurRadius: blur,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/soundsee_logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _AnimatedWaveform extends StatelessWidget {
  const _AnimatedWaveform({required this.animation});

  final Animation<double> animation;

  static const _phases = [0.0, 0.7, 1.4, 0.35, 1.9, 1.1, 0.55, 1.65];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          height: 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_phases.length, (i) {
              final wave = math.sin(
                (animation.value * 2 * math.pi) + _phases[i],
              );
              final height = 5.0 + ((wave + 1) / 2) * 14.0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 3,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Soft, ear-bound arcs that stay decorative and low-contrast.
class _SoundWaveBackgroundPainter extends CustomPainter {
  _SoundWaveBackgroundPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, size.height * 0.42);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final drift = t * 0.04;
      final opacity = 0.05 + (i.isEven ? t * 0.02 : (1 - t) * 0.015);
      paint
        ..color = const Color(0xFFF5F3FF).withValues(alpha: opacity)
        ..strokeWidth = 1.25;

      final rx = size.width * (0.24 + i * 0.09 + drift);
      final ry = size.height * (0.10 + i * 0.04 + drift * 0.3);
      canvas.drawArc(
        Rect.fromCenter(center: origin, width: rx * 2, height: ry * 2),
        math.pi * 1.12,
        math.pi * 0.76,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoundWaveBackgroundPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
