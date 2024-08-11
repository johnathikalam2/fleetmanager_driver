import 'package:mongo_dart/mongo_dart.dart';

String loggedInUserId = '';
Db? db;
DbCollection? collection_drivers;
DbCollection? collection_temp_vehicles;
DbCollection? collection_vehicles;
DbCollection? collection_trips;
DbCollection? collection_scratch;
DbCollection? collection_workshop;
DbCollection? collection_issues;
List<Map<String, dynamic>> globalTrips = [];