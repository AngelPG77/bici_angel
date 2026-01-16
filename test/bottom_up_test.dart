import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; 
import 'package:bici_angel/repositories/station_repository.dart'; 
import 'package:bici_angel/models/station.dart';

void main() {
  group('Integración Ascendente: HTTP -> Repositorio -> Modelos', () {
    
    test('El Repositorio combina correctamente Info y Status de la API', () async {

      final mockInfoJson = '''
      {
        "data": {
          "stations": [
            {
              "station_id": "1",
              "name": "Estación Puerto", 
              "lat": 43.3, 
              "lon": -8.4, 
              "capacity": 20, 
              "address": "Av. Marina"
            }
          ]
        }
      }
      ''';
      final mockStatusJson = '''
      {
        "data": {
          "stations": [
            {
              "station_id": "1",
              "num_bikes_available": 5,
              "num_docks_available": 15,
              "last_reported": 1700000000,
              "status": "IN_SERVICE",
              "vehicle_types_available": [
                {"vehicle_type_id": "FIT", "count": 2}, 
                {"vehicle_type_id": "EFIT", "count": 3}
              ]
            }
          ]
        }
      }
      ''';

      final mockClient = MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('station_information')) {
          return http.Response(mockInfoJson, 200);
        } else if (url.contains('station_status')) {
          return http.Response(mockStatusJson, 200);
        }
        return http.Response('Not Found', 404);
      });

      final repository = StationRepositoryImpl(client: mockClient);

      final List<Station> result = await repository.getStations();

      expect(result.length, 1);
      
      final station = result.first;
      expect(station.name, "Estación Puerto");
      expect(station.address, "Av. Marina");
      expect(station.availableBikes, 5); 
      expect(station.mechanicalBikes, 2); 
      expect(station.electricBikes, 3);   
      expect(station.isActive, true);
    });
  });
}