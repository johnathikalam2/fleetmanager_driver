import 'dart:ffi';

class Trip{
  String tripNumber;
  String vehicleNumber;
  String driverUsername;
  DateTime tripDate;
  DateTime? tripStartTime;
  DateTime? tripEndTime;
  String tripRoute;
  String? vehicleLocation;
  String tripType;
  int tripRemunaration;
  String? notification;
  int? odometerStart;
  int? odometerEnd;
  int? fuelStart;
  int? fuelEnd;
  String? odometerStartImage;
  String? odometerEndImage;



  Trip(this.tripNumber,
      this.vehicleNumber,
      this.driverUsername,
      this.tripDate,
      this.tripStartTime,
      this.tripEndTime,
      this.tripRoute,
      this.vehicleLocation,
      this.tripType,
      this.tripRemunaration,
      this.notification,
      this.odometerStart,
      this.odometerEnd,
      this.fuelStart,
      this.fuelEnd,
      this.odometerStartImage,
      this.odometerEndImage,
      );
}