import 'dart:convert';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/get_response_body.dart';
import 'package:project/features/model/prayer_times_model.dart';
import 'package:project/features/model/sql_db.dart';

SqlDb sqldb = SqlDb();

Map<String, dynamic> prayerData = {};

class FetchPrayerFromDate extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadPrayerData();
    // Listen to data changes
    ever(dataUpdateTrigger, (_) => loadPrayerData());
  }

  final dataUpdateTrigger = 0.obs;
  PrayerTimesData? prayerTimesData;
  final GetResponseBody responsectrl = Get.find();

  // Function to parse a time string
  DateTime parseTime(String time) {
    try {
      var parts = time.trim().split('-');
      if (parts.length != 3) {
        throw FormatException('Invalid time format: $time');
      }
      return DateTime(
        int.parse(parts[2].trim()),
        int.parse(parts[1].trim()),
        int.parse(parts[0].trim()),
      );
    } catch (e) {
      // print("=========================================================");
      // print('Error parsing time: $time - Error: $e');
      // print("=========================================================");

      // Return a default time in case of error
      return DateTime(01, 01, DateTime.now().year);
    }
  }

  Future<void> loadPrayerData() async {
    try {
      List<Map<String, dynamic>>? sqlData = await sqldb.readdata(
        "SELECT * FROM prayer_times ORDER BY last_updated DESC LIMIT 1 ",
      );

      if (sqlData != null && sqlData.isNotEmpty) {
        String prayerDataStr = sqlData[0]['response_data']
            .toString()
            .replaceAll("@@@", "'");

        Map<String, dynamic> newData = jsonDecode(prayerDataStr);
        // print("=========================================================");
        // print("new data : all data is here $newData");
        // print("=========================================================");

        if (newData.containsKey('data')) {
          prayerTimesData = PrayerTimesData.fromJson(newData['data']);
          // print("=========================================================");
          // print("prayer times data newData['data']: $newData");
          // print("=========================================================");

          await fetchPrayerTimes(); // Call fetchPrayerTimes after data is loaded
        } else {
          // print("=========================================================");
          // print('No data key in prayer times response');
          // print("=========================================================");
        }
      } else {
        // print("=========================================================");
        // print('No prayer times data found in database');
        // print("=========================================================");
      }
    } catch (e) {
      // print("=========================================================");
      // print('Error loading prayer data: $e');
      // print("=========================================================");

      // print('Stack trace: $stack');
    }
  }

  RxMap<String, Map<String, Map<String, String>>> prayersdays =
      <String, Map<String, Map<String, String>>>{}.obs;
  DateTime currentDate = DateTime.now();

  int daysindata() {
    int result = 0;
    for (int i = 1; i <= prayersdays.length; i++) {
      result += prayersdays["$i"]!.length;
    }
    return result;
  }

  // Function to get the date for a given index for check if we are in current
  // date to to display the current slat time with a differnt color
  String? getDateByIndex(int index) {
    if (firstResponseDate == null) return null;
    // Calculate the date for the given index
    final date = firstResponseDate!.add(Duration(days: index));

    // Format the date in the same format as before (YYYY-MM-DD)
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  DateTime? firstResponseDate; // Add this at class level
  List prayersdayskeys = [];

  Future<void> fetchPrayerTimes() async {
    try {
      if (prayerTimesData == null) {
        // print("=========================================================");
        // print('prayerTimesData is null in fetchPrayerTimes');
        // print("=========================================================");

        return;
      }

      // Store the first day's date from the response
      if (prayerTimesData!.monthlyData.isNotEmpty) {
        firstResponseDate = parseTime(
          prayerTimesData!.monthlyData.values.first.first.date.gregorian.date,
        );

        // Clear previous data

        prayersdays.clear();

        prayerTimesData?.monthlyData.forEach((monthKey, monthDaysData) {
          Map<String, Map<String, String>> daysInMonthMap = {};

          for (var dayData in monthDaysData) {
            // Extract day number from dayData.date.gregorian.day (it's a String)
            String dayKey = dayData.date.gregorian.day;

            Map<String, String> dailyPrayers = {
              'Fajr': dayData.timings.fajr,
              'Sunrise': dayData.timings.sunrise,
              'Dhuhr': dayData.timings.dhuhr,
              'Asr': dayData.timings.asr,
              'Sunset':
                  dayData
                      .timings
                      .sunset, // Assuming Sunset is available, if not use Maghrib
              'Maghrib': dayData.timings.maghrib,
              'Isha': dayData.timings.isha,
              // Add other prayers if needed
              'Imsak': dayData.timings.imsak,
              'Midnight': dayData.timings.midnight,
              'Firstthird': dayData.timings.firstthird,
              'Lastthird': dayData.timings.lastthird,
            };
            daysInMonthMap[dayKey] = dailyPrayers;
          }

          if (daysInMonthMap.isNotEmpty) {
            prayersdays[monthKey] = daysInMonthMap;
            
            // print("=========================================================");
            // print('RxMap<String, Map<String, Map<String, String>>> get prayersdays: $prayersdays');
            // print("=========================================================");
          } else {
            // print("=========================================================");
            // print('No days available for month $monthKey');
            // print("=========================================================");
          }
        });
        // Update prayersdayskeys if you still use it, e.g., for displaying month tabs
        prayersdayskeys = prayersdays.keys.toList();

        update(); // Notify GetX listeners
      } else {
        // print("=========================================================");
        // print('monthlyData is empty in fetchPrayerTimes');
        // print("=========================================================");
      }
    } catch (e) {
      // print("=========================================================");
      // print('Error in fetchPrayerTimes: $e');
      // print("=========================================================");

      // print('Stack trace: $stack');
    }
  }
}
