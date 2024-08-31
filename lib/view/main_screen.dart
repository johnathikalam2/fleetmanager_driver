import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../widget/nav_drawer.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
   MainScreen({super.key});
  final HomeController homeController = Get.put(HomeController());
  final LoginController loginController = Get.put(LoginController());



   @override
  Widget build(BuildContext context) {
    return Scaffold(

          appBar: AppBar(
            toolbarHeight: 60,
            leading: Builder(
              builder: (context) => GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 25,top: 15),
                  child: Icon (Icons.menu_rounded, color: greenlight, size: 40.0,),
                ),
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            backgroundColor: secondary,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top:10,right: 30),
                  child: Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child:  loginController.user!.profileImg != null
                          ? Image.asset(loginController.user!.profileImg!,)
                          : Icon(Icons.person, color: greenlight, size: 40.0,),
                    ),
                  ),
                ),
              ],
            ),
          body:HomeScreen(),
      drawer: NavDrawer(),
    );
  }
}
