class TempVehicle{
  //String driverId;
  String vehicleNumber;
  String vehiclePhoto;
  String vehicleName;
  String vechileType;
  int odometerReading;

  TempVehicle(
      //this.driverId,
      this.vehicleNumber,
      this.vehiclePhoto,
      this.vehicleName,
      this.vechileType,
      this.odometerReading,
      );

  Map<String, dynamic> toJson() => {
    'vehicleNumber': vehicleNumber,
    'vehiclePhoto': vehiclePhoto,
    'vehicleName': vehicleName,
    'vechileType': vechileType,
    'odometerReading': odometerReading,
  };
}