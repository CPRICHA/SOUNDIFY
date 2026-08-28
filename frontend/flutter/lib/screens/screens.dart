import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../data/sound_taxonomy.dart';
import '../services/services.dart';
import '../services/sound_classifier.dart';

// Riverpod Providers
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());
final classificationServiceProvider = Provider<SoundClassificationService>((ref) => TFLiteSoundClassificationService());
final historyServiceProvider = Provider<HistorySyncService>((ref) => HiveHistorySyncService());
final emergencyServiceProvider = Provider<EmergencyService>((ref) => MockEmergencyService());

final authStateProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentModeProvider = StateProvider<String>((ref) => 'indoor'); // 'indoor' or 'outdoor'
final isListeningProvider = StateProvider<bool>((ref) => true);
final userPreferencesProvider = StateProvider<List<String>>((ref) => ['text', 'icon', 'color']);
final lastDetectedSoundProvider = StateProvider<SoundLabel?>((ref) => null);

/// -------------------------------------------------------------
/// 1. SPLASH SCREEN
/// -------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthLandingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hearing, size: 72, color: Colors.indigo),
            ),
            const SizedBox(height: 24),
            const Text(
              'SoundSee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visual & Haptic Sound Awareness',
              style: TextStyle(
                color: Colors.indigo.shade100,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 2. AUTH LANDING SCREEN
/// -------------------------------------------------------------
class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.indigo),
              const SizedBox(height: 32),
              const Text(
                'Welcome to SoundSee',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your safe, visual companion for environmental sound safety.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // Push to sign in
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 3. ONBOARDING SCREEN
/// -------------------------------------------------------------
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _micAccess = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age *', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Age is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Emergency Phone', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  value: _micAccess,
                  onChanged: (v) => setState(() => _micAccess = v ?? false),
                  title: const Text('Enable Microphone Access'),
                ),
                CheckboxListTile(
                  value: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  title: const Text('I accept Terms of Service *'),
                ),
                CheckboxListTile(
                  value: _privacyAccepted,
                  onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
                  title: const Text('I accept Privacy Policy *'),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _termsAccepted && _privacyAccepted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OutputPreferenceScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill required fields and accept terms.')),
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 4. OUTPUT STYLE PREFERENCE SCREEN
/// -------------------------------------------------------------
class OutputPreferenceScreen extends ConsumerWidget {
  const OutputPreferenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Style')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How should SoundSee alert you?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Pick at least one format. You can select multiple.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildPrefTile(
              ref,
              id: 'text',
              title: 'Text alerts',
              desc: 'Descriptive textual popup notifications',
              icon: Icons.text_fields,
              isSelected: prefs.contains('text'),
            ),
            const SizedBox(height: 16),
            _buildPrefTile(
              ref,
              id: 'icon',
              title: 'Icon-forward alerts',
              desc: 'Bold graphic sound sources and symbols',
              icon: Icons.image,
              isSelected: prefs.contains('icon'),
            ),
            const SizedBox(height: 16),
            _buildPrefTile(
              ref,
              id: 'color',
              title: 'Color Coded Alerts',
              desc: 'Vibrant color bands indicating danger level',
              icon: Icons.palette,
              isSelected: prefs.contains('color'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: prefs.isEmpty
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
              child: const Text('Complete Setup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefTile(
    WidgetRef ref, {
    required String id,
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
  }) {
    return Card(
      color: isSelected ? Colors.indigo.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? Colors.indigo : Colors.transparent, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final list = List<String>.from(ref.read(userPreferencesProvider));
          if (list.contains(id)) {
            list.remove(id);
          } else {
            list.add(id);
          }
          ref.read(userPreferencesProvider.notifier).state = list;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: isSelected ? Colors.indigo : Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  final list = List<String>.from(ref.read(userPreferencesProvider));
                  if (list.contains(id)) {
                    list.remove(id);
                  } else {
                    list.add(id);
                  }
                  ref.read(userPreferencesProvider.notifier).state = list;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 5. HOME SCREEN
/// -------------------------------------------------------------
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
   @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final service = ref.read(classificationServiceProvider);

      try {
        await service.initializeModel();

        await service.startListening((sound, confidence) {
          if (!mounted) return;

          ref.read(lastDetectedSoundProvider.notifier).state = sound;

          print(
            'Detected in HomeScreen: ${sound.name} '
            '${(confidence * 100).toStringAsFixed(1)}%',
          );
        });
      } catch (e) {
        print('Failed to start AIISH detection: $e');
      }
    });
  }

  @override
  void dispose() {
    ref.read(classificationServiceProvider).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(currentModeProvider);
    final listening = ref.watch(isListeningProvider);
    final lastSound = ref.watch(lastDetectedSoundProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoundSee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailedHistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode Toggler & GPS status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        mode == 'indoor' ? Icons.home : Icons.park,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mode == 'indoor' ? 'Indoor Mode' : 'Outdoor Mode',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.gps_fixed, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text('GPS Active', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Segmented Control
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref.read(currentModeProvider.notifier).state = 'indoor',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mode == 'indoor' ? Colors.indigo : Colors.grey.shade200,
                        foregroundColor: mode == 'indoor' ? Colors.white : Colors.black87,
                      ),
                      child: const Text('Indoor'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref.read(currentModeProvider.notifier).state = 'outdoor',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mode == 'outdoor' ? Colors.indigo : Colors.grey.shade200,
                        foregroundColor: mode == 'outdoor' ? Colors.white : Colors.black87,
                      ),
                      child: const Text('Outdoor'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Centered listening ring
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated Listening Ripple Circles (Static representation here)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      listening ? 'Listening for environment...' : 'Paused',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Outdoor safety auxiliary triggers (Dynamic)
              if (mode == 'outdoor' && lastSound != null && lastSound.severity == PriorityLevel.critical) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          ref.read(emergencyServiceProvider).triggerEmergencyAlert(
                            'user_123',
                            'Dispatched safety SMS to primary contact',
                            'CALL_EMERGENCY',
                          );
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call Emergency', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {},
                        icon: const Icon(Icons.safety_check, color: Colors.white),
                        label: const Text('Reached Safe', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Small history overview
              const Text('Recent Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('No recent critical events logged', style: TextStyle(color: Colors.grey)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 6 & 7. ALERT BANNERS (TEXT & ICON STYLE)
/// -------------------------------------------------------------
class AlertBannerText extends StatelessWidget {
  final String text;
  const AlertBannerText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertBannerIcon extends StatelessWidget {
  final SoundLabel sound;
  const AlertBannerIcon({Key? key, required this.sound}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color severityColor = Colors.green;
    IconData severityShape = Icons.circle;

    if (sound.severity == PriorityLevel.critical) {
      severityColor = Colors.red;
      severityShape = Icons.warning;
    } else if (sound.severity == PriorityLevel.high) {
      severityColor = Colors.orange;
      severityShape = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hearing, color: Colors.indigo, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sound.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(sound.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Icon(severityShape, color: severityColor, size: 32),
        ],
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 8. DETAILED HISTORY SCREEN
/// -------------------------------------------------------------
class DetailedHistoryScreen extends ConsumerWidget {
  const DetailedHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: soundTaxonomy.length,
        itemBuilder: (context, index) {
          final item = soundTaxonomy[index];
          IconData severityIcon = Icons.circle;
          Color sevColor = Colors.green;

          if (item.severity == PriorityLevel.critical) {
            severityIcon = Icons.warning_amber;
            sevColor = Colors.red;
          } else if (item.severity == PriorityLevel.high) {
            severityIcon = Icons.warning_amber;
            sevColor = Colors.amber;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(severityIcon, color: sevColor, size: 28),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item.category} • ${item.environment.name.toUpperCase()}'),
              trailing: const Text('Just now', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

/// -------------------------------------------------------------
/// 9. SETTINGS & VIBRATION GUIDE SCREEN
/// -------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vibration Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Haptic Vibration Guide',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'SoundSee converts acoustic danger levels into discrete structural vibration waveforms.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            _buildVibrationRow(
              title: 'Critical Severity Vibration',
              desc: 'Continuous intense pulses (250ms on, 50ms off) to ensure maximum safety.',
              intensity: 'High Intensity (Emergency)',
              waveform: '⌂⌂⌂⌂⌂⌂⌂⌂⌂⌂',
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            _buildVibrationRow(
              title: 'Attention Severity Vibration',
              desc: 'Double beat pattern (100ms pulse, 100ms pause, 100ms pulse) for general awareness.',
              intensity: 'Medium Intensity',
              waveform: '⌴⌴  ⌴⌴  ⌴⌴',
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildVibrationRow(
              title: 'Low Severity Vibration',
              desc: 'Single light tap (50ms duration) for quiet background indicators.',
              intensity: 'Low Intensity (Ambient)',
              waveform: ' .   .   . ',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibrationRow({
    required String title,
    required String desc,
    required String intensity,
    required String waveform,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vibration, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(intensity, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)),
                Text(waveform, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: color, fontSize: 14)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
