import 'package:flutter/material.dart';
import '../models/station.dart';

class StationDetailScreen extends StatelessWidget {
  final Station station;
  const StationDetailScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final timeStr = "${station.lastUpdated.hour}:${station.lastUpdated.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: Text(station.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: station.availableBikes > 0 ? Colors.teal : Colors.grey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text("BICIS DISPONIBLES", style: TextStyle(color: Colors.white70)),
                  Text("${station.availableBikes}", 
                    style: const TextStyle(fontSize: 64, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _infoCard("Mecánicas", station.mechanicalBikes, Icons.pedal_bike, Colors.blueGrey)),
                const SizedBox(width: 16),
                Expanded(child: _infoCard("Eléctricas", station.electricBikes, Icons.electric_bolt, Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                children: [
                  _row("Anclajes Libres", "${station.availableDocks}", Colors.black),

                  if (station.disabledDocks > 0) ...[
                    const Divider(),
                    _row("Puestos Rotos", "${station.disabledDocks}", Colors.red),
                  ],
                  
                  const Divider(),
                  _row("Capacidad Total", "${station.totalCapacity}", Colors.grey),
                  const Divider(),
                  _row("Actualizado", timeStr, Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          Text("$count", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _row(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}