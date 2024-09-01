import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fleet_manager_driver_app/model/vehicle.dart';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/login_controller.dart';
import '../controller/navigation_controller.dart';
import '../service/database.dart';
import '../widget/toaster_message.dart';
import 'main_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.vehicle,{Key? key}) : super(key: key);
  final Vehicle vehicle;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}
Rx<File?> _imageFile = Rx<File?>(null);
Rx<File?> _odometerimageFile = Rx<File?>(null);
Rx<File?> _SOSimageFile = Rx<File?>(null);

String? _issueSelection;

class _NavigationScreenState extends State<NavigationScreen> {

  NavigationController controller = Get.put(NavigationController());
  LoginController loginController = Get.put(LoginController());

  RxBool _obscureTextPin = true.obs;
  late final Vehicle selectedVehicle;
  final odometerController = TextEditingController();
  final fuelController = TextEditingController();

  LatLng _selectedLocation = LatLng(9.175249926873791, 76.5014099702239);
  String? _currentPlaceName;
  String? _currentPlaceStreet;
  String? _currentPlaceAdministrativeArea;
  String? _currentPlaceCountry;
  String? _currentPlacePostalCode;
  String? _currentPlaceSubLocality;
  String? _currentPlaceLocality;
  String? _currentPlaceSubAdministrativeArea;
  String? _currentPlaceIsoCountryCode;
  String? _currentPlaceSubThoroughfare;
  String? _currentPlaceThoroughfare;


  @override
  void initState() {
    super.initState();
    selectedVehicle = widget.vehicle;
    _selectedLocation = selectedVehicle.vehicleLocation != null
        ? LatLng(selectedVehicle.vehicleLocation!.latitude, selectedVehicle.vehicleLocation!.longitude)
        : LatLng(9.175249926873791, 76.5014099702239);
    locationDetails();
    //snackbarMessage("Please select the location on the map");
  }

  double calculateTotalHours(DateTime startTime, DateTime endTime) {
    Duration duration = endTime.difference(startTime);
    return duration.inHours + (duration.inMinutes % 60) / 60.0;
  }

  void snackbarMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: secondary,
      content: Text(message, style: GoogleFonts.lato(color: primary, fontSize: 15, fontWeight: FontWeight.w600)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _onMapTapped(LatLng location) async {
    await updateLocation(widget.vehicle.vehicleNumber, location.latitude, location.longitude);
    List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude, location.longitude
    );
    setState(() {
      _selectedLocation = location;
      _currentPlaceName = placemarks[0].name ?? "";
      _currentPlaceStreet = placemarks[0].street ?? "";
      _currentPlaceAdministrativeArea = placemarks[0].administrativeArea ?? "";
      _currentPlaceCountry = placemarks[0].country ?? "";
      _currentPlacePostalCode = placemarks[0].postalCode ?? "";
      _currentPlaceSubLocality = placemarks[0].subLocality ?? "";
      _currentPlaceLocality = placemarks[0].locality ?? "";
      _currentPlaceSubAdministrativeArea = placemarks[0].subAdministrativeArea ?? "";
      _currentPlaceIsoCountryCode = placemarks[0].isoCountryCode ?? "";
      _currentPlaceSubThoroughfare = placemarks[0].subThoroughfare ?? "";
      _currentPlaceThoroughfare = placemarks[0].thoroughfare ?? "";



    });
    print('Selected location: ${location.latitude}, ${location.longitude}');
  }

  Future<void> locationDetails() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude, _selectedLocation.longitude
    );
    setState(() {
      _currentPlaceName = placemarks[0].name ?? "";
      _currentPlaceStreet = placemarks[0].street ?? "";
      _currentPlaceAdministrativeArea = placemarks[0].administrativeArea ?? "";
      _currentPlaceCountry = placemarks[0].country ?? "";
      _currentPlacePostalCode = placemarks[0].postalCode ?? "";
      _currentPlaceSubLocality = placemarks[0].subLocality ?? "";
      _currentPlaceLocality = placemarks[0].locality ?? "";
      _currentPlaceSubAdministrativeArea = placemarks[0].subAdministrativeArea ?? "";
      _currentPlaceIsoCountryCode = placemarks[0].isoCountryCode ?? "";
      _currentPlaceSubThoroughfare = placemarks[0].subThoroughfare ?? "";
      _currentPlaceThoroughfare = placemarks[0].thoroughfare ?? "";



    });
  }


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile.value = File(image.path);
      });
    }
  }
  Future<void> _pickImageSOS() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _SOSimageFile.value = File(image.path);
      });
    }
  }

  Future<void> _pickOdometerImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _odometerimageFile.value = File(image.path);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: Container(
        //margin: const EdgeInsets.only(top:10),
        //height: MediaQuery.of(context).size.height*.65,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: greenlight, width: 2),
            left: BorderSide(color: greenlight, width: 2),
            right: BorderSide(color: greenlight, width: 2),
            bottom: BorderSide(color: greenlight, width: 2),
          ),
        ),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _selectedLocation,
            zoom: 15,
          ),
          onTap: _onMapTapped,
          markers: {
            Marker(
              markerId: MarkerId('selected_location'),
              position: _selectedLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: '$_currentPlaceName',
                snippet: 'Lat: ${_selectedLocation.latitude.toPrecision(
                    2)}, Lng: ${_selectedLocation.longitude.toPrecision(2)}',
              ),
            ),
          }
        ),
      ),
      floatingActionButton: Stack(
        children:<Widget> [
          Positioned(
            right: 5,
            bottom: 50,
            child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                padding: const EdgeInsets.only(left:4,right:4,top:4,bottom:45),
                child: FloatingActionButton(
                  backgroundColor: primary,
                  onPressed: () {
                    showDetailOverLay();
                  },
                  child: const Icon(Icons.menu_rounded, color: Colors.white, size: 30,),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
          ),
          Positioned(
            right: 5,
            bottom: 120,
            child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                padding: const EdgeInsets.only(left:4,right:4,top:4,bottom:45),
                child: FloatingActionButton(
                  backgroundColor: Colors.red[700],
                  onPressed: () {
                    print("Dashboard");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildSosAlert();
                      },
                    );
                  },
                  child: const Icon(Icons.sos, color: Colors.white, size: 30,),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
          ),
          Positioned(
            right: 5,
            bottom: 190, // Adjust this value as needed
            child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                padding: const EdgeInsets.only(left:4,right:4,top:4,bottom:45),
                child: FloatingActionButton(
                  backgroundColor: greenlight,
                  onPressed: () {
                    controller.callHelp();
                  },
                  child: const Icon(Icons.call, color: Colors.white, size: 30,),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
          ),
          // Positioned(
          //   right: 5,
          //   bottom: 260, // Adjust this value as needed
          //   child: Container(
          //     decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
          //     padding: const EdgeInsets.only(left:4,right:4,top:4,bottom:45),
          //     child: FloatingActionButton(
          //       backgroundColor: Colors.white,
          //       onPressed: () {
          //         showDialog(
          //           context: context,
          //           builder: (BuildContext context) {
          //             return WidgetbuildLocation();
          //           },
          //         );
          //       },
          //       child: const Icon(Icons.location_pin, color: Colors.red, size: 30,),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(100.0),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      )
    );
  }

  WidgetbuildLocation(){
    return SingleChildScrollView(
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: secondary,
                title: Center(child: Text("LOCATION", style: GoogleFonts.lato(color: primary, fontSize: 18, fontWeight: FontWeight.w700))),
                content: Column(
                  children: [
                    _currentPlaceName == ''?SizedBox(height: 0,):Text(_currentPlaceName!,style: TextStyle(color: greenlight),),
                    _currentPlaceStreet == ''?SizedBox(height: 0,):Text(_currentPlaceStreet!,style: TextStyle(color: greenlight),),
                    _currentPlacePostalCode == ''?SizedBox(height: 0,):Text(_currentPlacePostalCode!,style: TextStyle(color: greenlight),),
                    _currentPlaceSubLocality == ''?SizedBox(height: 0,):Text(_currentPlaceSubLocality!,style: TextStyle(color: greenlight),),
                    _currentPlaceLocality == ''?SizedBox(height: 0,):Text(_currentPlaceLocality!,style: TextStyle(color: greenlight),),
                    _currentPlaceSubAdministrativeArea == ''?SizedBox(height: 0,):Text(_currentPlaceSubAdministrativeArea!,style: TextStyle(color: greenlight),),
                    _currentPlaceSubThoroughfare == ''?SizedBox(height: 0,):Text(_currentPlaceSubThoroughfare!,style: TextStyle(color: greenlight),),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _currentPlaceAdministrativeArea == ''?SizedBox(height: 0,):Text('${_currentPlaceAdministrativeArea!},',style: TextStyle(color: greenlight),),
                          SizedBox(width: 5,),
                          _currentPlaceCountry == ''?SizedBox(height: 0,):Text(_currentPlaceCountry!,style: TextStyle(color: greenlight),),
                          SizedBox(width: 5,),
                          _currentPlaceIsoCountryCode == ''?SizedBox(height: 0,):Text('(${_currentPlaceIsoCountryCode!})',style: TextStyle(color: greenlight),),
                        ]
                    ),
                  ],
                ),
                  actions: [
                  TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    },
                    child: Text("Ok", style: TextStyle(color: greenlight, fontSize: 15, fontWeight: FontWeight.w600),),
                  ),
                  ],
              );
            }
        )
    );
  }
  Widget buildSosAlert() {
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: secondary,
            title: Center(child: Text("SOS ALERT", style: GoogleFonts.lato(color: primary, fontSize: 18, fontWeight: FontWeight.w700))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    labelText: 'Enter your message',
                    labelStyle: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w500),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary.withOpacity(.7)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary),
                    ),
                  ),
                ),
                SizedBox(height: 20,),

                Obx(() =>
                _SOSimageFile.value != null
                    ?
                Image.file(_SOSimageFile.value!)
                    : Container(),
                ),

                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: WidgetStateProperty.all(primary),
                    ),
                    onPressed: () async {
                      await _pickImageSOS();
                      setState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 18,),
                        const SizedBox(width: 10),
                        Text(
                          'ADD  IMAGE',
                          style: GoogleFonts.lato(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _imageFile = Rx<File?>(null);
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL", style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),),
              ),

              TextButton(
                onPressed: () async {
                  if(controller.messageController.text!='' && _SOSimageFile != null) {
                    try {
                      final Uint8List bytes = await _SOSimageFile.value!.readAsBytes();
                      String base64Image = base64Encode(bytes);
                      await reportIssue(
                          loginController.currentTrip!.tripNumber,
                          selectedVehicle.vehicleNumber,
                          loginController.user!.userName,
                          "SOS",
                          controller.messageController.text,
                          base64Image);
                    }catch(e){
                      print("Error ${e}");
                    }

                    _SOSimageFile = Rx<File?>(null);
                    controller.messageController.clear();
                  } else {
                    createToastTop("Please fill all the emergency fields");
                  }
                  _SOSimageFile = Rx<File?>(null);
                  controller.messageController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("SUBMIT", style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget buildStopAlert() {
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: secondary,
            title: Center(child: Text("STOP", style: GoogleFonts.lato(color: primary, fontSize: 18, fontWeight: FontWeight.w700))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                controller: odometerController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: "Odometer Reading",
                  labelStyle: TextStyle(color: primary, fontSize: 13,fontWeight: FontWeight.w500),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primary.withOpacity(.7)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primary),
                  ),
                ),
              ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: fuelController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: 'Fuel Level',
                    labelStyle: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w500),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary.withOpacity(.7)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary),
                    ),
                  ),
                ),
                SizedBox(height: 20,),

                Obx(() =>
                _odometerimageFile.value != null
                    ?
                Image.file(_odometerimageFile.value!)
                    : Container(),
                ),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: WidgetStateProperty.all(primary),
                    ),
                    onPressed: () async {
                      await _pickOdometerImage();
                      setState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 18,),
                        const SizedBox(width: 10),
                        Text(
                          'ODOMETER  IMAGE',
                          style: GoogleFonts.lato(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15,),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Do you want to report any issues?', style: TextStyle(color: primary, fontWeight: FontWeight.w500)),
                ),
                RadioListTile<String>(
                  title: const Text('Yes', style: TextStyle(color: primary,fontSize: 14, fontWeight: FontWeight.w500)),
                  value: 'yes',

                  groupValue: _issueSelection,
                  onChanged: (value) {
                    setState(() {
                      _issueSelection = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('No', style: TextStyle(color: primary,fontSize: 14, fontWeight: FontWeight.w500)),
                  value: 'no',
                  groupValue: _issueSelection,
                  onChanged: (value) {
                    setState(() {
                      _issueSelection = value;
                    });
                  },
                ),
                if (_issueSelection == 'yes') ...[
                  TextFormField(
                    controller: controller.issueController,
                    decoration: InputDecoration(
                      labelText: 'Enter your issue',
                      labelStyle: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w500),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primary.withOpacity(.7)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Obx(() =>
                  _imageFile.value != null
                      ?
                  Image.file(_imageFile.value!)
                      : Container(),
                  ),

                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                        backgroundColor: WidgetStateProperty.all(primary),
                      ),
                      onPressed: () async {
                        await _pickImage();
                        setState(() {});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 18,),
                          const SizedBox(width: 10),
                          Text(
                            'SCRATCH  IMAGE',
                            style: GoogleFonts.lato(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  odometerController.clear();
                  fuelController.clear();
                  controller.issueController.clear();
                   _odometerimageFile = Rx<File?>(null);
                  _imageFile = Rx<File?>(null);
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL", style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),),
              ),
              TextButton(
                onPressed: () async {
                  if(odometerController.text!='' && fuelController.text!='' && _odometerimageFile != null) {
                    bool pinValidity = await showCheckPinOverLay();
                    if (pinValidity) {
                      if (_issueSelection == 'yes') {
                        try {
                          final Uint8List bytes = await _imageFile.value!
                              .readAsBytes();
                          String base64Image = base64Encode(bytes);
                          await reportIssue(
                              loginController.currentTrip!.tripNumber,
                              selectedVehicle.vehicleNumber,
                              loginController.user!.userName,
                              "Trip end issues",
                              controller.issueController.text,
                              base64Image);
                        } catch (e) {
                          print(e);
                        }
                      }
                      print("trip issues updated..................");
                      try{
                        final Uint8List bytes = await _odometerimageFile.value!.readAsBytes();
                        String base64Image = base64Encode(
                            bytes);
                          await updateVehicleReading(
                              selectedVehicle.vehicleNumber,
                              odometerController.text);
                          print('updateVehicleReading....................');
                        await updateKeyCustody(selectedVehicle.vehicleNumber, 'Available');
                        print('updateKeyCustody...........................');
                        await updateTripEnd(
                              loginController.currentTrip!.tripNumber,
                              odometerController.text,
                              fuelController.text,
                              base64Image);
                        print('updateTripEnd..............................');
                        await updateTripEndTime(loginController.currentTrip!.tripNumber);
                        print("updateTripEndTime...........................");
                        loginController.currentTrip!.tripEndTimeDriver = DateTime.now();
                          selectedVehicle.odometerReading = int.parse(odometerController.text);
                      }
                      catch(e){
                        print(e);
                      }
                      await updateTripStatus(
                          loginController.user!.userName, null);
                      print('updateTripStatus............................');
                      var result = calculateTotalHours(
                          loginController.currentTrip!.tripStartTimeDriver!,
                          DateTime.now());
                      // int.parse(loginController.chartData!.totalHours.toString())
                      loginController.chartData!.totalHours+=result;

                      print('Total hours: ${loginController.chartData!.totalHours}');
                      // print('Total hours: ${loginController.chartData!.totalHours.runtimeType}');

                      await updateChartData(
                        loginController.user!.id,
                          loginController.chartData!.totalHours,
                          DateTime.now());
                      print("updateChartData............................");
                      loginController.currentTrip = null;
                      loginController.user!.status = null;
                      _imageFile = Rx<File?>(null);
                      Get.offAll(() => MainScreen());
                    }
                  } else{
                    createToastBottom('Please fill all the fields');
                  }
                },
                child: Text("SUBMIT", style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),),
              ),
            ],
          );
        },
      ),
    );
  }


  Future<bool> showCheckPinOverLay() async {
    bool isValidPin = false;
    await Get.bottomSheet(
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
                      'ENTER YOUR PIN',
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
                            controller: controller.pinController,
                            obscureText: _obscureTextPin.value,
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
                                  _obscureTextPin.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primary,
                                ),
                                onPressed: () => _obscureTextPin.toggle(),
                              ),
                            ),
                          )
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
                        if (int.parse(controller.pinController.text) == loginController.user!.pin) {
                          isValidPin = true;
                          Get.back();
                        } else {
                          print('Incorrect PIN');
                          createToastTop('Incorrect PIN');
                          isValidPin = false;
                        }
                      },
                      child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
    return isValidPin;
  }

  showDetailOverLay() async {
    Get.bottomSheet(
      SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                width: Get.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.memory(base64Decode(selectedVehicle.vehiclePhoto), height: 130, width: 130)),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: Get.width*.5,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: greenlight.withOpacity(.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child:Row(
                                children:[
                                  Icon(Icons.location_pin, color: greenlight, size: 25),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(_currentPlaceSubAdministrativeArea!=''?_currentPlaceSubAdministrativeArea!:_currentPlaceSubLocality!=''?_currentPlaceSubLocality!:_currentPlaceLocality!, style: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w600),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ),
                                ]
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    bool pinValidity = await showCheckPinOverLay();
                                    if(pinValidity) {
                                      await updateTripStatus(loginController.user!.userName, loginController.currentTrip!.tripNumber);
                                      Get.offAll(() => MainScreen());
                                    }


                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(greenlight),
                                    elevation: MaterialStateProperty.all(5),
                                  ),
                                  child: const Text('PAUSE', style: TextStyle(color: Colors.white),)),

                              const SizedBox(width: 20),
                              ElevatedButton(
                                  onPressed: (){
                                    // print("Dashboard");
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return buildStopAlert();
                                      },
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(primary),
                                    elevation: MaterialStateProperty.all(5),
                                  ),
                                  child: const Text('STOP', style: TextStyle(color: Colors.white),)),
                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
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
