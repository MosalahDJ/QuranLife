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
    print('=== GetResponseBody initialized ===');
    super.onInit();
    _updateDates();
    ever(_checkRefreshTimer, (_) => _checkAndRefresh());
    _checkAndRefreshOnStartup();
    print('Initial setup completed. endDate: $endDate');
  }

  final _checkRefreshTimer = 0.obs;

  Future<void> _checkAndRefreshOnStartup() async {
    print('=== Checking for refresh on startup ===');
    if (await _shouldRefreshForNewYear()) {
      print('Refresh needed on startup');
      _updateDates();
      await _getCalendarData();
    } else {
      print('No refresh needed on startup');
    }
  }

  void startPeriodicCheck() {
    print('Starting periodic check timer');
    Timer.periodic(const Duration(hours: 1), (timer) {
      print('Periodic check triggered at ${DateTime.now()}');
      _checkRefreshTimer.value = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _updateDates() {
    mycurrentdate = DateTime.now();
    endDate = DateTime(DateTime.now().year, 12, 31);
    print('Dates updated - Current: $mycurrentdate, End: $endDate');
  }

  Future<bool> _shouldRefreshForNewYear() async {
    print('=== Checking if refresh is needed ===');
    try {
      final result = await sqldb.readdata(
        "SELECT response_data, last_updated FROM prayer_times ORDER BY last_updated DESC LIMIT 1",
      );

      if (result.isEmpty) {
        print('No existing data found, refresh needed');
        return true;
      }

      final data = result.first;
      final lastUpdated = DateTime.parse(data['last_updated']);
      final currentDate = DateTime.now();

      print('Last update: $lastUpdated');
      print('Current date: $currentDate');

      if (currentDate.year > lastUpdated.year) {
        print('New year detected: ${currentDate.year} > ${lastUpdated.year}');
        return true;
      }

      if (currentDate.difference(lastUpdated).inDays > 360) {
        print('Data is older than 360 days');
        return true;
      }

      print('No refresh needed');
      return false;
    } catch (e) {
      print('Error checking refresh need: $e');
      return true;
    }
  }

  Future<void> _checkAndRefresh() async {
    print('=== Checking and refreshing data ===');
    if (await _shouldRefreshForNewYear()) {
      print('Refresh triggered for new year or old data');
      _updateDates();
      await _getCalendarData();
    }
  }

  Future<bool> initileresponse() async {
    print('=== Initializing response ===');
    bool needsRefresh = await _shouldRefreshForNewYear();
    print('Needs refresh: $needsRefresh');

    if (needsRefresh) {
      _updateDates();
      Get.snackbar(
        "downloading_data".tr,
        "please_be_patient".tr,
        colorText: Get.isDarkMode ? const Color(0xFFFFFFFF) : const Color.fromARGB(255, 0, 0, 0),
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
    try {
      print('=== Manual data refresh requested ===');
      _updateDates();
      await _getCalendarData();
      print('Manual refresh completed successfully');
    } catch (e) {
      print('Error in manual refresh: $e');
      rethrow;
    }
  }

  Future<void> _getCalendarData() async {
    try {
      print('=== _getCalendarData Start ===');
      await locationctrl.determinePosition();
      print('Location: ${locationctrl.latitude}, ${locationctrl.longtude}');

      final currentYear = DateTime.now().year;
      print('Fetching data for year: $currentYear');

      final response = await http.get(
        Uri.parse(
          "https://api.aladhan.com/v1/calendar/$currentYear?latitude=${locationctrl.latitude}&longitude=${locationctrl.longtude}&method=19&school=0&timezonestring=Africa/Algiers&tune=0,-1,0,0,4,4,0,0,0&midnightMode=0&latitudeAdjustmentMethod=2&calendarMethod=MATHEMATICAL&iso8601=false",
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
        print('Prayer data loaded successfully');
      } else {
        print('Failed to fetch calendar data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _getCalendarData: $e');
    }
  }
}
