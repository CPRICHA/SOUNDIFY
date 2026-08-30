import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/models.dart';
import 'location_geofence_manager.dart';

enum EnvironmentState { indoor, outdoor, unknown }

class EnvironmentManager extends ChangeNotifier {
  EnvironmentManager({LocationGeofenceManager? locationGeofenceManager})
      : _locationManager = locationGeofenceManager ?? LocationGeofenceManager();

  final LocationGeofenceManager _locationManager;
  EnvironmentState _currentEnvironment = EnvironmentState.unknown;
  SavedIndoorLocation? _activeIndoorLocation;
  String? _activeLocationId;
  Position? _lastPosition;

  LocationGeofenceManager get locationManager => _locationManager;

  EnvironmentState get currentEnvironment => _currentEnvironment;
  SavedIndoorLocation? get activeIndoorLocation => _activeIndoorLocation;
  String? get activeLocationId => _activeLocationId;
  Position? get lastPosition => _lastPosition;

  bool get isUnknown => _currentEnvironment == EnvironmentState.unknown;

  Future<void> initialize() async {
    await _locationManager.initialize();
    final position = await _locationManager.resolveCurrentPosition();
    if (position != null) {
      await updateFromPosition(position);
    }

    _locationManager.positionStream.listen((position) async {
      await updateFromPosition(position);
    });
  }

  Future<void> refreshFromLastKnownOrCurrent() async {
    final position = _lastPosition ?? await _locationManager.resolveCurrentPosition();
    if (position != null) {
      await updateFromPosition(position);
      return;
    }

    if (_currentEnvironment == EnvironmentState.indoor) {
      _setEnvironment(EnvironmentState.outdoor, null, null);
    }
  }

  Future<void> updateFromPosition(Position currentPosition) async {
    _lastPosition = currentPosition;

    if (currentPosition.accuracy > 80 ||
        currentPosition.latitude.isNaN ||
        currentPosition.longitude.isNaN ||
        currentPosition.latitude.isInfinite ||
        currentPosition.longitude.isInfinite) {
      _setEnvironment(EnvironmentState.unknown, null, null);
      return;
    }

    final enabledLocations = await _locationManager.getEnabledLocations();
    if (enabledLocations.isEmpty) {
      _setEnvironment(EnvironmentState.outdoor, null, null);
      return;
    }

    final previousState = _currentEnvironment;
    final previousLocation = _activeIndoorLocation;
    SavedIndoorLocation? indoorCandidate;
    double closestDistance = double.infinity;

    for (final location in enabledLocations) {
      final distance = _distanceInMeters(currentPosition, location);
      final threshold = location.radiusMeters + 50.0;
      final isInsideRadius = distance <= location.radiusMeters;
      final isInsideHysteresis =
          previousState == EnvironmentState.indoor &&
          previousLocation != null &&
          previousLocation.id == location.id &&
          distance > location.radiusMeters &&
          distance <= threshold;

      if (isInsideRadius || isInsideHysteresis) {
        if (distance < closestDistance) {
          closestDistance = distance;
          indoorCandidate = location;
        }
      }
    }

    if (indoorCandidate != null) {
      _setEnvironment(EnvironmentState.indoor, indoorCandidate, indoorCandidate.id);
      return;
    }

    if (previousState == EnvironmentState.indoor &&
        previousLocation != null &&
        enabledLocations.any((location) => location.id == previousLocation.id)) {
      final previousDistance = _distanceInMeters(currentPosition, previousLocation);
      final exitThreshold = previousLocation.radiusMeters + 50.0;
      if (previousDistance <= exitThreshold) {
        _setEnvironment(EnvironmentState.indoor, previousLocation, previousLocation.id);
        return;
      }
    }

    _setEnvironment(EnvironmentState.outdoor, null, null);
  }

  double _distanceInMeters(Position position, SavedIndoorLocation location) {
    final lat1 = position.latitude * pi / 180.0;
    final lat2 = location.latitude * pi / 180.0;
    final deltaLat = (location.latitude - position.latitude) * pi / 180.0;
    final deltaLon = (location.longitude - position.longitude) * pi / 180.0;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return 6371000.0 * c;
  }

  void _setEnvironment(
    EnvironmentState state,
    SavedIndoorLocation? location,
    String? activeId,
  ) {
    if (_currentEnvironment == state &&
        _activeIndoorLocation?.id == activeId &&
        _activeLocationId == activeId) {
      return;
    }

    _currentEnvironment = state;
    _activeIndoorLocation = location;
    _activeLocationId = activeId;
    notifyListeners();
  }
}
