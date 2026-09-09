import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/full_screen_alert_screen.dart';
import 'widgets/bottom_nav.dart';

class SensoryReachApp extends StatefulWidget {
  const SensoryReachApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<SensoryReachApp> createState() => _SensoryReachAppState();
}

class _SensoryReachAppState extends State<SensoryReachApp> {
  @override
  void initState() {
    super.initState();
    // Initialize system-level notification and full-screen intent dispatch
    NotificationService.instance
        .initialize(navKey: SensoryReachApp.navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, child) {
          final isHC = state.userProfile.highContrast;

          return MaterialApp(
            title: 'SoundSee',
            navigatorKey: SensoryReachApp.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(highContrast: isHC),
            locale: state.currentLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, childWidget) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(state.fontScale),
                ),
                child: childWidget ?? const SizedBox.shrink(),
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/shell': (context) => const MainNavigationShell(),
              '/alert': (context) => const FullScreenAlertScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final screens = const [
      HomeScreen(),
      HistoryScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
