enum PriorityLevel { critical, high, medium, low }

enum EnvironmentType { indoor, outdoor }

class SoundLabel {
  final String id;
  final String name;
  final EnvironmentType environment;
  final String category;
  final PriorityLevel severity;
  final String imagePath;
  final String? iconName;

  const SoundLabel({
    required this.id,
    required this.name,
    required this.environment,
    required this.category,
    required this.severity,
    required this.imagePath,
    this.iconName,
  });

  factory SoundLabel.fromJson(Map<String, dynamic> json) {
    return SoundLabel(
      id: json['id'] as String,
      name: json['name'] as String,
      environment: json['environment'] == 'outdoor'
          ? EnvironmentType.outdoor
          : EnvironmentType.indoor,
      category: json['category'] as String,
      severity: _parseSeverity(json['severity'] as String),
      imagePath: json['imagePath'] as String? ?? '',
      iconName: json['iconName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'environment': environment == EnvironmentType.outdoor ? 'outdoor' : 'indoor',
        'category': category,
        'severity': severity.name,
        'imagePath': imagePath,
        'iconName': iconName,
      };

  static PriorityLevel _parseSeverity(String val) {
    switch (val.toLowerCase()) {
      case 'critical':
        return PriorityLevel.critical;
      case 'high':
        return PriorityLevel.high;
      case 'medium':
        return PriorityLevel.medium;
      case 'low':
      default:
        return PriorityLevel.low;
    }
  }
}

class SoundEvent {
  final String id;
  final String soundId;
  final String userId;
  final String label;
  final PriorityLevel severity;
  final EnvironmentType mode;
  final DateTime timestamp;

  SoundEvent({
    required this.id,
    required this.soundId,
    required this.userId,
    required this.label,
    required this.severity,
    required this.mode,
    required this.timestamp,
  });

  factory SoundEvent.fromJson(Map<String, dynamic> json) {
    final rawSoundId = json['sound_id'] as String? ??
        json['soundId'] as String? ??
        json['id'] as String? ??
        '';
    return SoundEvent(
      id: json['id'] as String,
      soundId: rawSoundId.isNotEmpty ? rawSoundId : (json['label'] as String? ?? ''),
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? 'guest_user',
      label: json['label'] as String? ?? '',
      severity: SoundLabel._parseSeverity(json['severity'] as String? ?? 'low'),
      mode: json['mode'] == 'outdoor' ? EnvironmentType.outdoor : EnvironmentType.indoor,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sound_id': soundId,
        'soundId': soundId,
        'user_id': userId,
        'label': label,
        'severity': severity.name,
        'mode': mode == EnvironmentType.outdoor ? 'outdoor' : 'indoor',
        'timestamp': timestamp.toIso8601String(),
      };

  SoundEvent copyWith({
    String? id,
    String? soundId,
    String? userId,
    String? label,
    PriorityLevel? severity,
    EnvironmentType? mode,
    DateTime? timestamp,
  }) {
    return SoundEvent(
      id: id ?? this.id,
      soundId: soundId ?? this.soundId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      severity: severity ?? this.severity,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class SavedLocation {
  final String id;
  final String name;
  final String address;
  final int? createdAt;

  SavedLocation({
    required this.id,
    required this.name,
    required this.address,
    this.createdAt,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      createdAt: json['createdAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'createdAt': createdAt,
      };
}

class UserProfile {
  String id;
  String name;
  int age;
  String phone;
  String email;
  bool micAccess;
  bool termsAccepted;
  bool privacyPolicyAccepted;
  List<String> outputPreferences; // 'text', 'icon', 'color'
  String? emergencyContactName;
  String? emergencyContactPhone;
  bool muteLowAlerts;
  bool muteMediumAlerts;
  bool gpsAutoDetect;
  List<SavedLocation> savedLocations;
  String language; // 'English', 'Hindi', 'Kannada'
  String textSize; // 'small', 'medium', 'large'
  bool highContrast;

  bool get isTextEnabled => outputPreferences.contains('text');
  bool get isIconEnabled => outputPreferences.contains('icon');
  bool get isColorEnabled => outputPreferences.contains('color');

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.email,
    this.micAccess = true,
    this.termsAccepted = true,
    this.privacyPolicyAccepted = true,
    this.outputPreferences = const ['text', 'icon', 'color'],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.muteLowAlerts = false,
    this.muteMediumAlerts = false,
    this.gpsAutoDetect = true,
    this.savedLocations = const [],
    this.language = 'English',
    this.textSize = 'medium',
    this.highContrast = false,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      id: 'default_user_1',
      name: 'Accessibility User',
      age: 28,
      phone: '+1 (555) 019-2834',
      email: 'user@sensoryreach.app',
      micAccess: true,
      termsAccepted: true,
      privacyPolicyAccepted: true,
      outputPreferences: ['text', 'icon', 'color'],
      emergencyContactName: 'Dr. Sarah Mitchell',
      emergencyContactPhone: '+1 (555) 911-0000',
    );
  }
}
