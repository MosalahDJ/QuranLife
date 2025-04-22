// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';
import 'package:project/features/controller/prayer%20times%20controller/location_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

//note: don't forget to fix the logical error in the _gettingresponse function
// and the _addDateToResponse function. The current implementation may not work as expected.

int currentyear = DateTime.now().year;

class GetResponseBody extends GetxController {
  final LocationController locationctrl = Get.find();

  @override
  void onInit() {
    super.onInit();
    _updateDates();
    // Add periodic check for data refresh
    ever(_checkRefreshTimer, (_) => _checkAndRefresh());
  }

  final _checkRefreshTimer = 0.obs;

  // Start periodic check every hour
  void startPeriodicCheck() {
    Timer.periodic(const Duration(hours: 1), (timer) {
      _checkRefreshTimer.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future<void> _checkAndRefresh() async {
    if (await _isAfterRefreshingDate()) {
      await _gettingresponse();
      // Notify FetchPrayerFromDate to reload data
      Get.find<FetchPrayerFromDate>().loadPrayerData();
    }
  }


  late SharedPreferences prefs;
  //I use this func for parsing String date when i get it from SHPF
  // DateTime _parseDate(String date) {
  //   try {
  //     var parts = date.trim().split('-');
  //     if (parts.length != 3) {
  //       throw FormatException('Invalid time format: $date');
  //     }
  //     return DateTime(
  //       int.parse(parts[0].trim()),
  //       int.parse(parts[1].trim()),
  //       int.parse(parts[2].trim()),
  //     );
  //   } catch (e) {
  //     print('Error parsing time: $date - Error: $e');
  //     // Return a default time in case of error
  //     return DateTime.now();
  //   }
  // }

  //I use this func for defining end date and refreshing date
  //here i must change refreshing date to the last day in the year or after
  Future<void> _defineRefreshingDate() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final refreshingdate = endDate.subtract(const Duration(days: 3));
      await prefs.setString("refreshingdate", _formatDate(refreshingdate));
    } catch (e) {
      print('Error setting refreshing date: $e');
    }
  }

  //checking if current date is after refreshing date
  Future<bool> _isAfterRefreshingDate() async {
    try {
      prefs = await SharedPreferences.getInstance();
      if (prefs.getString("refreshingdate") == null) {
        await _defineRefreshingDate();
        return false;
      }

      DateTime refreshingDate = _parseDate(prefs.getString("refreshingdate")!);
      DateTime now = DateTime.now();

      // Check if we've passed the refresh date
      if (now.isAfter(refreshingDate)) {
        await prefs.remove("refreshingdate");
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking refresh date: $e');
      return false;
    }
  }

  Future<bool> _shouldRefreshData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      if (prefs.getString("responsebody") == null) return true;

      if (prefs.getString("responsebody")!.length < 36000) return true;

      Map<String, dynamic> data = jsonDecode(prefs.getString("responsebody")!);
      List<String> dates = data.keys.toList();
      if (dates.isEmpty) return true;

      dates.sort();
      DateTime oldestStoredDate = _parseDate(dates.first);
      DateTime latestStoredDate = _parseDate(dates.last);
      DateTime currentDate = DateTime.now();

      // Check if current date is within our stored date range
      if (currentDate.isBefore(oldestStoredDate) ||
          currentDate.isAfter(latestStoredDate)) {
        return true;
      }

      return false; // Don't refresh if we have valid data
    } catch (e) {
      print('Error checking data validity: $e');
      return true;
    }
  }

  //i use this func when open the app
  Future<bool> initileresponse() async {
    prefs = await SharedPreferences.getInstance();
    bool needsRefresh = await _shouldRefreshData();

    if (needsRefresh) {
      _updateDates();
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
      await _gettingresponse(mycurrentdate, endDate);
      return true; // Data was refreshed
    }
    return false; // No refresh needed
  }

  //I use this func on demende
  demendeNewResponse() async {
    prefs = await SharedPreferences.getInstance();
    await _gettingresponse();
  }

  Future<void> _gettingresponse() async {
    await locationctrl.determinePosition();
    try {
        //getting response
        var response = await http.get(
          Uri.parse(
            "https://api.aladhan.com/v1/calendar/$currentyear?latitude=${locationctrl.latitude}&longitude=${locationctrl.longtude}&method=19&school=0&timezonestring=Africa/Algiers&tune=0,0,0,0,0,0,0,0,0&midnightMode=0&latitudeAdjustmentMethod=2&calendarMethod=HJCoSA&iso8601=false",
          ),
        );
        //if succes store responsebody in cash
        //here I must change shared prefrensses with sqflite
        response.statusCode == 200?await prefs.setString("responsebody", "{$response}"):null;
        // Update the refreshing date
        await _defineRefreshingDate();
        // Notify FetchPrayerFromDate to reload data instead of restarting
        Get.find<FetchPrayerFromDate>().loadPrayerData();
    } catch (e) {
      print('There was an error: $e');
    }
  }
}
