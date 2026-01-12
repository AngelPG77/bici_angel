import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../models/station_info_dto.dart';
import '../models/station_status_dto.dart';

abstract class StationRepository {
  Future<List<Station>> getStations();
}

class StationRepositoryImpl implements StationRepository {
  final http.Client _client;
  static const String _infoUrl = 'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_information';
  static const String _statusUrl = 'https://acoruna.publicbikesystem.net/customer/gbfs/v2/gl/station_status';

  StationRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<Station>> getStations() async {
    try {
      final responses = await Future.wait([
        _client.get(Uri.parse(_infoUrl)),
        _client.get(Uri.parse(_statusUrl)),
      ]);

      if (responses[0].statusCode != 200 || responses[1].statusCode != 200) {
        throw Exception('Error al intentar conectar con API BiciCoruña');
      }

      final jsonInfo = json.decode(responses[0].body);
      final jsonStatus = json.decode(responses[1].body);

      final List<Map<String, dynamic>> listInfo = 
        List<Map<String, dynamic>>.from(jsonInfo['data']['stations'] as List);
      final List<Map<String, dynamic>> listStatus = 
        List<Map<String, dynamic>>.from(jsonStatus['data']['stations'] as List);

      final Map<String, StationStatusDTO> statusMap = {
        for (var item in listStatus)
          item['station_id']: StationStatusDTO.fromJson(item)
      };

      final List<Station> stations = [];

      for (var item in listInfo) {
        final infoDto = StationInfoDTO.fromJson(item);
        final statusDto = statusMap[infoDto.stationId];

        if (statusDto != null) {
          stations.add(Station(
            id: infoDto.stationId,
            name: infoDto.name,
            address: infoDto.address,
            totalCapacity: infoDto.capacity,
            availableBikes: statusDto.numBikesAvailable,
            mechanicalBikes: statusDto.mechanicalCount,
            electricBikes: statusDto.electricCount,
            availableDocks: statusDto.numDocksAvailable,
            disabledDocks: statusDto.numDocksDisabled, 
            lastUpdated: DateTime.fromMillisecondsSinceEpoch(statusDto.lastReported * 1000),
            isActive: statusDto.status == 'IN_SERVICE',
          ));
        }
      }
      
      stations.sort((a, b) => a.name.compareTo(b.name));
      return stations;

    } catch (e) {
      throw Exception('Error cargando datos: $e');
    }
  }
}