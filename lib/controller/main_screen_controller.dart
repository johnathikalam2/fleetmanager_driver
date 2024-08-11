import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreenController extends GetxController{
  static MainScreenController get to =>Get.find();

  RxString title = RxString('Home');
  RxInt selectedIndex = RxInt(0);
  final scaffoldKey = GlobalKey<ScaffoldState>();

  selectIndex(int index) {
    selectedIndex.value = index;
    setTitle(index);
    if(scaffoldKey.currentState!.isDrawerOpen){
      scaffoldKey.currentState!.closeDrawer();
    }
  }setTitle(int index) {
    switch (index) {
      case 0:
        title.value = 'Home';
        break;
    }
  }
}