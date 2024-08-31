import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../model/vehicle.dart';
import '../utils/color.dart';
import '../widget/toaster_message.dart';
import 'car_detail_screen.dart';
import 'navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find();
  LoginController loginController = Get.put(LoginController());
  RxBool _obscureTextPin = true.obs;
  TextEditingController pinController = TextEditingController();
  int _index = 2;
  final carNumberController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final vehicleNameController = TextEditingController();
  bool isLoading = false;
  late final Vehicle? selectedVehicle = loginController.currentvehicle;

  late DateTime now;
  late DateTime today;

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    controller.isinitloading.value = true;
    // controller.spots = List.generate(12, (index) => FlSpot(index + 1, getTripsForMonth(index + 1).toDouble()));
    // getTotalTripsThisYear();
    // print(controller.spots);
    controller.isinitloading.value = false;
  }

  String getFirstWords(String text, int len) {
    List<String> words = text.split(' ');
    return words.length > len ? '${words[0]} ${words[1]}' : text;
  }
  // void getTotalTripsThisYear() {
  //   int currentYear = DateTime.now().year;
  //   controller.totalTripsThisYear = loginController.chartData==null?0:loginController.chartData!.date.where((date) => date.year == currentYear).length;
  // }
  //
  // List<int> getTripsPerMonthThisYear() {
  //   int currentYear = DateTime
  //       .now()
  //       .year;
  //   List<int> tripsPerMonth = List<int>.filled(12, 0);
  //
  //   if (loginController.chartData == null) {
  //     return tripsPerMonth;
  //   }
  //   else {
  //     for (var date in loginController.chartData!.date) {
  //       if (date.year == currentYear) {
  //         tripsPerMonth[date.month - 1]++;
  //       }
  //     }
  //     return tripsPerMonth;
  //   }
  // }
  //
  // int getTripsForMonth(int month) {
  //   List<int> tripsPerMonth = getTripsPerMonthThisYear();
  //   return tripsPerMonth[month - 1];
  // }


  @override
  void dispose() {
    vehicleNumberController.dispose();
    vehicleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      body: controller.isinitloading.value?Center(child: CircularProgressIndicator(color: greenlight,)):
      SingleChildScrollView(
        child: Column(
          children: [
            loginController.trips.length != 0? buildTripCard(): Padding(
              padding: const EdgeInsets.symmetric(vertical:60),
              child: Center(child: Text("No trips assigned",style: TextStyle(color: greenlight),)),
            ),
            SizedBox(height: 20),
            loginController.currentTrip != null ? buildCurrentTrip() : Container(),
            buildWorkChart(),
            SizedBox(height: 20),
            Container(
                margin: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                child: Divider(color: greenlight.withOpacity(.3), thickness: 1)),
            // loginController.user!.status == null ?
            loginController.currentTrip != null ?
            loginController.user!.status == null ?
            Container(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  GestureDetector(
                    onTap: () {
                      // loginController.currentTrip == null ?
                      //     createToastBottom("No trip to start") :
                        showTakeAKeyOverLay();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: greenlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("TAKE A CAR", style: const TextStyle(color:Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ) :
            //resume trip
            Container(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  GestureDetector(
                    onTap: () {
                        showCheckPinOverLay();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: greenlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("RESUME TRIP", style: const TextStyle(color:Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ):Container(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  showCheckPinOverLay() async {
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
                            obscureText: _obscureTextPin.value,
                            controller: pinController,
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
                         if (int.parse(pinController.text) == loginController.user!.pin) {
                          if(selectedVehicle != null) {
                            Get.offAll(() =>
                                NavigationScreen(selectedVehicle!));
                          }else{
                            createToastTop('No vehicle selected');
                          }
                        } else {
                          print('Incorrect PIN');
                          createToastTop('Incorrect PIN');

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
  }

  Widget buildTripCard(){
    return Container(
      margin: const EdgeInsets.only(top: 20,bottom:30, left: 5, right: 5),
      child: Container(
        height: MediaQuery.of(context).size.width / 2.7, // Card height
        child: PageView.builder(
          itemCount: loginController.trips.length,
          controller: PageController(viewportFraction: 0.36, initialPage: 2),
          onPageChanged: (index) => setState(() => _index = index),
          itemBuilder: (context, index) {
            double scale = _index == index ? 1 : .7; // Scale up if it's the middle card
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  //width: MediaQuery.of(context).size.width / 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: MemoryImage(base64Decode((loginController.vehicles.firstWhere((vehicle) => vehicle.vehicleNumber == loginController.trips[index].vehicleNumber).vehiclePhoto))),
                      fit: BoxFit.fill, // Make the image fill the container
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _index == index ? primary.withOpacity(.3): Colors.black.withOpacity(.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left:20.0, right: 10.0,top:15, bottom: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(getFirstWords(loginController.vehicles.firstWhere((vehicle) => vehicle.vehicleNumber == loginController.trips[index].vehicleNumber,).vehicleName,2), style:  TextStyle(color:Colors.white.withOpacity(.9), fontSize: 12, fontWeight: FontWeight.w300)),
                                  Icon(loginController.trips[index].tripStartTimeDriver != null && loginController.trips[index].tripEndTimeDriver !=null ? Icons.circle :
                                  loginController.trips[index].tripStartTimeDriver != null && loginController.trips[index].tripEndTimeDriver ==null ? Icons.drive_eta_rounded :
                                  Icons.circle_outlined, color: Colors.white, size: 15),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("${loginController.trips[index].tripStartLocation} - ${loginController.trips[index].tripDestination.}", style: const TextStyle(color:Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text("${getFirstWords(loginController.trips[index].tripStartLocation,2)}  ${getFirstWords(loginController.trips[index].tripDestination,2)}",
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.20,
                                    color: greenlight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, color: Colors.white, size: 10,),
                                          SizedBox(width: 3),
                                          //Text(loginController.trips[index].tripDate, style: const TextStyle(color:Colors.white, fontSize: 10, fontWeight: FontWeight.w400)),
                                          Text(DateFormat('dd/MM/yy').format(loginController.trips[index].tripDate), style: const TextStyle(color:Colors.white, fontSize: 10, fontWeight: FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.28,
                                    color: greenlight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, color: Colors.white, size: 10,),
                                          SizedBox(width: 3),
                                          Text("12:00AM- 6:00PM", style: const TextStyle(color:Colors.white, fontSize: 10, fontWeight: FontWeight.w400)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildCurrentTrip() {
    return Column(
      children: [
        Text("CURRENT TRIP", style: GoogleFonts.lato(color:primary, fontSize: 16, fontWeight: FontWeight.w700)),
        Container(
          decoration: BoxDecoration(
            color: greenlight.withOpacity(.1),
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          padding: const EdgeInsets.only(top: 10, bottom:10, right: 20, left:20),
          child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Trip No: ${loginController.currentTrip!.tripNumber}", style: const TextStyle(color:primary, fontWeight: FontWeight.w400)),
                      SizedBox(height: 10,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Text(loginController.currentTrip!.tripStartLocation,
                            // overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontSize:16,color:greenlight, fontWeight: FontWeight.w800)),),
                      Text("${DateFormat('dd/MM/yy').format(loginController.currentTrip!.tripDate)}", style: const TextStyle(color:primary, fontWeight: FontWeight.w400, fontSize: 13)),
                      Text("${DateFormat('hh:mm a').format(loginController.currentTrip!.tripDate)}", style: const TextStyle(color: primary, fontWeight: FontWeight.w400, fontSize: 13),),
                      SizedBox(height: 15,),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Text(loginController.currentTrip!.tripDestination,
                            // overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize:16,color:greenlight, fontWeight: FontWeight.w800)),),
                      Text("${DateFormat('dd/MM/yy').format(loginController.currentTrip!.tripEndTime)}", style: const TextStyle(color:primary, fontWeight: FontWeight.w400)),
                      Text("${DateFormat('hh:mm a').format(loginController.currentTrip!.tripEndTime)}", style: const TextStyle(color: primary, fontWeight: FontWeight.w400),),

                      SizedBox(height: 10),
                      Text(loginController.currentTrip!.tripType, style: const TextStyle(fontSize:12, color:primary, fontWeight: FontWeight.w400)),
                      SizedBox(height: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                          child: Text(loginController.currentTrip!.notification ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color:Colors.grey, fontSize: 13, fontWeight: FontWeight.w400)),),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loginController.currentTrip!.tripStartTimeDriver != null && loginController.currentTrip!.tripEndTimeDriver ==null ? "In Progress" :
                        loginController.currentTrip!.tripStartTimeDriver != null && loginController.currentTrip!.tripEndTimeDriver != null ? "Trip Completed":"Trip to Start", style: const TextStyle(color:greenlight, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.memory(
                                base64Decode(loginController.currentvehicle!.vehiclePhoto),
                                height: 140,
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Text(
                                "${getFirstWords(loginController.currentvehicle!.vehicleName,2)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ),
        Container(
            margin: const EdgeInsets.only(top:5,bottom: 10, left: 30, right: 30),
            child: Divider(color: greenlight.withOpacity(.3), thickness: 1)),

      ],
    );
  }
  Widget buildWorkChart() {
    // List<FlSpot> spots = List.generate(12, (index) => FlSpot(index + 1, getTripsForMonth(index + 1).toDouble()));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("WORK CHART", style: GoogleFonts.lato(color: primary, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: secondary,
                      border: Border.all(color: greenlight, width: .25),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text("Total Hours", style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w400)),
                        ),
                        Text(loginController.chartData==null?'0':loginController.chartData!.totalHours.toStringAsFixed(2), style: const TextStyle(color: greenlight, fontSize: 12, fontWeight: FontWeight.w900)),
                        Image.asset('assets/graph/graph1.png', width: 100),
                      ],
                    ),
                  ),
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: secondary,
                      border: Border.all(color: greenlight, width: .25),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text("Total Trips", style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w400)),
                        ),
                        Text(loginController.chartData==null?'0':loginController.chartData!.date.length.toString(), style: const TextStyle(color: greenlight, fontSize: 12, fontWeight: FontWeight.w900)),
                        Image.asset('assets/graph/graph1.png', width: 100),
                      ],
                    ),
                  ),
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: secondary,
                      border: Border.all(color: greenlight, width: .25),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text("This Year", style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w400)),
                        ),
                        Text(loginController.totalTripsThisYear.toString(), style: const TextStyle(color: greenlight, fontSize: 12, fontWeight: FontWeight.w900)),
                        Image.asset('assets/graph/graph1.png', width: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.only(top: 20, right: 30, left: 20),
          height: 120,
          width: MediaQuery.of(context).size.width * 0.9,
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: greenlight,
                    strokeWidth: 0.3,
                    dashArray: [2, 5],
                  );
                },
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: bottomTitleWidgets,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1000,
                    getTitlesWidget: leftTitleWidgets,
                    reservedSize: 28,
                  ),
                ),
              ),
              backgroundColor: secondary,
              lineBarsData: [
                LineChartBarData(
                  spots: loginController.spots,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        color: greenlight,
                        radius: 4,
                      );
                    },
                  ),
                  color: primary,
                  barWidth: 2,

                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.grey,
      fontSize: 6,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('JAN', style: style);
        break;
      case 2:
        text = const Text('FEB', style: style);
        break;
      case 3:
        text = const Text('MAR', style: style);
        break;
      case 4:
        text = const Text('APR', style: style);
        break;
      case 5:
        text = const Text('MAY', style: style);
        break;
      case 6:
        text = const Text('JUN', style: style);
        break;
      case 7:
        text = const Text('JUL', style: style);
        break;
      case 8:
        text = const Text('AUG', style: style);
        break;
      case 9:
        text = const Text('SEP', style: style);
        break;
      case 10:
        text = const Text('OCT', style: style);
        break;
      case 11:
        text = const Text('NOV', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.grey,
      fontSize: 6,
    );
    String text;
    switch (value.toInt()) {
      case 1000:
        text = '1000';
        break;
      case 2000:
        text = '2000';
        break;
      case 3000:
        text = '3000';
        break;
      case 4000:
        text = '4000';
        break;
      case 5000:
        text = '5000';
        break;
      case 6000:
        text = '6000';
        break;
      case 7000:
        text = '7000';
        break;
      case 8000:
        text = '8000';
        break;
      case 9000:
        text = '9000';
        break;
      case 10000:
        text = '10000';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  showTakeAKeyOverLay() async {
    String query = '';
    List<String> filteredCars = [];
    Get.bottomSheet(
      SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                       ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.memory(
                              base64Decode(loginController.currentvehicle!.vehiclePhoto),
                              height: 150,
                            ),
                          ),

                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${getFirstWords(loginController.currentvehicle!.vehicleName,2)}",
                              style: GoogleFonts.lato(color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),),
                            SizedBox(height: 10),
                            Text(
                              loginController.currentvehicle!.vehicleType,
                              style: GoogleFonts.lato(color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),),
                            SizedBox(height: 10),
                            Text(
                              loginController.currentvehicle!.vehicleNumber,
                              style: GoogleFonts.lato(color: greenlight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),),
                            SizedBox(height: 10),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await controller.getWorkshopData(loginController.currentvehicle!);
                                  while (controller.isLoading) {
                                    await Future.delayed(Duration(seconds: 1));
                                  }
                                  Get.offAll(() =>
                                      CarDetailScreen(loginController.currentvehicle!,controller.workshop!, true));
                                },
                                style: ButtonStyle(
                                  elevation: WidgetStateProperty.all(8),
                                  backgroundColor: WidgetStateProperty.all(primary),
                                ),
                                child: Text(
                                  'SELECT CAR',
                                  style: GoogleFonts.lato(fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Divider(color: greenlight, thickness: 1),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CHANGE CAR',
                          style: GoogleFonts.lato(color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),),
                        /*ElevatedButton(
                            style: ButtonStyle(
                              elevation: WidgetStateProperty.all(5),
                              backgroundColor: WidgetStateProperty.all(
                                  greenlight),
                            ),
                            onPressed: () {
                              Get.back();
                              Get.dialog(
                                AlertDialog(
                                  title: Text('ADD NEW CAR',
                                      style: GoogleFonts.lato(color: primary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600)),
                                  backgroundColor: secondary,
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: vehicleNumberController,
                                          decoration: InputDecoration(
                                            labelText: 'Enter Car Number',
                                            labelStyle: GoogleFonts.lato(
                                                fontSize: 12,
                                                color: primary,
                                                fontWeight: FontWeight.w600),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primary.withOpacity(
                                                      .7)),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: vehicleNameController,
                                          decoration: InputDecoration(
                                            labelText: 'Enter Car Name',
                                            labelStyle: GoogleFonts.lato(
                                                fontSize: 12,
                                                color: primary,
                                                fontWeight: FontWeight.w600),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primary.withOpacity(
                                                      .7)),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Obx(() =>
                                        _imageFile.value != null
                                            ?
                                        Image.file(_imageFile.value!)
                                            : Container(),
                                        ),

                                        const SizedBox(height: 10),

                                        ElevatedButton(
                                          onPressed: () async {
                                            await _pickImage();
                                            setState(() {});
                                          },
                                          style: ButtonStyle(
                                            elevation: WidgetStateProperty.all(
                                                5),
                                            backgroundColor: WidgetStateProperty
                                                .all(greenlight),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Icon(Icons.add_a_photo_rounded,
                                                color: Colors.white, size: 18,),
                                              const SizedBox(width: 10),
                                              Text(
                                                'ADD  IMAGE',
                                                style: GoogleFonts.lato(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight
                                                        .bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Obx(() =>
                                            DropdownButton<String>(
                                              value: selectedVehicleModel.value,
                                              onChanged: onVehicleModelChanged,
                                              underline: Container(
                                                height: 1,
                                                color: primary.withOpacity(
                                                    .7),
                                              ),
                                              items: vehicleModels.map((
                                                  String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      style: GoogleFonts.lato(
                                                          fontSize: 12,
                                                          color: primary,
                                                          fontWeight: FontWeight.w600)),
                                                );
                                              }).toList(),
                                            )),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _imageFile = Rx<File?>(null);
                                        Get.back();
                                      },
                                      child: Text("CANCEL",
                                        style: GoogleFonts.lato(fontSize: 15,
                                            color: primary,
                                            fontWeight: FontWeight.w600),),
                                    ),
                                    /*TextButton(
                                          onPressed: () async {
                                            if(vehicleNumberController.text != "" && vehicleNameController.text != "" && _imageFile.value != null){
                                              //vehicleNumber, image, vehicleName, vechileType
                                              final ByteData imageData = await _imageFile.readAsBytes();
                                              final Uint8List bytes = imageData.buffer.asUint8List();
                                              String _base = base64Encode(bytes);
                                              uploadTempVehicle(vehicleNumberController.text, _base, vehicleNameController.text, selectedVehicleModel.value);
                                              _imageFile=Rx<File?>(null);
                                              Vehicle tempVehicle = Vehicle(vehicleNameController.text, vehicleNumberController.text, DateTime.parse("0000-00-00"), DateTime.parse("0000-00-00"), 'seden', '_base', false, '', 0, 0, '', [], '', '', '', '', DateTime.parse("0000-00-00"), DateTime.parse("0000-00-00"), '');
                                              Get.back();
                                              Get.offAll(() => CarDetailScreen(tempVehicle, false));
                                            }
                                            else{
                                              createToastTop('Please fill all the fields');
                                            }
                                          },
                                          child: Text("CONFIRM", style: GoogleFonts.lato(fontSize: 15, color: primary, fontWeight: FontWeight.w600),),
                                        ),*/
                                    //isLoading? CircularProgressIndicator():
                                    TextButton(
                                      onPressed: () async {
                                        if (vehicleNumberController.text.isNotEmpty && vehicleNameController.text.isNotEmpty && _imageFile.value != null) {
                                          try {
                                            // setState(() {
                                            //   isLoading = true;
                                            // });
                                            final Uint8List bytes = await _imageFile
                                                .value!.readAsBytes();
                                            String base64Image = base64Encode(
                                                bytes);
                                            await controller.uploadTempVehicle(
                                              vehicleNumberController.text,
                                              base64Image,
                                              vehicleNameController.text,
                                              selectedVehicleModel
                                                  .value, // Assuming you have a controller for HomeController
                                            );

                                            _imageFile.value =
                                            null; // Reset _imageFile after upload
                                            Vehicle tempVehicle = Vehicle(
                                              vehicleNameController.text,
                                              vehicleNumberController.text,
                                              DateTime.parse("0000-00-00"),
                                              DateTime.parse("0000-00-00"),
                                              'seden',
                                              base64Image,
                                              // Use base64Image here instead of '_base'
                                              false,
                                              '',
                                              0,
                                              0,
                                              '',
                                              [],
                                              '',
                                              '',
                                              '',
                                              '',
                                              DateTime.parse("0000-00-00"),
                                              DateTime.parse("0000-00-00"),
                                              '',
                                            );
                                            Get.back();
                                            Get.offAll(() =>
                                                CarDetailScreen(tempVehicle,(tempVehicle.vehicleNumber,DateTime.parse("0000-00-00"),"","","",0,0,"",0) as workshopMovement, false));
                                          } catch (e) {
                                            createToastTop(
                                                'An error occurred: $e');
                                            // } finally {
                                            //
                                            //     setState(() {
                                            //       isLoading = false; // Hide loading indicator
                                            //     });
                                            //
                                          }
                                        }else {
                                          createToastTop(
                                              'Please fill all the fields');
                                        }
                                      },
                                      child: Text(
                                        "CONFIRM",
                                        style: GoogleFonts.lato(fontSize: 15,
                                            color: primary,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('ADD NEW CAR', style: TextStyle(
                                color: Colors.white),)),*/
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: carNumberController,
                      onChanged: (value) {
                        query = value;
                        filteredCars = loginController.vehicles
                            .map((vehicle) => vehicle.vehicleNumber)
                            .where((carNumber) => carNumber.contains(query))
                            .toList();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Vehicle Number',
                        labelStyle: GoogleFonts.lato(fontSize: 13,
                            color: primary,
                            fontWeight: FontWeight.w500),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: primary.withOpacity(.7)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCars.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredCars[index]),
                          onTap: () {
                            carNumberController.text = filteredCars[index];
                            filteredCars = [];
                            setState(() {});
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(

                      onPressed: () {
                        String vehicleNumber = carNumberController.text;
                        Vehicle selectedCar = loginController.vehicles
                            .firstWhere((vehicle) =>
                        vehicle.vehicleNumber == vehicleNumber);
                        Get.back();
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: secondary,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: MemoryImage(base64Decode(
                                          selectedCar.vehiclePhoto)),
                                      fit: BoxFit.fill,
                                    ),
                                  ),

                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                          border: Border.all(
                                              color: greenlight.withOpacity(.2),
                                              width: 2),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              right: 10.0,
                                              top: 15,
                                              bottom: 10.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(selectedCar.vehicleName,
                                                      style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.9),
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .w500)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                    'Car Number : ${selectedCar.vehicleNumber}',
                                    style: const TextStyle(color: primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  //uploadImage(selectedCar);

                                  carNumberController.clear();
                                  Get.back();
                                },
                                child: Text("CANCEL", style: const TextStyle(
                                    color: primary, fontSize: 16)),
                              ),
                              TextButton(
                                onPressed: () {

                                  Get.back();
                                  carNumberController.clear();
                                  loginController.currentvehicle = selectedCar;
                                  // Get.offAll(() =>
                                  //     CarDetailScreen(selectedCar, true));
                                },
                                child: Text("OK", style: const TextStyle(
                                    color: primary, fontSize: 16)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(8),
                        backgroundColor: WidgetStateProperty.all(primary),
                      ),
                      child: Text(
                        'CHECK CAR',
                        style: GoogleFonts.lato(fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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




