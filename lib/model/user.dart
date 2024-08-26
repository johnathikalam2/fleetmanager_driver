class User{
  String id;
  String userName;
  String password;
  int? pin;
  String name;
  String mobile;
  String? location;
  String dlNumber;
  DateTime dlExpiry;
  String? profileImg;
  String? notes;
  String? status;
  List<String> trips;


  User(
      this.id,
      this.userName,
      this.password,
      this.pin,
      this.name,
      this.mobile,
      this.location,
      this.dlNumber,
      this.dlExpiry,
      this.profileImg,
      this.notes,
      this.status,
      this.trips,
      );
}