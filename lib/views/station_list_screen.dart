import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/station_list_view_model.dart';
import 'station_detail_screen.dart';

class StationListScreen extends StatelessWidget {
  const StationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiciCoruña', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar estación...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => context.read<StationListViewmodel>().searchStations(val),
            ),
          ),
          Expanded(
            child: Consumer<StationListViewmodel>(
              builder: (context, vm, _) {
                if (vm.isLoading) return const Center(child: CircularProgressIndicator());
                if (vm.errorMessage != null) return Center(child: Text(vm.errorMessage!));
                
                return RefreshIndicator(
                  onRefresh: vm.loadStations,
                  child: ListView.builder(
                    itemCount: vm.stations.length,
                    itemBuilder: (ctx, i) {
                      final station = vm.stations[i];
                      return ListTile(
                        leading: Icon(Icons.pedal_bike, 
                          color: station.availableBikes > 0 ? Colors.teal : Colors.grey),
                        title: Text(station.name),
                        subtitle: Text(station.address),
                        trailing: Text(
                          "${station.availableBikes}", 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                        ),
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => StationDetailScreen(station: station))
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}