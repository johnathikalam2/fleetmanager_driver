import 'package:fleet_manager_driver_app/model/scratch.dart';
import 'package:fleet_manager_driver_app/model/tempvehicle.dart';
import 'package:fleet_manager_driver_app/service/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/vehicle.dart';
import '../utils/color.dart';
import '../widget/toaster_message.dart';
import 'login_controller.dart';

class CarDetailController extends GetxController {
  static CarDetailController get to => Get.find();
  LoginController loginController = Get.put(LoginController());
  TextEditingController pinController = TextEditingController();
  Scratch? scratchData;
  RxBool _obscureText = true.obs;
  bool isDashboard = false;
  bool isloading = false;
  List<bool> checkboxValues = List.generate(10, (index) => false);
  List<String> checkboxTexts = [
    "Engine light",
    "Fuel",
    "Tissue",
    "Water",
    "Sanitizer",
    "Charging Accessories",
    "Interior clean",
    "Exterior clean",
    "Tire warning",
    "Other warning lights",
  ];


  void getScratchdata(Vehicle selectedVehicle) async {
    isloading = true;
    if (selectedVehicle.vehicleNumber == null) {
      return;
    }
    try {
      var scratch = await collection_scratch?.findOne(
        where.eq('vehicleNumber', selectedVehicle.vehicleNumber),
      );

      if (scratch != null) {
        List<String> scratchOrgLsv = [];
        for (var scratchOrglsv in scratch['scratchOrgLsv']) {
          scratchOrgLsv.add(scratchOrglsv);
        }
        List<String> scratchOrgRsv = [];
        for (var scratchOrgrsv in scratch['scratchOrgRsv']) {
          scratchOrgRsv.add(scratchOrgrsv);
        }
        List<String> scratchFvOrg = [];
        for (var scratchfvOrg in scratch['scratchFvOrg']) {
          scratchFvOrg.add(scratchfvOrg);
        }
        List<String> scratchTvOrg = [];
        for (var scratchtvOrg in scratch['scratchTvOrg']) {
          scratchTvOrg.add(scratchtvOrg);
        }
        List<String> scratchBvOrg = [];
        for (var scratchbvOrg in scratch['scratchBvOrg']) {
          scratchBvOrg.add(scratchbvOrg);
        }
        scratchData = Scratch(
            scratch['vehicleNumber'],
            scratch['vehicleName'],
            scratch['vehicleType'],
            scratch['scratchLSV'].last,
            scratch['scratchRSV'].last,
            scratch['scratchFV'].last,
            scratch['scratchTV'].last,
            scratch['scratchBV'].last,
            scratchOrgLsv,
            scratchOrgRsv,
            scratchFvOrg,
            scratchTvOrg,
            scratchBvOrg
        );
        print('Scratch data fetched');
        isloading = false;
      } else {
        print('No scratch data found for vehicle number: ${selectedVehicle.vehicleNumber}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<bool> showSetPinOverLay() async {
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
                            controller: pinController,
                            obscureText: _obscureText.value,
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
                        if (int.parse(pinController.text) == loginController.user!.pin) {
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
}