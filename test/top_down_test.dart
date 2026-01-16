import 'package:flutter_test/flutter_test.dart';
import 'package:bici_angel/viewmodels/station_list_view_model.dart';
import 'package:bici_angel/repositories/station_repository.dart';
import 'package:bici_angel/models/station.dart';


class StubStationRepository implements StationRepository {
  final bool simulateError;

  StubStationRepository({this.simulateError = false});

  @override
  Future<List<Station>> getStations() async {

    await Future.delayed(const Duration(milliseconds: 10));

    if (simulateError) {
      throw Exception("Error de conexión simulado");
    }


    return [
      Station(
        id: '1',
        name: 'Estación Central',
        address: 'Av. Principal',
        totalCapacity: 20,
        availableBikes: 10,
        mechanicalBikes: 5,
        electricBikes: 5,
        availableDocks: 10,
        disabledDocks: 0,
        lastUpdated: DateTime.now(),
        isActive: true,
      ),
      Station(
        id: '2',
        name: 'Estación Norte', 
        address: 'Calle Lejana',
        totalCapacity: 15,
        availableBikes: 0,
        mechanicalBikes: 0,
        electricBikes: 0,
        availableDocks: 15,
        disabledDocks: 0,
        lastUpdated: DateTime.now(),
        isActive: true,
      ),
    ];
  }
}

void main() {
  group('2.2 Integración Descendente: ViewModel -> Repositorio', () {
    
    test('El ViewModel solicita datos al Repositorio y actualiza su estado correctamente', () async {
      final stubRepo = StubStationRepository(simulateError: false);

      final viewModel = StationListViewmodel(repository: stubRepo);

      expect(viewModel.isLoading, true);

      await Future.delayed(const Duration(milliseconds: 15));

      expect(viewModel.isLoading, false); 
      expect(viewModel.stations.length, 2); 
      expect(viewModel.stations.first.name, 'Estación Central');
    });

    test('El ViewModel filtra correctamente los datos recibidos del Repositorio', () async {
      final stubRepo = StubStationRepository();
      final viewModel = StationListViewmodel(repository: stubRepo);
      
      await Future.delayed(const Duration(milliseconds: 15));


      viewModel.searchStations('Norte');

      expect(viewModel.stations.length, 1);
      expect(viewModel.stations.first.name, 'Estación Norte');
    });

    test('El ViewModel maneja correctamente una excepción lanzada por el Repositorio', () async {
      final stubRepo = StubStationRepository(simulateError: true);
      final viewModel = StationListViewmodel(repository: stubRepo);

      await Future.delayed(const Duration(milliseconds: 15));

      expect(viewModel.stations, isEmpty);
      expect(viewModel.errorMessage, contains("No se pudieron cargar datos"));
    });
  });
}