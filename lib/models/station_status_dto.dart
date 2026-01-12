class StationStatusDTO {
  final String stationId;
  final int numBikesAvailable;
  final int numDocksAvailable;
  final int numDocksDisabled; 
  final int lastReported;
  final String status;
  final int mechanicalCount;
  final int electricCount;

  StationStatusDTO({
    required this.stationId,
    required this.numBikesAvailable,
    required this.numDocksAvailable,
    required this.numDocksDisabled,
    required this.lastReported,
    required this.status,
    required this.mechanicalCount,
    required this.electricCount,
  });

  factory StationStatusDTO.fromJson(Map<String, dynamic> json) {
    int mech = 0;
    int elec = 0;

    if (json['vehicle_types_available'] != null) {
      final types = json['vehicle_types_available'] as List;
      for (var t in types) {
        final typeId = t['vehicle_type_id'] as String?;
        final count = (t['count'] as num?)?.toInt() ?? 0;

        if (typeId == 'FIT') {
          mech += count;
        } else if (typeId == 'EFIT' || typeId == 'BOOST') {
          elec += count;
        }
      }
    }

    return StationStatusDTO(
      stationId: json['station_id'] as String,
      numBikesAvailable: (json['num_bikes_available'] as num?)?.toInt() ?? 0,
      numDocksAvailable: (json['num_docks_available'] as num?)?.toInt() ?? 0,
      numDocksDisabled: (json['num_docks_disabled'] as num?)?.toInt() ?? 0, 
      lastReported: (json['last_reported'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'UNKNOWN',
      mechanicalCount: mech,
      electricCount: elec,
    );
  }
}