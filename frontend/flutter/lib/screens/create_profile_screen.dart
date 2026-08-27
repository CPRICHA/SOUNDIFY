import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'alert_presentation_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Accessibility User');
  final _ageController = TextEditingController(text: '28');
  final _phoneController = TextEditingController(text: '9876543210');
  final _emailController = TextEditingController(text: 'user@sensoryreach.app');

  String _countryCode = '+91';
  bool _micAccess = true;
  bool _locationAccess = true;
  bool _termsAccepted = true;
  bool _privacyAccepted = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleNext(AppLocalizations l10n) {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final ageStr = _ageController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = l10n.errEnterName);
      return;
    }

    final age = int.tryParse(ageStr);
    if (age == null || age <= 0 || age > 120) {
      setState(() => _errorMessage = l10n.errEnterAge);
      return;
    }

    if (phone.isEmpty || phone.length < 7) {
      setState(() => _errorMessage = l10n.errEnterPhone);
      return;
    }

    if (!_micAccess) {
      setState(() => _errorMessage = l10n.errMicRequired);
      return;
    }

    if (!_locationAccess) {
      setState(() => _errorMessage = l10n.errLocationRequired);
      return;
    }

    if (!_termsAccepted) {
      setState(() => _errorMessage = l10n.errTermsRequired);
      return;
    }

    if (!_privacyAccepted) {
      setState(() => _errorMessage = l10n.errPrivacyRequired);
      return;
    }

    // Update app state profile
    final state = context.read<AppState>();
    final currentProfile = state.userProfile;
    currentProfile.name = name;
    currentProfile.age = age;
    currentProfile.phone = '$_countryCode $phone';
    currentProfile.email = _emailController.text.trim();
    currentProfile.micAccess = _micAccess;
    currentProfile.gpsAutoDetect = _locationAccess;
    currentProfile.termsAccepted = _termsAccepted;
    currentProfile.privacyPolicyAccepted = _privacyAccepted;

    state.updateProfile(currentProfile);

    // Proactively request runtime notification permissions for background alert delivery
    NotificationService.instance.requestPermissions();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AlertPresentationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.createProfileTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtext
                      Text(
                        l10n.createProfileDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isHC ? AppColors.hcText : AppColors.textSecondary,
                          fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // NAME *
                      _buildLabel(l10n.labelName, isHC),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isHC ? AppColors.hcText : AppColors.textPrimary,
                        ),
                        decoration: _buildInputDecoration(
                          hint: l10n.placeholderName,
                          isHC: isHC,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // AGE * and PHONE * Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Age field (35% width)
                          SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(l10n.labelAge, isHC),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isHC
                                        ? AppColors.hcText
                                        : AppColors.textPrimary,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hint: l10n.placeholderAge,
                                    isHC: isHC,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Phone field (expanded)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(l10n.labelPhone, isHC),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    // Country Code Dropdown
                                    Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isHC
                                              ? AppColors.hcBorder
                                              : const Color(0xFFCBD5E1),
                                          width: isHC ? 2 : 1,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _countryCode,
                                          icon: const Icon(
                                            Icons.arrow_drop_down_rounded,
                                            size: 20,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isHC
                                                ? AppColors.hcText
                                                : AppColors.textPrimary,
                                          ),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(
                                                  () => _countryCode = val);
                                            }
                                          },
                                          items: const [
                                            DropdownMenuItem(
                                              value: '+91',
                                              child: Text('🇮🇳 +91'),
                                            ),
                                            DropdownMenuItem(
                                              value: '+1',
                                              child: Text('🇺🇸 +1'),
                                            ),
                                            DropdownMenuItem(
                                              value: '+44',
                                              child: Text('🇬🇧 +44'),
                                            ),
                                            DropdownMenuItem(
                                              value: '+61',
                                              child: Text('🇦🇺 +61'),
                                            ),
                                            DropdownMenuItem(
                                              value: '+971',
                                              child: Text('🇦🇪 +971'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Phone Number Input
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: isHC
                                              ? AppColors.hcText
                                              : AppColors.textPrimary,
                                        ),
                                        decoration: _buildInputDecoration(
                                          hint: l10n.placeholderPhone,
                                          isHC: isHC,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // EMAIL (optional)
                      _buildLabel(l10n.labelEmail, isHC),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isHC ? AppColors.hcText : AppColors.textPrimary,
                        ),
                        decoration: _buildInputDecoration(
                          hint: l10n.placeholderEmail,
                          isHC: isHC,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Checkboxes Section
                      _buildCheckboxTile(
                        title: l10n.micAccessTitle,
                        value: _micAccess,
                        isHC: isHC,
                        onChanged: (val) =>
                            setState(() => _micAccess = val ?? false),
                      ),
                      _buildCheckboxTile(
                        title: l10n.locationAccessTitle,
                        value: _locationAccess,
                        isHC: isHC,
                        onChanged: (val) =>
                            setState(() => _locationAccess = val ?? false),
                      ),
                      _buildCheckboxTile(
                        title: l10n.termsOfServiceTitle,
                        value: _termsAccepted,
                        isHC: isHC,
                        onChanged: (val) =>
                            setState(() => _termsAccepted = val ?? false),
                      ),
                      _buildCheckboxTile(
                        title: l10n.privacyPolicyTitle,
                        value: _privacyAccepted,
                        isHC: isHC,
                        onChanged: (val) =>
                            setState(() => _privacyAccepted = val ?? false),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.criticalBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.criticalBorder, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 16, color: AppColors.critical),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.critical,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _handleNext(l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isHC
                          ? const BorderSide(color: AppColors.hcBorder, width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    l10n.nextStylePreferences,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isHC) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: isHC ? AppColors.hcText : const Color(0xFF64748B),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required bool isHC,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isHC ? AppColors.hcBorder : const Color(0xFFCBD5E1),
          width: isHC ? 2 : 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isHC ? AppColors.hcBorder : const Color(0xFFCBD5E1),
          width: isHC ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isHC ? AppColors.hcBorder : const Color(0xFF5B4FE8),
          width: isHC ? 2 : 2,
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required bool isHC,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor:
                      isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isHC ? FontWeight.w800 : FontWeight.w600,
                    color: isHC
                        ? AppColors.hcText
                        : const Color(0xFF334155),
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
