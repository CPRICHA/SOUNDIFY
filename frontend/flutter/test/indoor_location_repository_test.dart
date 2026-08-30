import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sound_accessibility_app/models/models.dart';
import 'package:sound_accessibility_app/services/indoor_location_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('indoor locations persist and support CRUD operations', () async {
    final repo = IndoorLocationRepository();

    final home = SavedIndoorLocation(
      id: 'home',
      name: 'Home',
      latitude: 12.9716,
      longitude: 77.5946,
      radiusMeters: 100,
      enabled: true,
    );

    await repo.addLocation(home);
    var all = await repo.getAllLocations();
    expect(all.length, 1);
    expect(all.first.name, 'Home');
    expect(all.first.radiusMeters, 100.0);

    final updated = home.copyWith(name: 'Home Updated', radiusMeters: 150, enabled: false);
    await repo.updateLocation(updated);
    final fetched = await repo.getLocation('home');
    expect(fetched?.name, 'Home Updated');
    expect(fetched?.radiusMeters, 150.0);
    expect(fetched?.enabled, false);

    await repo.setLocationEnabled('home', true);
    final enabled = await repo.getLocation('home');
    expect(enabled?.enabled, true);

    await repo.addLocation(
      SavedIndoorLocation(
        id: 'college',
        name: 'College',
        latitude: 12.98,
        longitude: 77.59,
        radiusMeters: 200,
        enabled: true,
      ),
    );

    all = await repo.getAllLocations();
    expect(all.length, 2);

    await repo.deleteLocation('home');
    all = await repo.getAllLocations();
    expect(all.length, 1);
    expect(all.first.id, 'college');
  });
}
