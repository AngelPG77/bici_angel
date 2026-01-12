import 'package:flutter_test/flutter_test.dart';
import 'package:bici_angel/models/station_info_dto.dart';

void main() {
  group('StationInfoDto', () {
    test('fromJson crea una instancia válida con JSON completo', () {
      final Map<String, dynamic> json = {
        'station_id': '123',
        'name': 'Estación Central',
        'address': 'Av. Principal 100',
        'capacity': 50,
        'lat': 40.7128,
        'lon': -74.0060,
      };

      final result = StationInfoDTO.fromJson(json);

      expect(result.stationId, '123');
      expect(result.name, 'Estación Central');
      expect(result.address, 'Av. Principal 100');
      expect(result.capacity, 50);
      expect(result.lat, 40.7128);
      expect(result.lon, -74.0060);
    });

    test(
      'fromJson asigna valores por defecto cuando los campos opcionales son nulos',
      () {
        final Map<String, dynamic> json = {
          'station_id': '456',
          'name': 'Estación Norte',
          'address': null,
          'capacity': null,
          'lat': 10.5,
          'lon': 20.5,
        };

        final result = StationInfoDTO.fromJson(json);

        expect(result.address, 'Sin dirección');
        expect(result.capacity, 0);
      },
    );

    test('fromJson maneja correctamente lat/lon si vienen como enteros', () {
      final Map<String, dynamic> json = {
        'station_id': '789',
        'name': 'Estación Sur',
        'address': 'Calle 1',
        'capacity': 10,
        'lat': 40,
        'lon': -74,
      };

      final result = StationInfoDTO.fromJson(json);

      expect(result.lat, 40.0);
      expect(result.lon, -74.0);
      expect(result.lat, isA<double>());
      expect(result.lon, isA<double>());
    });
  });
}
