// ignore_for_file: avoid_print
import 'dart:developer';

import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';
import 'package:project/features/controller/prayer%20times%20controller/location_controller.dart';
import 'package:http/http.dart' as http;
import 'package:project/features/controller/prayer%20times%20controller/new%20prayer%20times%20controller/sql_db.dart';

class NewResponseBody extends GetxController {
  final LocationController locationctrl = Get.find();
  SqlDb sqldb = SqlDb();
  @override
  onInit() async {
    super.onInit();
    await getCalendarData();
  }

  Future<void> getCalendarData() async {
    try {
      await locationctrl.determinePosition();

      final response = await http.get(
        Uri.parse(
          "https://api.aladhan.com/v1/calendar/2025?latitude=${locationctrl.latitude}&longitude=${locationctrl.longtude}&method=19&school=0&timezonestring=Africa/Algiers&tune=0,-1,0,0,4,4,0,0,0&midnightMode=0&latitudeAdjustmentMethod=2&calendarMethod=MATHEMATICAL&iso8601=false",
        ),
      );

      if (response.statusCode == 200) {
        // Escape single quotes in the response body by replacing ' with ''
        final escapedJson = response.body.replaceAll("'", "@@@");
        await sqldb.insertdata(
          "INSERT INTO prayer_times (response_data, last_updated) VALUES ('$escapedJson', '${DateTime.now().toIso8601String()}')",
        );
        List<Map<String, dynamic>> newdata = await sqldb.readdata(
          "SELECT * FROM prayer_times WHERE last_updated = (SELECT MAX(last_updated) FROM prayer_times)",
        );
        log(newdata.toString());
        // Notify FetchPrayerFromDate to reload data
        Get.find<FetchPrayerFromDate>().loadPrayerData();
      } else {
        print('Failed to fetch calendar data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching calendar data: $e');
    }
  }
}


/*
1 location ctrl
2 get response ctrl
3 fetch prayer from date ctrl
4 determine prayer ctrl
5 times page ctrl
*/