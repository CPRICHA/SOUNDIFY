import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class IndoorLocationRepository {
  static const String _storageKey = 'aiish_indoor_locations_v1';

  Future<List<SavedIndoorLocation>> getAllLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <SavedIndoorLocation>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <SavedIndoorLocation>[];
      }

      return decoded
          .map((item) => SavedIndoorLocation.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return <SavedIndoorLocation>[];
    }
  }

  Future<SavedIndoorLocation?> getLocation(String id) async {
    final locations = await getAllLocations();
    try {
      return locations.firstWhere((location) => location.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addLocation(SavedIndoorLocation location) async {
    final locations = await getAllLocations();
    final normalized = _normalize(location);
    final existing = locations.where((item) => item.id == normalized.id).toList();
    final updated = [...locations.where((item) => item.id != normalized.id), normalized];
    if (existing.isNotEmpty) {
      final merged = updated.toList();
      final index = merged.indexWhere((item) => item.id == normalized.id);
      if (index >= 0) {
        merged[index] = normalized;
      }
      await _persist(merged);
      return;
    }
    await _persist(updated);
  }

  Future<void> updateLocation(SavedIndoorLocation location) async {
    final normalized = _normalize(location);
    final locations = await getAllLocations();
    final updated = locations.map((item) {
      if (item.id == normalized.id) {
        return normalized;
      }
      return item;
    }).toList();

    if (!updated.any((item) => item.id == normalized.id)) {
      updated.add(normalized);
    }

    await _persist(updated);
  }

  Future<void> deleteLocation(String id) async {
    final locations = await getAllLocations();
    final filtered = locations.where((item) => item.id != id).toList();
    await _persist(filtered);
  }

  Future<void> setLocationEnabled(String id, bool enabled) async {
    final locations = await getAllLocations();
    final updated = locations.map((location) {
      if (location.id == id) {
        return location.copyWith(enabled: enabled, updatedAt: DateTime.now().millisecondsSinceEpoch);
      }
      return location;
    }).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<SavedIndoorLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(locations.map((location) => location.toJson()).toList());
    await prefs.setString(_storageKey, payload);
  }

  SavedIndoorLocation _normalize(SavedIndoorLocation location) {
    final safeRadius = _validatedRadius(location.radiusMeters);
    return location.copyWith(
      name: location.name.trim(),
      radiusMeters: safeRadius,
      enabled: location.enabled,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  double _validatedRadius(double radius) {
    if (radius.isNaN || radius.isInfinite || radius <= 0) {
      return 100.0;
    }
    return radius;
  }
}
