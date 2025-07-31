import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/Utils/constants.dart';

import '../../../core/Utils/size_config.dart';
import '../../controller/settings%20controllers/theme_controller.dart';
import '../splash%20page/widgets/splash_view_body.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    //I use it here fore initialize the screen size
    Sizeconfig().init(context);

    return GetBuilder<ThemeController>(
      builder:
          (c) => Scaffold(
            backgroundColor: Get.isDarkMode ? kmaincolor3dark : kmaincolor3,
            body: SplashViewBody(),
          ),
    );
  }
}
