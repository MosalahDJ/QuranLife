import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/features/controller/Auth%20controller/user_state_controller.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';
import 'package:project/features/controller/prayer%20times%20controller/get_response_body.dart';
import 'package:project/features/controller/prayer%20times%20controller/location_controller.dart';
import 'package:project/features/controller/prayer%20times%20controller/deterimine_prayers_controller.dart';
import 'package:project/features/controller/prayer%20times%20controller/times_page_controller.dart';

class SplashViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AnimationController? animationcontroller;
  Animation<double>? fadinganimation;
  final LocationController locationctrl = Get.find();
  final FetchPrayerFromDate fpfctrl = Get.find();
  final DeterminePrayersController prayerctrl = Get.find();
  final TimesPageController timespagectrl = Get.find();
  final GetResponseBody responsectrl = Get.find();
  final _userstatectrl = Get.put<UserStateController>(
    UserStateController(),
    permanent: true,
  );

  RxBool isLoading = true.obs;
  void tonextpage() {
    Future.delayed(const Duration(seconds: 2), () async {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        final userState = await _userstatectrl.getUserState();

        switch (userState) {
          case UserState.noUser:
            Get.offAllNamed("onboarding");
            break;
          case UserState.anonymousUser:
          case UserState.emailSignInUser:
          case UserState.googleSignInUser:
            Get.offAllNamed("home");
            break;
        }
      } else {
        if (currentUser == null) {
          // User is not logged in
          Get.offAllNamed("onboarding");
        } else if (currentUser.isAnonymous) {
          // Anonymous user
          Get.offAllNamed("home");
        } else if (currentUser.emailVerified) {
          // Verified email user
          Get.offAllNamed("home");
        } else {
          // Unverified email user
          Get.offAllNamed("login");
        }
      }
    });
  }

  Future<void> getdata() async {
    bool wasDataRefreshed = await responsectrl.initileresponse();
    isLoading(true);
    // Only fetch prayer times if we didn't just refresh the data
    if (!wasDataRefreshed) {
      await fpfctrl.loadPrayerData();
    }
    prayerctrl.determineCurrentPrayer();
    timespagectrl.pagecontroller();
    timespagectrl.getcurrentpage();
    isLoading(false);
  }

  @override
  void onInit() async {
    super.onInit();
    animationcontroller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    fadinganimation = Tween<double>(
      begin: .2,
      end: 1,
    ).animate(animationcontroller!);
    animationcontroller?.repeat(reverse: true);
    await getdata();
    tonextpage();

    // Start periodic check after initial setup
    Get.find<GetResponseBody>().startPeriodicCheck();
  }
  @override
  void onClose() {
    super.onClose();
    SplashViewController().dispose();
  }
}
