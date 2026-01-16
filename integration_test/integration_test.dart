import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:bici_angel/repositories/station_repository.dart';
import 'package:bici_angel/viewmodels/station_list_view_model.dart';
import 'package:bici_angel/views/station_list_screen.dart';
import 'package:bici_angel/models/station.dart';

class StubSystemRepository implements StationRepository {
  @override
  Future<List<Station>> getStations() async {
    // Simulamos un pequeño delay realista de red
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Station(
        id: '1',
        name: 'Estación E2E Test',
        address: 'Plaza del Sistema',
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
        name: 'Estación Secundaria',
        address: 'Calle Fondo',
        totalCapacity: 10,
        availableBikes: 2,
        mechanicalBikes: 1,
        electricBikes: 1,
        availableDocks: 8,
        disabledDocks: 0,
        lastUpdated: DateTime.now(),
        isActive: true,
      ),
    ];
  }
}

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flujo Completo: Carga Lista -> Navega a Detalle -> Vuelve', (tester) async {

    final stubRepo = StubSystemRepository();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StationRepository>(create: (_) => stubRepo),
          ChangeNotifierProvider<StationListViewmodel>(
            create: (ctx) => StationListViewmodel(repository: ctx.read<StationRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'BiciCoruña Test',
          theme: ThemeData(primarySwatch: Colors.teal),
          home: const StationListScreen(), 
          debugShowCheckedModeBanner: false,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);

    final stationFinder = find.text('Estación E2E Test');
    expect(stationFinder, findsOneWidget);
    expect(find.text('Plaza del Sistema'), findsOneWidget);

    await tester.tap(stationFinder);
    await tester.pumpAndSettle();

    expect(find.text('BICIS DISPONIBLES'), findsOneWidget);
    expect(find.text('10'), findsAtLeastNWidgets(1)); 
    
    await tester.pageBack();
    
    await tester.pumpAndSettle();

    expect(find.text('Estación E2E Test'), findsOneWidget);
  });
}