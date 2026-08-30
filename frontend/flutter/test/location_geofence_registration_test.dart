import 'package:flutter_test/flutter_test.dart';

import 'package:sound_accessibility_app/models/models.dart';
import 'package:sound_accessibility_app/services/location_geofence_manager.dart';

void main() {
  test('multiple enabled geofences are mapped to native registrations', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final office = SavedIndoorLocation(
      id: 'office',
      name: 'Office',
      latitude: 12.9750,
      longitude: 77.6000,
      radiusMeters: 150,
      enabled: true,
    );

    final payload = LocationGeofenceManager.buildGeofenceRegistrationPayload([home, office]);

    expect(payload.length, 2);
    expect(payload[0]['id'], 'home');
    expect(payload[0]['latitude'], 12.9716);
    expect(payload[0]['radiusMeters'], 100.0);
    expect(payload[1]['id'], 'office');
  });

  test('disabled and invalid locations are excluded from registration payload', () {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final disabled = home.copyWith(id: 'disabled', enabled: false);
    final invalid = home.copyWith(
      id: 'invalid',
      latitude: 200,
      longitude: 200,
      radiusMeters: 0,
      enabled: true,
    );

    final payload = LocationGeofenceManager.buildGeofenceRegistrationPayload([home, disabled, invalid]);

    expect(payload, hasLength(1));
    expect(payload.first['id'], 'home');
  });

  test('geofence ids map correctly to saved location ids', () {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final college = SavedIndoorLocation(
      id: 'college',
      name: 'College',
      latitude: 12.9800,
      longitude: 77.5900,
      radiusMeters: 150,
      enabled: true,
    );

    final ids = LocationGeofenceManager.buildGeofenceIds([home, college]);

    expect(ids, ['home', 'college']);
  });
}
