import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/color.dart';
import '../view/login_screen.dart';
import '../view/main_screen.dart';
import '../widget/toaster_message.dart';
import 'login_controller.dart';


class SplashController extends GetxController {

  LoginController loginController = Get.put(LoginController());
  RxDouble opacity = RxDouble(0.0);
  TextEditingController pinController = TextEditingController();
  RxBool _obscureText = true.obs;


  @override
  onInit(){
    super.onInit();
    animateLogo();
  }

  animateLogo() async {
    await Future.delayed(Duration.zero);
    opacity.value=1;
    await Future.delayed(const Duration(seconds: 3));
    loginController.isLoggedIn.value
        ? showSetPinOverLay()
        : Get.offAll(() => LoginScreen());
  }


  showSetPinOverLay() async {
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
                        if (loginController.user?.pin == pinController.text) {
                          while (loginController.isloading.value) {
                            await Future.delayed(Duration(seconds: 1));
                          }
                          Get.offAll(() => MainScreen());
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
}
