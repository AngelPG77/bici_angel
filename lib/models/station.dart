class Station {
  final String id;
  final String name;
  final String address;        
  final int totalCapacity;    
  
  final int availableBikes;    
  final int mechanicalBikes;   
  final int electricBikes;     
  final int availableDocks;    
  final int disabledDocks;     
  
  final DateTime lastUpdated;  
  final bool isActive;         

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.totalCapacity,
    required this.availableBikes,
    required this.mechanicalBikes,
    required this.electricBikes,
    required this.availableDocks,
    required this.disabledDocks,
    required this.lastUpdated,
    this.isActive = true,
  });

  bool get hasProblem => !isActive; 
}