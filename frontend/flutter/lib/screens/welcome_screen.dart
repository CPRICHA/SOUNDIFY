import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../app.dart';
import 'create_profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Centered Icon Badge
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isHC ? AppColors.hcText : AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: isHC
                      ? Border.all(color: AppColors.hcBorder, width: 2)
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: isHC ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Heading
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isHC ? AppColors.hcText : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtext
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.welcomeDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                    color: isHC ? AppColors.hcText : AppColors.textSecondary,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Bottom Buttons Stack
              Column(
                children: [
                  // Primary: Get Started (Sign Up)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isHC
                              ? const BorderSide(
                                  color: AppColors.hcBorder, width: 2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        l10n.getStarted,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary: Use Guest Demo Profile
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () async {
                        await state.completeOnboardingAsGuest();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainNavigationShell(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                        side: BorderSide(
                          color: isHC
                              ? AppColors.hcBorder
                              : const Color(0xFFE2E8F0),
                          width: isHC ? 2 : 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.useGuestProfile,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isHC ? FontWeight.w800 : FontWeight.w700,
                          color: isHC
                              ? AppColors.hcText
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
