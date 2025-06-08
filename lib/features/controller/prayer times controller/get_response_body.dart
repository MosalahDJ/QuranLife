import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';
import 'package:http/http.dart' as http;
import 'package:project/features/controller/prayer%20times%20controller/location_controller.dart';
import 'package:project/features/model/sql_db.dart';

DateTime mycurrentdate = DateTime.now();

class GetResponseBody extends GetxController {
  final LocationController locationctrl = Get.find();
  SqlDb sqldb = SqlDb();
  late DateTime endDate;

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
      _updateDates();
      await _getCalendarData();
    }
  }

  void _updateDates() {
    mycurrentdate = DateTime.now();
    endDate = DateTime(DateTime.now().year, 12, 31);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

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
  // print('Error parsing time: $date - Error: $e');
  //     return DateTime.now();
  //   }
  // }

  Future<void> _defineRefreshingDate() async {
    final refreshingdate = endDate.add(Duration(seconds: 1));
    await sqldb.insertdata(
      "INSERT OR REPLACE INTO prayer_times_meta (key, value) VALUES ('refreshing_date', '${_formatDate(refreshingdate)}')",
    );
  }

  Future<bool> _isAfterRefreshingDate() async {
    try {
      final result = await sqldb.readdata(
        "SELECT value FROM prayer_times_meta WHERE key = 'refreshing_date'",
      );

      if (result.isEmpty) {
        await _defineRefreshingDate();
        return false;
      }

      DateTime refreshingDate = endDate.add(Duration(seconds: 1));
      DateTime now = DateTime.now();

      if (now.isAfter(refreshingDate)) {
        await sqldb.deletedata(
          "DELETE FROM prayer_times_meta WHERE key = 'refreshing_date'",
        );
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
      final result = await sqldb.readdata(
        "SELECT response_data, last_updated FROM prayer_times ORDER BY last_updated DESC LIMIT 1",
      );

      if (result.isEmpty) return true;

      final data = result.first;
      final lastUpdated = DateTime.parse(data['last_updated']);
      final currentDate = DateTime.now();

      // Check if data is older than 30 days
      if (currentDate.difference(lastUpdated).inDays > 360) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking data validity: $e');
      return true;
    }
  }

  Future<bool> initileresponse() async {
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
        duration: const Duration(seconds: 10),
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        padding: const EdgeInsets.all(20),
      );
      await _getCalendarData();
      return true;
    }
    return false;
  }

  Future<void> demendeNewResponse() async {
    _updateDates();
    await _getCalendarData();
  }

  Future<void> _getCalendarData() async {
    try {
      print('=== _getCalendarData Start ===');
      await locationctrl.determinePosition();
      print('Location: ${locationctrl.latitude}, ${locationctrl.longtude}');

      final response = await http.get(
        Uri.parse(
          "https://api.aladhan.com/v1/calendar/2025?latitude=${locationctrl.latitude}&longitude=${locationctrl.longtude}&method=19&school=0&timezonestring=Africa/Algiers&tune=0,-1,0,0,4,4,0,0,0&midnightMode=0&latitudeAdjustmentMethod=2&calendarMethod=MATHEMATICAL&iso8601=false",
        ),
      );

      print('API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final escapedJson = response.body.replaceAll("'", "@@@");
        print('Data received and escaped');
        await sqldb.insertdata(
          "INSERT INTO prayer_times (response_data, last_updated) VALUES ('$escapedJson', '${DateTime.now().toIso8601String()}')",
        );
        print('Data inserted into SQL database');
        Get.find<FetchPrayerFromDate>().loadPrayerData();
      } else {
        print('Failed to fetch calendar data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _getCalendarData: $e');
    }
  }
}
