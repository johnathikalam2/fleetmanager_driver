import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';


class NavigationController extends GetxController {
  static NavigationController get to => Get.find();
  TextEditingController pinController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController issueController = TextEditingController();


  callHelp() async {
    if (!await launchUrl(Uri.parse('tel:+9181380 66143'))) {
      throw 'Could not launch tel:+918138066143';
    }
  }
}