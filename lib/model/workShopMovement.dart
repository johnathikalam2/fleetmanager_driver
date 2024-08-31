class workshopMovement{
  String vehicleNumber;
  DateTime workshopVisitDate;
  String? visitType;
  String nextOilChange;
  String nextTyreChange;
  int? noOfDays;
  int odometerReading;
  String? complaintDetail;
  int? amountSpent;

  workshopMovement(
    this.vehicleNumber,
    this.workshopVisitDate,
    this.visitType,
    this.nextOilChange,
    this.nextTyreChange,
      this.noOfDays,
    this.odometerReading,
    this.complaintDetail,
    this.amountSpent,
  );
}