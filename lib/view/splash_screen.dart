import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';
import '../utils/color.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Obx(
              () => SizedBox(
            height: Get.width * 0.6,
            width: Get.width * 0.6,
            child: AnimatedOpacity(
                opacity: controller.opacity.value,
                duration: const Duration(seconds: 1),
                child: Image.asset('assets/logo/fleet_manager.png')),
          ),
        ),
      ),
    );
  }
}
