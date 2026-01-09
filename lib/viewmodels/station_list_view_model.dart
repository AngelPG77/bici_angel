import 'package:flutter/foundation.dart';
import '../models/station.dart';
import '../repositories/station_repository.dart';

class StationListViewmodel extends ChangeNotifier {
  final StationRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Station> _allStations = [];
  List<Station> _filteredStations = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Station> get stations => _filteredStations;

  StationListViewmodel({required StationRepository repository}) : _repository = repository {
    loadStations();
  }

  Future<void> loadStations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getStations();
      _allStations = result;
      _filteredStations = result;
    } catch (e) {
      _errorMessage = "No se pudieron cargar datos.\nRevisa tu conexión.";
      _allStations = [];
      _filteredStations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchStations(String query) {
    if (query.isEmpty) {
      _filteredStations = _allStations;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredStations = _allStations.where((station) {
        return station.name.toLowerCase().contains(lowerQuery) || 
               station.address.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }
}