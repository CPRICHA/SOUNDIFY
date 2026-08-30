import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'indoor_location_repository.dart';

class LocationGeofenceManager {
  LocationGeofenceManager({IndoorLocationRepository? repository})
      : _repository = repository ?? IndoorLocationRepository();

  static const MethodChannel _geofenceChannel =
      MethodChannel('com.example.sound_accessibility_app/geofence');
  static const String _pendingGeofenceEventKey = 'aiish_pending_geofence_event';

  final IndoorLocationRepository _repository;
  StreamSubscription<Position>? _subscription;
  bool _initialized = false;
  bool _platformHandlerRegistered = false;
  Future<void> Function(List<String> ids, int transition)? _nativeTransitionListener;

  Stream<Position> get positionStream => _positionController.stream;
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  void setNativeGeofenceListener(
    Future<void> Function(List<String> ids, int transition)? listener,
  ) {
    _nativeTransitionListener = listener;
    if (!_platformHandlerRegistered) {
      _platformHandlerRegistered = true;
      _geofenceChannel.setMethodCallHandler(_handleNativeMethodCall);
    }
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    if (call.method == 'geofenceTransition') {
      final ids = (call.arguments['ids'] as List?)?.cast<String>() ?? const <String>[];
      final transition = (call.arguments['transition'] as num?)?.toInt() ?? 0;
      if (ids.isNotEmpty && _nativeTransitionListener != null) {
        await _nativeTransitionListener!(ids, transition);
        return true;
      }
    }
    return null;
  }

  static bool _isValidLocation(SavedIndoorLocation location) {
    if (!location.enabled) return false;
    if (location.latitude.isNaN ||
        location.longitude.isNaN ||
        location.latitude.isInfinite ||
        location.longitude.isInfinite) {
      return false;
    }
    if (location.latitude < -90 || location.latitude > 90) return false;
    if (location.longitude < -180 || location.longitude > 180) return false;
    if (location.radiusMeters.isNaN ||
        location.radiusMeters.isInfinite ||
        location.radiusMeters <= 0) {
      return false;
    }
    return true;
  }

  static List<Map<String, dynamic>> buildGeofenceRegistrationPayload(
    List<SavedIndoorLocation> locations,
  ) {
    return locations
        .where(_isValidLocation)
        .map((location) => {
              'id': location.id,
              'latitude': location.latitude,
              'longitude': location.longitude,
              'radiusMeters': location.radiusMeters,
            })
        .toList();
  }

  static List<String> buildGeofenceIds(List<SavedIndoorLocation> locations) {
    return locations.where(_isValidLocation).map((location) => location.id).toList();
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _initialized = true;
      return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      _initialized = true;
      return;
    }

    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 25,
      ),
    ).listen((position) {
      _positionController.add(position);
    });

    _initialized = true;
  }

  Future<Position?> resolveCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<SavedIndoorLocation>> getEnabledLocations() async {
    final all = await _repository.getAllLocations();
    return all.where((location) => location.enabled).toList();
  }

  Future<void> syncEnabledGeofences([List<SavedIndoorLocation>? suppliedLocations]) async {
    if (!Platform.isAndroid) {
      return;
    }

    final locations = suppliedLocations ?? await getEnabledLocations();
    final payload = buildGeofenceRegistrationPayload(locations);

    if (payload.isEmpty) {
      await removeAllGeofences();
      return;
    }

    try {
      await _geofenceChannel.invokeMethod<bool>(
        'registerGeofences',
        {'locations': payload},
      );
    } catch (_) {
      return;
    }
  }

  Future<void> removeGeofence(String locationId) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      await _geofenceChannel.invokeMethod<bool>(
        'removeGeofence',
        {'locationId': locationId},
      );
    } catch (_) {
      return;
    }
  }

  Future<void> consumePendingGeofenceEvent() async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingGeofenceEventKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      await prefs.remove(_pendingGeofenceEventKey);
      final payload = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final ids = (payload['ids'] as List?)?.cast<String>() ?? const <String>[];
      final transition = (payload['transition'] as num?)?.toInt() ?? 0;
      if (ids.isEmpty) {
        return;
      }
      if (_nativeTransitionListener != null) {
        await _nativeTransitionListener!(ids, transition);
      }
    } catch (_) {
      return;
    }
  }

  Future<void> removeAllGeofences() async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      await _geofenceChannel.invokeMethod<bool>('removeAllGeofences');
    } catch (_) {
      return;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _positionController.close();
  }
}
