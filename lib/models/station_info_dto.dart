class StationInfoDTO {
  final String stationId;
  final String name;
  final String address;
  final int capacity;
  final double lat;
  final double lon;

  StationInfoDTO({
    required this.stationId,
    required this.name,
    required this.address,
    required this.capacity,
    required this.lat,
    required this.lon,
  });

  factory StationInfoDTO.fromJson(Map<String, dynamic> json) {
    return StationInfoDTO(
      stationId: json['station_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? 'Sin dirección',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}