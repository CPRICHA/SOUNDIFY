class UserProfile {
  final String id;
  final String name;
  final int age;
  final String phone;
  final String email;
  final bool micAccess;
  final bool termsAccepted;
  final bool privacyPolicyAccepted;
  final List<String> outputPreferences; // 'text', 'icon', 'color'

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.email,
    required this.micAccess,
    required this.termsAccepted,
    required this.privacyPolicyAccepted,
    required this.outputPreferences,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'phone': phone,
    'email': email,
    'micAccess': micAccess,
    'termsAccepted': termsAccepted,
    'privacyPolicyAccepted': privacyPolicyAccepted,
    'outputPreferences': outputPreferences,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    age: json['age'] ?? 0,
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    micAccess: json['micAccess'] ?? false,
    termsAccepted: json['termsAccepted'] ?? false,
    privacyPolicyAccepted: json['privacyPolicyAccepted'] ?? false,
    outputPreferences: List<String>.from(json['outputPreferences'] ?? []),
  );
}

enum AlertSeverity {
  critical,
  attention,
  low
}

class SoundLabel {
  final String id;
  final String name;
  final String environment; // 'indoor' or 'outdoor'
  final String category;
  final AlertSeverity severity;
  final String iconName;

  SoundLabel({
    required this.id,
    required this.name,
    required this.environment,
    required this.category,
    required this.severity,
    required this.iconName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'environment': environment,
    'category': category,
    'severity': severity.name,
    'iconName': iconName,
  };
}

class SoundEvent {
  final String id;
  final String userId;
  final String label;
  final AlertSeverity severity;
  final String mode; // 'indoor' or 'outdoor'
  final DateTime timestamp;

  SoundEvent({
    required this.id,
    required this.userId,
    required this.label,
    required this.severity,
    required this.mode,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'label': label,
    'severity': severity.name,
    'mode': mode,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SoundEvent.fromJson(Map<String, dynamic> json) => SoundEvent(
    id: json['id'] ?? '',
    userId: json['userId'] ?? json['user_id'] ?? '',
    label: json['label'] ?? '',
    severity: AlertSeverity.values.firstWhere(
      (e) => e.name == (json['severity'] ?? 'low'),
      orElse: () => AlertSeverity.low,
    ),
    mode: json['mode'] ?? 'indoor',
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
  );
}
