import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:fleet_manager_driver_app/widget/toaster_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/trip.dart';
import '../model/user.dart';
import '../model/vehicle.dart';
import '../service/global.dart';


class LoginController extends GetxController{
  User? user;
  Trip? currentTrip;
  Vehicle? currentvehicle;
  RxBool isLoggedIn = false.obs;
  final pinController1 = TextEditingController();
  final pinController2 = TextEditingController();
  RxBool _obscureText1 = true.obs;
  RxBool _obscureText2 = true.obs;
  RxList<Trip> trips = RxList.empty();
  RxList<Vehicle> vehicles = RxList.empty();
  RxBool isloading = false.obs;

@override
  Future<void> onInit() async {
    super.onInit();
    isloading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userName') && prefs.containsKey('password') && prefs.containsKey('id'))
      print(prefs.getString('userName')!);
      loggedInUserId = prefs.getString('id')!;
      var driver = await collection_drivers?.findOne(where.eq('_id', ObjectId.parse(loggedInUserId)));
      if (driver != null) {
        isLoggedIn(true);

        List<String> trips = [];
        for (var trip in driver['trips']) {
        trips.add(trip);
      }
        user = User(
            driver['_id'].toHexString(),
            driver['driverUsername'],
            driver['driverPassword'],
            driver['pin'],
            driver['driverName'],
            driver['mobileNumber'],
            driver['location'],
            driver['driverLicenceNumber'],
            driver['driverLicenceExpiretDate'],
            driver['driverPhoto'],
            driver['notes'],
            driver['status'],
            trips,
        );
      }
    isLoggedIn(true);
    fetchTripsAndVehicles();
}

  Future<void> fetchTripsAndVehicles() async {
    var globalTrips = await collection_trips
        ?.find(where.eq('driverUsername', user?.userName))
        .toList();
    if (globalTrips != null) {
      for (var trip in globalTrips) {
        trips.add(Trip(
          trip['tripNumber'],
          trip['vehicleNumber'],
          trip['driverUsername'],
          trip['tripDate'],
          trip['tripStartTime'],
          trip['tripEndTime'],
          trip['tripRoute'],
          trip['vehicleLocation'],
          trip['tripType'],
          trip['tripRemunaration'],
          trip['notification'],
          trip['odometerStart'],
          trip['odometerEnd'],
          trip['fuelStart'],
          trip['fuelEnd'],
          trip['odometerStartImage'],
          trip['odometerEndImage'],
        ));

        if (!vehicles.any((car) => car.vehicleNumber == trip["vehicleNumber"])) {
          var vehicle = await collection_vehicles
              ?.findOne(where.eq('vehicleNumber', trip['vehicleNumber']));
          if (vehicle != null) {
            List<String> vehiclePhoto =
            List<String>.from(vehicle['vehiclePhotos'] ?? []);
            print(vehicle['vehicleName']);
            vehicles.add(Vehicle(
              vehicle['vehicleName'],
              vehicle['vehicleNumber'],
              vehicle['insuranceDueDate'],
              vehicle['istimaraDueDate'],
              vehicle['vehicleType'],
              vehicle['vehiclePhoto'],
              vehicle['ownVehicle'],
              vehicle['insurancePhoto'],
              vehicle['lastTyreChangeOdoReading'],
              vehicle['odometerReading'],
              vehicle['istimaraPhoto'],
              vehiclePhoto,
              vehicle['vehicleStatus'],
              vehicle['vehicleLocation'],
              vehicle['notesAboutVehicle'],
              vehicle['rentalAgreement'],
              vehicle['lastServiceDate'],
              vehicle['tireChangeDate'],
              vehicle['keyCustody'],
            ));
          }
        } else {
          print('Vehicle already added');
        }
      }
    }
    trips.sort((a, b) => a.tripDate.compareTo(b.tripDate));
    isloading(false);
    assignTrip();
  }

  void assignTrip() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // currentTrip = trips
    //     .where((trip) => trip.tripDate.year == today.year &&
    //     trip.tripDate.month == today.month &&
    //     trip.tripDate.day == today.day)
    //     .reduce((a, b) => a.tripDate.isBefore(b.tripDate) ? a : b);

    var filteredTrips = trips.where((trip) =>
    trip.tripDate.year == today.year &&
        trip.tripDate.month == today.month &&
        trip.tripDate.day == today.day
    );

    if (filteredTrips.isNotEmpty) {
      print('Filtered Trips: ${filteredTrips.length}');
      currentTrip = filteredTrips.reduce((a, b) => a.tripDate.isBefore(b.tripDate) ? a : b);
      if (currentTrip!.tripEndTime != null) {
        print('Current Trip: ${currentTrip!.tripNumber}');
      } else {
        print('No trips for today.');
      }
    } else {
      currentTrip = null;
    }
    if (currentTrip != null) {

      print('Current Trip: ${currentTrip!.tripNumber}');
      asignVehicle();
    } else {
      print('No trips for today.');
    }
  }

  void asignVehicle() {
    currentvehicle = vehicles.firstWhere(
            (vehicle) => vehicle.vehicleNumber == currentTrip?.vehicleNumber);
    if (currentvehicle != null) {
      print('Vehicle assigned: ${currentvehicle!.vehicleNumber}');
    } else {
      print('No vehicle assigned');
    }
  }

  login(usernameController, passwordController) async {
    isloading(true);
    var driver = await collection_drivers?.findOne(where.eq('driverUsername', usernameController.text));
      if (driver !=null){
        if (usernameController.text==driver['driverUsername'] && passwordController.text==driver['driverPassword']){
          loggedInUserId = driver['_id'].toHexString();
          List<String> trips = [];
          for (var trip in driver['trips']) {
            trips.add(trip);
          }
          user = User(
            driver['_id'].toHexString(),
            driver['driverUsername'],
            driver['driverPassword'],
            driver['pin'],
            driver['driverName'],
            driver['mobileNumber'],
            driver['location'],
            driver['driverLicenceNumber'],
            driver['driverLicenceExpiretDate'],
            driver['driverPhoto'],
            driver['notes'],
            driver['status'],
            trips,
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userName', usernameController.text);
          prefs.setString('password', passwordController.text);
          prefs.setString('id', loggedInUserId);
          fetchTripsAndVehicles();
          return user;
        }
      }

    return false;

  }


  showSetPinOverLay() async {
    Get.bottomSheet(
      SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                     Text(
                    'SET SECURITY PIN',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
                    ),

                    const SizedBox(height: 20),
                     Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(30),
                         color: greenlight.withOpacity(.1),
                       ),
                       child: Obx(() =>
                           TextFormField(
                         controller: pinController1,
                         obscureText: _obscureText1.value,
                         maxLength: 4,
                         keyboardType: TextInputType.number,
                         inputFormatters: <TextInputFormatter>[
                           FilteringTextInputFormatter.digitsOnly
                         ],
                        decoration: InputDecoration(
                          counterText: "",
                          prefixIcon: const Icon(Icons.password),
                          prefixIconColor: primary,
                          border: InputBorder.none,
                          labelText: 'PIN',
                          labelStyle: const TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText1.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primary,
                            ),
                            onPressed: () => _obscureText1.toggle(),
                          ),
                        ),
                       )
                       ),
                     ),
                    const SizedBox(height: 20),
                     Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(30),
                         color: greenlight.withOpacity(.1),
                       ),
                       child: Obx(() =>
                           TextFormField(
                          controller: pinController2,
                         obscureText: _obscureText2.value,
                         maxLength: 4,
                         keyboardType: TextInputType.number,
                         inputFormatters: <TextInputFormatter>[
                           FilteringTextInputFormatter.digitsOnly
                         ],
                        decoration: InputDecoration(
                          counterText: "",
                          prefixIcon: const Icon(Icons.password),
                          prefixIconColor: primary,
                          border: InputBorder.none,
                          labelText: 'CONFIRM PIN',
                          labelStyle: const TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText2.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primary,
                            ),
                            onPressed: () => _obscureText2.toggle(),
                          ),
                        ),
                       ),
                       ),
                     ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: greenlight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        if (pinController1.text == pinController2.text) {
                          await collection_drivers?.update(
                            where.eq('_id', ObjectId.parse(loggedInUserId)),
                            modify.set('pin', pinController1.text),
                          );
                          print(pinController1.text);
                          print('Pin set');
                          pinController1.clear();
                          pinController2.clear();

                          Get.back();
                        } else {
                          print('Pin not match');
                          createToastTop('Pin not match');
                        }
                      },
                      child: const Text('Set Pin', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}