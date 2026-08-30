import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:sound_accessibility_app/models/models.dart';
import 'package:sound_accessibility_app/services/environment_manager.dart';
import 'package:sound_accessibility_app/services/location_geofence_manager.dart';

class TestLocationGeofenceManager extends LocationGeofenceManager {
  TestLocationGeofenceManager(this.locations);

  final List<SavedIndoorLocation> locations;

  @override
  Future<List<SavedIndoorLocation>> getEnabledLocations() async {
    return locations.where((location) => location.enabled).toList();
  }
}

Position _position(double lat, double lon, {double accuracy = 5}) {
  return Position(
    latitude: lat,
    longitude: lon,
    timestamp: DateTime.now(),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
    isMocked: false,
  );
}

void main() {
  test('inside Home returns indoor', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home]),
    );

    await manager.updateFromPosition(_position(12.9716, 77.5946));

    expect(manager.currentEnvironment, EnvironmentState.indoor);
    expect(manager.activeLocationId, 'home');
  });

  test('inside College returns indoor', () async {
    final college = SavedIndoorLocation(
      id: 'college',
      name: 'College',
      latitude: 12.9800,
      longitude: 77.5900,
      radiusMeters: 150,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([college]),
    );

    await manager.updateFromPosition(_position(12.9800, 77.5900));

    expect(manager.currentEnvironment, EnvironmentState.indoor);
    expect(manager.activeLocationId, 'college');
  });

  test('outside all locations returns outdoor', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home]),
    );

    await manager.updateFromPosition(_position(12.9600, 77.5800));

    expect(manager.currentEnvironment, EnvironmentState.outdoor);
    expect(manager.activeLocationId, isNull);
  });

  test('disabled location is ignored', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: false,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home]),
    );

    await manager.updateFromPosition(_position(12.9716, 77.5946));

    expect(manager.currentEnvironment, EnvironmentState.outdoor);
  });

  test('multiple enabled locations work', () async {
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
      radiusMeters: 100,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home, office]),
    );

    await manager.updateFromPosition(_position(12.9750, 77.6000));

    expect(manager.currentEnvironment, EnvironmentState.indoor);
    expect(manager.activeLocationId, 'office');
  });

  test('overlapping locations choose nearest active location', () async {
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
      latitude: 12.9725,
      longitude: 77.5955,
      radiusMeters: 150,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home, college]),
    );

    await manager.updateFromPosition(_position(12.9720, 77.5950));

    expect(manager.currentEnvironment, EnvironmentState.indoor);
    expect(manager.activeLocationId, 'home');
  });

  test('GPS jitter keeps previous stable state inside hysteresis band', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home]),
    );

    await manager.updateFromPosition(_position(12.9716, 77.5946));
    await manager.updateFromPosition(_position(12.9726, 77.5946));

    expect(manager.currentEnvironment, EnvironmentState.indoor);
  });

  test('hysteresis exits indoor only beyond threshold', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home]),
    );

    await manager.updateFromPosition(_position(12.9716, 77.5946));
    await manager.updateFromPosition(_position(12.9722, 77.5946));
    expect(manager.currentEnvironment, EnvironmentState.indoor);

    final farPoint = _position(12.9738, 77.5946);
    await manager.updateFromPosition(farPoint);
    expect(manager.currentEnvironment, EnvironmentState.outdoor);
  });

  test('poor accuracy resolves to unknown', () async {
    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );
    final manager = EnvironmentManager(
      locationGeofenceManager: TestLocationGeofenceManager([home]),
    );

    await manager.updateFromPosition(_position(12.9716, 77.5946, accuracy: 120));

    expect(manager.currentEnvironment, EnvironmentState.unknown);
  });
}
