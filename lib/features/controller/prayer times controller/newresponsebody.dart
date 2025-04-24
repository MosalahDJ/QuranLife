// ignore_for_file: avoid_print
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';
import 'package:project/features/controller/prayer%20times%20controller/location_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewResponseBody extends GetxController {
  final LocationController locationctrl = Get.find();
  late SharedPreferences prefs;

  Future<void> getCalendarData() async {
    try {
      await locationctrl.determinePosition();

      final response = await http.get(
        Uri.parse(
          "https://api.aladhan.com/v1/calendar/2025?latitude=${locationctrl.latitude}&longitude=${locationctrl.longtude}&method=19&school=0&timezonestring=Africa/Algiers&tune=0,-1,0,0,4,4,0,0,0&midnightMode=0&latitudeAdjustmentMethod=2&calendarMethod=MATHEMATICAL&iso8601=false",
        ),
      );

      if (response.statusCode == 200) {
        prefs = await SharedPreferences.getInstance();
        await prefs.setString("responsebody", response.body);

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
