import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:bici_angel/repositories/station_repository.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) _handler;

  MockHttpClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  group('StationRepositoryImpl Tests', () {
    
    const infoUrl = 'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_information';

    test('mock client test básico', () async {
      final mockClient = MockHttpClient((request) async {
        print('URL solicitada: ${request.url}');
        final urlString = request.url.toString();
        
        if (urlString.contains('station_information')) {
          return http.Response(
            '{"data": {"stations": [{"station_id": "1", "name": "Test"}]}}', 
            200,
            headers: {
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }
        return http.Response('Not Found', 404);
      });

      final response = await mockClient.get(Uri.parse(infoUrl));
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      expect(response.statusCode, 200);
      expect(response.body, contains('station_id'));
    });

    test('getStations devuelve una lista de estaciones combinada y ordenada cuando la API responde 200', () async {
      
      final mockInfoBody = jsonEncode({
        "data": {
          "stations": [
            {
              "station_id": "1",
              "name": "B. Estación Segunda", 
              "address": "Calle Test 2",
              "capacity": 20,
              "lat": 43.0,
              "lon": -8.0
            },
            {
              "station_id": "2",
              "name": "A. Estación Primera", 
              "address": "Calle Test 1",
              "capacity": 10,
              "lat": 43.1,
              "lon": -8.1
            }
          ]
        }
      });

      final mockStatusBody = jsonEncode({
        "data": {
          "stations": [
            {
              "station_id": "1",
              "num_bikes_available": 5,
              "num_docks_available": 15,
              "num_docks_disabled": 0,
              "last_reported": 1700000000,
              "status": "IN_SERVICE",
              "vehicle_types_available": [
                {"vehicle_type_id": "FIT", "count": 2},
                {"vehicle_type_id": "EFIT", "count": 3}
              ]
            },
            {
              "station_id": "2",
              "num_bikes_available": 8,
              "num_docks_available": 2,
              "num_docks_disabled": 0,
              "last_reported": 1700000000,
              "status": "IN_SERVICE",
              "vehicle_types_available": [
                {"vehicle_type_id": "FIT", "count": 4},
                {"vehicle_type_id": "EFIT", "count": 4}
              ]
            }
          ]
        }
      });
      final mockClient = MockHttpClient((request) async {
        final urlString = request.url.toString();
        if (urlString.contains('station_information')) {
          return http.Response(mockInfoBody, 200);
        } else if (urlString.contains('station_status')) {
          return http.Response(mockStatusBody, 200);
        }
        return http.Response('Not Found', 404);
      });

      final repository = StationRepositoryImpl(client: mockClient);
      final result = await repository.getStations();

      expect(result.length, 2, reason: 'Debería devolver 2 estaciones');
      

      final station1 = result.firstWhere((s) => s.id == '1');
      expect(station1.name, "B. Estación Segunda"); 
      expect(station1.availableBikes, 5);           
      expect(station1.mechanicalBikes, 2); 

      final station2 = result.firstWhere((s) => s.id == '2');
      expect(station2.name, "A. Estación Primera");
      expect(station2.availableBikes, 8);
      expect(station2.mechanicalBikes, 4);        

      expect(result.first.name, "A. Estación Primera");
      expect(result.last.name, "B. Estación Segunda");
    });

    test('getStations lanza una excepción si alguna de las llamadas falla (ej. 404)', () async {

      final mockClient = MockHttpClient((request) async {
        final urlString = request.url.toString();
        if (urlString.contains('station_information')) {
          return http.Response('{"data": {"stations": []}}', 200);
        } else {
          return http.Response('Error del servidor', 500);
        }
      });

      final repository = StationRepositoryImpl(client: mockClient);

      expect(
        () async => await repository.getStations(),
        throwsException,
        reason: 'Debería fallar porque una de las respuestas no fue 200'
      );
    });
  });
}