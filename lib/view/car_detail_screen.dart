import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:fleet_manager_driver_app/controller/home_controller.dart';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:fleet_manager_driver_app/view/body_condition_screen.dart';
import 'package:fleet_manager_driver_app/view/home_screen.dart';
import 'package:fleet_manager_driver_app/widget/toaster_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/car_detail_controller.dart';
import '../controller/login_controller.dart';
import '../model/vehicle.dart';
import '../model/workShopMovement.dart';
import '../service/database.dart';
import 'navigation_screen.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen(this.vehicle,this.workshop,this._isStored,{Key? key}) : super(key: key);
  final Vehicle vehicle;
  final workshopMovement workshop;
  final bool _isStored;

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}
Rx<File?> _imageFile = Rx<File?>(null);

class _CarDetailScreenState extends State<CarDetailScreen> {
  final CarDetailController controller = Get.put(CarDetailController());
  LoginController loginController = Get.put(LoginController());
  HomeController homeController = Get.put(HomeController());
  late final Vehicle selectedVehicle;
  late final workshopMovement workshopDetail;
  final odometerController = TextEditingController();
  final fuelController = TextEditingController();


  @override
  void initState() {
    super.initState();
    selectedVehicle = widget.vehicle;
    workshopDetail = widget.workshop;
    controller.getScratchdata(selectedVehicle);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(height: 20,),
              buildDashboardBox(),
              widget._isStored == true? buildBodyConditionBox():Container(),
              SizedBox(height: 15,),
              Divider(color: greenlight.withOpacity(.3),thickness: 1,),
              SizedBox(height: 10,),
              buildCheckBox(),
              SizedBox(height: 15,),
              Divider(color: greenlight.withOpacity(.3),thickness: 1,),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.memory(
                      base64Decode(selectedVehicle.vehiclePhoto),
                      height: 140,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: controller.checkboxValues.every((value) => value) & controller.isDashboard ? () async {
                          bool pinValidity = await controller.showSetPinOverLay();
                          if(pinValidity) {
                            await updateTripStatus(loginController.user!.userName, loginController.currentTrip!.tripNumber);
                            await updateKeyCustody(selectedVehicle.vehicleNumber, loginController.user!.userName);
                            await updateTripStartTime(loginController.currentTrip!.tripNumber);
                            loginController.currentTrip!.tripStartTimeDriver = DateTime.now();
                            loginController.user!.status = loginController.currentTrip!.tripNumber;
                            Get.offAll(() => NavigationScreen(selectedVehicle));
                          }
                        }:
                            (){
                          createToastBottom("Please check all the fields");
                            },
                        child: Container(
                          decoration: BoxDecoration(
                            color: controller.checkboxValues.every((value) => value) & controller.isDashboard ? greenlight:greenlight.withOpacity(.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("TAKE HANDOVER",style: GoogleFonts.lato(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w700,height: 1.2),),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      GestureDetector(
                        onTap:() async {
                          bool pinValidity = await controller.showSetPinOverLay();
                          if(pinValidity) {
                            Get.offAll(() => HomeScreen());
                          }
                          print("RELEASE CAR");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("RELEASE CAR",style: GoogleFonts.lato(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w700,height: 1.2),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDashboardBox(){
    return GestureDetector(
      onTap: (){
        print("Dashboard");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return buildDashboardAlert();
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10,left: 5,right: 5),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage('assets/image/dashboard.png'),
            fit: BoxFit.fill,
          ),
        ),
        child:Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(.85), primary.withOpacity(.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DASHBOARD",style: GoogleFonts.lato(color: greenlight,fontSize: 16,fontWeight: FontWeight.w900,height: 1.2),),
                        SizedBox(height: 5,),
                        SizedBox(
                            width: MediaQuery.of(context).size.width*.6,
                            child: Text("Inspect and top off engine oil, coolant, brake fluid, and power steering fluid levels as necessary. Check battery terminals for corrosion and ensure the battery is securely mounted.",style: TextStyle(color: Colors.white.withOpacity(.7),fontSize: 8),maxLines: 3,)
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_sharp,color: Colors.white,size: 25,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBodyConditionBox(){
    return GestureDetector(
      onTap: () async {
        while (controller.isloading) {
          await Future.delayed(Duration(seconds: 1));
        }
        print("Body Condition");
        if (controller.scratchData != null) {
          Get.to(() => BodyConditionScreen(controller.scratchData!, true));
        } else {
          createToastBottom("Scratch data is not available");
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10,left: 5,right: 5),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage('assets/image/body_condition.png'),
            fit: BoxFit.fill,
          ),
        ),
        child:Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(.85), primary.withOpacity(.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width*.3,
                            child:
                            Text("BODY CONDITION",style: GoogleFonts.lato(color: greenlight,fontSize: 16,fontWeight: FontWeight.w900,height: 1.2,))),
                        SizedBox(height: 5,),
                        SizedBox(width: MediaQuery.of(context).size.width*.6,
                            child: Text("Check for dents, scratches, rust, or damage.Inspect for cracks or chips. Ensure windows open and close properly. Check side and rearview mirrors for cracks or damage.",style: TextStyle(color: Colors.white.withOpacity(.7),fontSize: 8),maxLines: 3,)),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_sharp,color: Colors.white,size: 25,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildCheckBox() {
    return Column(
      children: [
        ...List.generate(controller.checkboxValues.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: ListTile(
              minTileHeight: 20,
                tileColor: controller.checkboxValues[index] ? greenlight.withOpacity(.5):greenlight.withOpacity(.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Text(controller.checkboxTexts[index],style: TextStyle(color: primary.withOpacity(.7), fontSize: 13,),),
                trailing: Transform.scale(
                  scale: 0.6,
                  child: Checkbox(
                    value: controller.checkboxValues[index],
                    activeColor: primary,
                    onChanged: (value) {
                      setState(() {
                        controller.checkboxValues[index] = value!;
                      });
                    },
                  ),
                ),
            ),
          );
        }),

        widget._isStored?Container(
          width: MediaQuery.of(context).size.width*.85,
          decoration: BoxDecoration(
            color: greenlight.withOpacity(.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Alignment and Balancing",style: TextStyle(color: primary.withOpacity(.7), fontSize: 13,),),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text("${int.parse(loginController.currentvehicle!.odometerReading.toString()) -(int.parse(workshopDetail.odometerReading.toString()) )} Kms",style: TextStyle(color: primary.withOpacity(.7), fontSize: 13,),),
                  //child: Text("1000 Kms",style: TextStyle(color: primary.withOpacity(.7), fontSize: 13,),),
                ),
              ],
            ),
          ),
        ) : Container(),
      ],
    );
  }

  Widget buildDashboardAlert() {
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: secondary,
            title: Text("DASHBOARD", style: GoogleFonts.lato(color: primary, fontSize: 18, fontWeight: FontWeight.w700)),
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
                  Get.back();
                  setState(() {
                    controller.isDashboard=true;
                  });
                  print(controller.isDashboard);
                },
                child: Text("CANCEL", style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600),),
              ),

              TextButton(
                onPressed: () async {
                  if(odometerController.text!='' && fuelController.text!='' && _imageFile.value != null){
                    setState(() {
                      controller.isDashboard=true;
                    });
                    try{
                      final Uint8List bytes = await _imageFile
                          .value!.readAsBytes();
                      String base64Image = base64Encode(
                          bytes);
                      widget._isStored
                          ? {
                        await updateVehicleReading(
                          selectedVehicle.vehicleNumber,
                          odometerController.text,
                        ),
                        await updateTripBegin(
                            loginController.currentTrip!.tripNumber,
                            odometerController.text,
                            fuelController.text,
                            base64Image),
                        selectedVehicle.odometerReading = int.parse(odometerController.text),
                          }
                          :{
                        await updateTempVehicleReading(
                          selectedVehicle.vehicleNumber,
                          odometerController.text),
                      };
                      odometerController.clear();
                      fuelController.clear();
                      _imageFile = Rx<File?>(null);
                    }
                    catch(e){
                      print(e);
                    }
                    print(controller.isDashboard);

                  }
                  else{
                    createToastBottom("Please fill all the fields");
                  }
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
}
