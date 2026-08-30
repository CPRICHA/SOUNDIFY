import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';

class IndoorLocationMapPickerScreen extends StatefulWidget {
  const IndoorLocationMapPickerScreen({
    super.key,
    this.existing,
    this.initialLatitude,
    this.initialLongitude,
  });

  final SavedIndoorLocation? existing;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<IndoorLocationMapPickerScreen> createState() => _IndoorLocationMapPickerScreenState();
}

class _IndoorLocationMapPickerScreenState extends State<IndoorLocationMapPickerScreen> {
  final MapController _mapController = MapController();
  late double _selectedLatitude;
  late double _selectedLongitude;
  bool _isReady = false;

  static const double _fallbackLatitude = 12.9716;
  static const double _fallbackLongitude = 77.5946;

  @override
  void initState() {
    super.initState();
    _selectedLatitude = widget.initialLatitude ?? widget.existing?.latitude ?? _fallbackLatitude;
    _selectedLongitude = widget.initialLongitude ?? widget.existing?.longitude ?? _fallbackLongitude;
    _initializeMapCenter();
  }

  Future<void> _initializeMapCenter() async {
    double lat = _selectedLatitude;
    double lng = _selectedLongitude;

    if (widget.existing == null) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
          lat = position.latitude;
          lng = position.longitude;
        } catch (_) {
          lat = _fallbackLatitude;
          lng = _fallbackLongitude;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _selectedLatitude = lat;
      _selectedLongitude = lng;
      _isReady = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(lat, lng), 17.0);
    });
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    setState(() {
      _selectedLatitude = camera.center.latitude;
      _selectedLongitude = camera.center.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(_selectedLatitude, _selectedLongitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose on Map'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 17,
              onPositionChanged: (camera, hasGesture) => _onMapMoved(camera, hasGesture),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sound_accessibility_app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 28,
                    height: 28,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected location',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('Lat: ${_selectedLatitude.toStringAsFixed(6)}'),
                  Text('Lng: ${_selectedLongitude.toStringAsFixed(6)}'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'latitude': _selectedLatitude,
                    'longitude': _selectedLongitude,
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFF5B4FE8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Use This Location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
