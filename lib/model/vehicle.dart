class Vehicle{
  String vehicleName;
  String vehicleNumber;
  DateTime insuranceDueDate;
  DateTime istimaraDueDate;
  String vehicleType;
  String vehiclePhoto;
  bool ownVehicle;
  String insurancePhoto;
  int lastTyreChangeOdoReading;
  int odometerReading;
  String istimaraPhoto;
  List<String>  vehiclePhotos;
  String vehicleStatus;
  String vehicleLocation;
  String notesAboutVehicle;
  String rentalAgreement;
  DateTime lastServiceDate;
  DateTime tireChangeDate;
  String keyCustody;

  Vehicle(
  this.vehicleName,
  this.vehicleNumber,
  this.insuranceDueDate,
  this.istimaraDueDate,
  this.vehicleType,
  this.vehiclePhoto,
  this.ownVehicle,
  this.insurancePhoto,
  this.lastTyreChangeOdoReading,
  this.odometerReading,
  this.istimaraPhoto,
  this.vehiclePhotos,
  this.vehicleStatus,
  this.vehicleLocation,
  this.notesAboutVehicle,
  this.rentalAgreement,
      this.lastServiceDate,
      this.tireChangeDate,
      this.keyCustody,
      );
  Map<String, dynamic> toJson() => {
    'vehicleNumber': vehicleNumber,
    'vehicleName': vehicleName,
    'insuranceDueDate': insuranceDueDate,
    'istimaraDueDate': istimaraDueDate,
    'vehicleType': vehicleType,
    'vehiclePhoto': vehiclePhoto,
    'ownVehicle': ownVehicle,
    'insurancePhoto': insurancePhoto,
    'lastTyreChangeOdoReading': lastTyreChangeOdoReading,
    'odometerReading': odometerReading,
    'istimaraPhoto': istimaraPhoto,
    'vehiclePhotos': vehiclePhotos,
    'vehicleStatus': vehicleStatus,
    'vehicleLocation': vehicleLocation,
    'notesAboutVehicle': notesAboutVehicle,
    'rentalAgreement': rentalAgreement,
    'lastServiceDate': lastServiceDate,
    'tireChangeDate': tireChangeDate,
  };
}