import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/Utils/constants.dart';
import 'package:project/features/controller/spalshview%20controller/splash_view_controller.dart';

class SplashViewBody extends StatelessWidget {
  SplashViewBody({super.key});

  final SplashViewController anctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: FadeTransition(
                opacity: anctrl.fadinganimation!,
                child: Text(
                  'quran_life'.tr,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode ? kmaincolor3 : kmaincolor3dark,
                  ),
                ),
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                'please_wait'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
