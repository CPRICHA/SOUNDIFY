import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'create_profile_screen.dart';
import 'screens.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.8, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.9, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final colors = _WelcomeColors(isHC: isHC);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const _WelcomeBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  _TopBrand(colors: colors),
                  const SizedBox(height: 8),
                  _DecorativeNote(colors: colors),
                  const SizedBox(height: 12),
                  SlideTransition(
                    position: _heroSlide,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: const _SoundAwarenessHero(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stay aware of the sounds\naround you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.heading,
                      fontSize: 29,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'SoundSee helps turn important environmental\nsounds into clear visual and sensory alerts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.body,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeIn,
                    child: _GetStartedButton(
                      colors: colors,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SignInPrompt(
                    colors: colors,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeColors {
  const _WelcomeColors({required this.isHC});

  final bool isHC;

  Color get background => isHC ? Colors.white : const Color(0xFFFBF9FF);
  Color get heading => isHC ? Colors.black : const Color(0xFF252338);
  Color get body => isHC ? const Color(0xFF202020) : const Color(0xFF6F6A80);
  Color get purple => isHC ? Colors.black : const Color(0xFF7255D7);
}

class _WelcomeBackdrop extends StatelessWidget {
  const _WelcomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 270,
              height: 270,
              decoration: const BoxDecoration(
                color: Color(0xFFEFEAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 265,
            left: -150,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAFF).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -75,
            left: -30,
            right: -30,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAFE).withValues(alpha: 0.75),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.elliptical(220, 72),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -108,
            right: -50,
            child: Container(
              width: 260,
              height: 135,
              decoration: BoxDecoration(
                color: const Color(0xFFE5D9FC).withValues(alpha: 0.58),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.elliptical(190, 70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBrand extends StatelessWidget {
  const _TopBrand({required this.colors});

  final _WelcomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.purple.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/soundsee_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 9),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: colors.heading,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
            children: [
              const TextSpan(text: 'Sound'),
              TextSpan(
                text: 'See',
                style: TextStyle(color: colors.purple),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Sound awareness, made accessible.',
          style: TextStyle(
            color: colors.body,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }
}

class _DecorativeNote extends StatelessWidget {
  const _DecorativeNote({required this.colors});

  final _WelcomeColors colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A quieter world\nA more aware you',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colors.purple.withValues(alpha: 0.7),
                fontFamily: 'serif',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.25,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.favorite_border_rounded,
              size: 17,
              color: colors.purple.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundAwarenessHero extends StatelessWidget {
  const _SoundAwarenessHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 222,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 204,
            height: 204,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFE3D7FF), Color(0xFFF6F2FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8C6DE5).withValues(alpha: 0.15),
                  blurRadius: 28,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            child: _WaveMark(
              color: const Color(0xFF9D83E7).withValues(alpha: 0.7),
            ),
          ),
          Positioned(
            left: 4,
            top: 72,
            child: _SoundBubble(
              icon: Icons.directions_car_rounded,
              label: 'Vehicles',
            ),
          ),
          Positioned(
            right: 2,
            top: 52,
            child: _SoundBubble(
              icon: Icons.music_note_rounded,
              label: 'Music',
            ),
          ),
          Positioned(
            left: 28,
            bottom: 16,
            child: _SoundBubble(icon: Icons.pets_rounded, label: 'Dogs'),
          ),
          Positioned(
            right: 24,
            bottom: 13,
            child: _SoundBubble(
              icon: Icons.notifications_active_rounded,
              label: 'Alarms',
            ),
          ),
          Positioned(
            bottom: 1,
            child: _SoundBubble(icon: Icons.groups_rounded, label: 'People'),
          ),
          Container(
            width: 112,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF7255D7),
              borderRadius: BorderRadius.circular(56),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7255D7).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD8C8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 38,
                  color: Color(0xFF7255D7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveMark extends StatelessWidget {
  const _WaveMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final height in [12.0, 24.0, 36.0, 24.0, 12.0])
          Container(
            width: 4,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }
}

class _SoundBubble extends StatelessWidget {
  const _SoundBubble({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0D6FA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A7255D7),
                blurRadius: 9,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF7255D7)),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF807A91),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.colors, required this.onPressed});

  final _WelcomeColors colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: colors.isHC
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF8D6BEA), Color(0xFF6949C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: colors.isHC ? Colors.black : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.purple.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: colors.isHC
                  ? const BorderSide(color: Colors.white, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.colors, required this.onPressed});

  final _WelcomeColors colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Already have an account? Sign in',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: colors.body,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              children: [
                const TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign in',
                  style: TextStyle(
                    color: colors.purple,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
