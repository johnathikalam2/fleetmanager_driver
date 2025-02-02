
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'constants.dart';
import 'global.dart';

class MongoDB {
  static Future<Map<String, dynamic>> connect() async {
    db = await Db.create(MONGO_URL);
    await db!.open();
    var collection_drivers = db!.collection(COLLECTION_DRIVERS);
    collection_temp_vehicles = db!.collection(COLLECTION_TEMPVEHICLES);
    collection_trips = db!.collection(COLLECTION_TRIPS);
    collection_vehicles = db!.collection(COLLECTION_VEHICLES);
    collection_scratch = db!.collection(COLLECTION_SCRATCHS);
    collection_workshop = db!.collection(COLLECTION_WORKSHOPS);
    collection_issues = db!.collection(COLLECTION_ISSUES);
    collection_charts = db!.collection(COLLECTION_CHARTS);

    var driver = await collection_drivers?.findOne(where.eq('driverId', 'DR000'));
    if (driver !=null){
      print(driver['driverId']);
      print(driver['driverPassword']);
      print(driver['driverName']);
    }
    else{
      print("no driver with driverId DR000");
    }

      print('Connected to MongoDB');
      return {
        'db': db,
        'collection_drivers': collection_drivers,
      };
    }
  }

Future<void> updateTempVehicleReading(vehicleNumber, odometerReading) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify
      .set('odometerReading', odometerReading,);
  await collection_temp_vehicles?.updateOne(query, update);
}

Future<void> updateVehicleReading(vehicleNumber, odometerReading) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify
      .set('odometerReading', int.parse(odometerReading));
  await collection_vehicles?.updateOne(query, update);
}
Future<void> updateKeyCustody(vehicleNumber, keyCustody) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify
      .set('keyCustody', keyCustody);
  await collection_vehicles?.updateOne(query, update);
}
Future<void> updateLocation(vehicleNumber, latitude, longitude) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify.set('vehicleLocation', {
    'latitude': latitude,
    'longitude': longitude,
  });
  await collection_vehicles?.updateOne(query, update);
}
Future<void> updateTripBegin(tripNumber, odometerReading, fuelReading, image) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify
      .set('odometerStart', int.parse(odometerReading),)
      .set('fuelStart', int.parse(fuelReading))
      .set('odometerStartImage', image,);
  await collection_trips?.updateOne(query, update);
}
Future<void> updateTripEnd(tripNumber, odometerReading, fuelReading, image) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify
      .set('odometerEnd', int.parse(odometerReading),)
      .set('fuelEnd', int.parse(fuelReading))
      .set('odometerEndImage', image,);
  await collection_trips?.updateOne(query, update);
}
Future<void> updateTripStatus(driverUsername, status) async {
  final query = where.eq('driverId', driverUsername);
  final update = modify.set('status', status,);
  await collection_drivers?.updateOne(query, update);
}

Future<void> updateTripStartTime(tripNumber) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify
      .set('tripStartTimeDriver', DateTime.now(),);
  await collection_trips?.updateOne(query, update);
}

Future<void> updateTripEndTime(tripNumber) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify
      .set('tripEndTimeDriver', DateTime.now(),);
  await collection_trips?.updateOne(query, update);
}

Future<void> updateChartData(id, totalHours, date) async {
  final query = where.eq('driverId', ObjectId.parse(id));
  final update = modify
      .set('totalHours', totalHours,)
      .push('date', date,);
  await collection_charts?.updateOne(query, update);
}
Future<void> reportIssue(String tripNumber, String vehicleNumber, String driverUsername, String issueType, String issueDetail, String issueImage) async {
  final newIssue = {
    'tripNumber': tripNumber,
    'vehicleNumber': vehicleNumber,
    'driverId': driverUsername,
    'issueType': issueType,
    'issueDetail': issueDetail,
    'issueImage': issueImage,
    'timestamp': DateTime.now()
  };

  await collection_issues?.insertOne(newIssue);
}