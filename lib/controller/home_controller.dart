import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';


import 'package:fleet_manager_driver_app/controller/main_screen_controller.dart';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/vehicle.dart';
import '../model/workShopMovement.dart';
import '../service/global.dart';
import '../view/login_screen.dart';
import '../widget/toaster_message.dart';
import 'login_controller.dart';

class HomeController extends GetxController {
  workshopMovement? workshop;
  LoginController loginController = Get.put(LoginController());
  bool isLoading = false;
  final pinController1 = TextEditingController();
  final pinController2 = TextEditingController();
  final passwordController = TextEditingController();
  RxBool _obscureText1 = true.obs;
  RxBool _obscureText2 = true.obs;
  RxBool _obscureText = true.obs;


  Rx<File?> _imageFile = Rx<File?>(null);
  final List<String> vehicleModels = [
    'SUV',
    'MPV',
    'SEDAN',
    'LIMOUSINE'
  ]; // Example list of vehicle models

  Future<void> getWorkshopData(Vehicle selectedVehicle) async {
    isLoading = true;
    if (selectedVehicle.vehicleNumber == null) {
      print('Vehicle number is null');
      return;
    }
    try {
      var workshopmovement = await collection_workshop?.findOne(
        where.eq('vehicleNumber', selectedVehicle.vehicleNumber),
      );

      if (workshopMovement != null) {
        print('Workshop data found for vehicle number: ${selectedVehicle.vehicleNumber}');
        workshop = workshopMovement(
          workshopmovement?['vehicleNumber'],
          workshopmovement?['workshopVisitDate'],
          workshopmovement?['visitType'],
          workshopmovement?['nextOilChange'],
          workshopmovement?['nextTyreChange'],
          workshopmovement?['noOfDays'],
          workshopmovement?['odometerReading'],
          workshopmovement?['complaintDetail'],
          workshopmovement?['amountSpent']
        );
        print(workshop);
        print(workshop!.odometerReading);
        print(workshop!.amountSpent);
        print('Workshop data fetched');
        isLoading = false;
      } else {
        print('No workshop data found for vehicle number: ${selectedVehicle.vehicleNumber}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future <void> uploadTempVehicle(vehicleNumber, image, vehicleName, vechileType) async {
    await collection_temp_vehicles?.insert({
      'driverId': loginController.user?.id,
      'vehicleNumber': vehicleNumber,
      'vehiclePhoto': image,
      'vehicleName': vehicleName,
      'vechileType': vechileType,
      'odometerReading': '0',
      'fuelReading': '0',
      'odometerPhoto': '',
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _imageFile.value = File(image.path);
      update();
    }
  }

  Future<void> logout() async {
    LoginController loginController = LoginController();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userName');
    prefs.remove('password');
    prefs.remove('id');
    loginController.user = null;
    loginController.trips.clear();
    loginController.vehicles.clear();
    loginController.isLoggedIn(false);
    Get.offAll(() => LoginScreen());
  }

  Future<void> changePin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('pin');
    Get.back();
    Get.dialog(
      AlertDialog(
        title: Text('CHANGE PIN', style: TextStyle(
            color: primary, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: secondary,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: greenlight.withOpacity(.1),
                ),
                child: Obx(() =>
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText.value,
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: const Icon(Icons.lock_outline),
                        prefixIconColor: primary,
                        border: InputBorder.none,
                        labelText: 'PASSWORD',
                        labelStyle: const TextStyle(color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primary,
                          ),
                          onPressed: () => _obscureText.toggle(),
                        ),
                      ),
                    )
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
                        labelStyle: const TextStyle(color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
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
              const SizedBox(height: 10),
              Container(
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
                        labelStyle: const TextStyle(color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.clear();
              pinController1.clear();
              pinController2.clear();
              Get.back();
            },
            child: Text("CANCEL", style: GoogleFonts.lato(
                fontSize: 15, color: primary, fontWeight: FontWeight.w600),),
          ),

          TextButton(
            onPressed: () async {
              if (loginController.user?.password == passwordController.text) {
                if (pinController1.text == pinController2.text) {

                  await collection_drivers?.update(
                    where.eq('_id', ObjectId.parse(loginController.user!.id)),
                    modify.set('pin', int.parse(pinController1.text)),
                  );
                  print('Pin set');
                  createToastTop('PIN Changed successfully');
                  passwordController.clear();
                  pinController1.clear();
                  pinController2.clear();
                  Get.back();
                } else {
                  pinController1.clear();
                  pinController2.clear();
                  print('Pin not match');
                  createToastTop('Pin not match');
                }
              } else {
                passwordController.clear();
                pinController1.clear();
                pinController2.clear();
                print('Password not match');
                createToastTop('Password not match');
              }
            },
            child: Text("CONFIRM", style: GoogleFonts.lato(
                fontSize: 15, color: primary, fontWeight: FontWeight.w600),),
          ),
        ],
      ),
    );
  }
}

