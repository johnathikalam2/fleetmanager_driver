class VehicleLocation {
  final double latitude;
  final double longitude;

  VehicleLocation({required this.latitude, required this.longitude});

  factory VehicleLocation.fromMap(Map<String, dynamic> map) {
    return VehicleLocation(
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}