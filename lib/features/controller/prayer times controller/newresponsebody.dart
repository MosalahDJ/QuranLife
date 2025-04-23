// ignore_for_file: avoid_print
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';
import 'package:project/features/controller/prayer%20times%20controller/location_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NewResponseBody extends GetxController {
  final LocationController locationctrl = Get.find();
  late SharedPreferences prefs;

  @override
  void onInit() {
    super.onInit();
    initileresponse();
  }

  Future<bool> initileresponse() async {
    prefs = await SharedPreferences.getInstance();
    await _gettingYearlyResponse();
    return true;
  }

  Future<void> _gettingYearlyResponse() async {
    await locationctrl.determinePosition();

    try {
      Get.snackbar(
        "downloading_data".tr,
        "please_be_patient".tr,
        colorText:
            Get.isDarkMode
                ? const Color(0xFFFFFFFF)
                : const Color.fromARGB(255, 0, 0, 0),
        duration: const Duration(seconds: 15),
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        padding: const EdgeInsets.all(20),
      );

      var response = await http.get(
        Uri.parse(
          "https://api.aladhan.com/v1/calendar/2025?latitude=${locationctrl.latitude}&longitude=${locationctrl.longtude}&method=19&school=0&timezonestring=Africa/Algiers&tune=0,-1,0,0,4,4,0,0,0&midnightMode=0&latitudeAdjustmentMethod=2&calendarMethod=MATHEMATICAL&iso8601=false",
        ),
      );

      if (response.statusCode == 200) {
        // Store the complete response
        await prefs.setString("yearlyResponseBody", response.body);

        // Notify FetchPrayerFromDate to reload data
        Get.find<FetchPrayerFromDate>().loadPrayerData();
      } else {
        print('Failed to get response. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('There was an error: $e');
    }
  }

  // Method to manually trigger a new response
  Future<void> demandNewResponse() async {
    await _gettingYearlyResponse();
  }
}
