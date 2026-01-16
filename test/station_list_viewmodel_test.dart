import 'package:flutter_test/flutter_test.dart';
import 'package:bici_angel/viewmodels/station_list_view_model.dart';
import 'package:bici_angel/models/station.dart';
import 'package:bici_angel/repositories/station_repository.dart';

class MockStationRepository implements StationRepository {
  bool shouldFail = false;

  List<Station> mockData = [];

  @override
  Future<List<Station>> getStations() async {
    await Future.delayed(const Duration(milliseconds: 10));

    if (shouldFail) {
      throw Exception('Failed to fetch stations');
    }
    return mockData;
  }
}

void main() {
  final Station stationA = Station(
    id: '1',
    name: 'Station A',
    address: 'Address A',
    totalCapacity: 10,
    availableBikes: 5,
    mechanicalBikes: 3,
    electricBikes: 2,
    availableDocks: 5,
    disabledDocks: 0,
    lastUpdated: DateTime.now(),
  );

  final Station stationB = Station(
    id: '2',
    name: 'Station B',
    address: 'Address B',
    totalCapacity: 15,
    availableBikes: 10,
    mechanicalBikes: 6,
    electricBikes: 4,
    availableDocks: 5,
    disabledDocks: 0,
    lastUpdated: DateTime.now(),
  );

  group('StationListViewModel Tests', () {
    late MockStationRepository mockRepository;

    setUp(() {
      mockRepository = MockStationRepository();
    });

    test('Inicializa cargando datos correctamente del repositorio', () async {
      mockRepository.mockData = [stationA, stationB];
      mockRepository.shouldFail = false;

      final viewModel = StationListViewmodel(repository: mockRepository);

      expect(viewModel.isLoading, true);

      await Future.delayed(const Duration(milliseconds: 15));

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.stations.length, 2);
      expect(viewModel.stations.first.name, 'Station A');
    });

    test('Carga de estaciones fallida con manejo de error adecuado', () async {
      mockRepository.shouldFail = true;

      final viewModel = StationListViewmodel(repository: mockRepository);

      expect(viewModel.isLoading, true);

      await Future.delayed(const Duration(milliseconds: 15));

      expect(viewModel.isLoading, false);
      expect(viewModel.stations.length, 0);
      expect(viewModel.errorMessage, isNotNull);
    });

   test('searchStations filtra la lista correctamente', () async {

      mockRepository.mockData = [stationA, stationB];
      final viewModel = StationListViewmodel(repository: mockRepository);
      await Future.delayed(const Duration(milliseconds: 15)); 

      viewModel.searchStations('Station A');

      expect(viewModel.stations.length, 1);
      expect(viewModel.stations.first.name, 'Station A');
      viewModel.searchStations('Station C');
      expect(viewModel.stations, isEmpty);
      viewModel.searchStations('');
      expect(viewModel.stations.length, 2); 
    });

  });
}
