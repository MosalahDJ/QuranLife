import 'dart:convert';
// import 'dart:developer';
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

        if (newData.containsKey('data')) {
          prayerTimesData = PrayerTimesData.fromJson(newData['data']);

          // Check if we have data for current date
          var currentDayData = prayerTimesData?.getDayData(DateTime.now());
          if (currentDayData == null) {
            await responsectrl.initileresponse();
            return;
          }

          await fetchPrayerTimes();
          update();
        }
      }
    } catch (e, stack) {
      print('Error loading prayer data: $e');
      print('Stack trace: $stack');
    }
  }

  RxMap<String, Map<String, Map<String, String>>> prayersdays =
      <String, Map<String, Map<String, String>>>{}.obs;
  DateTime currentDate = DateTime.now();

  // func for getting akey from list of keys
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
        print('prayerTimesData is null in fetchPrayerTimes');
        return;
      }

      // Store the first day's date from the response
      firstResponseDate = DateTime.parse(
        prayerTimesData!.monthlyData.values.first.first.date.gregorian.date,
      );

      // Clear previous data
      prayersdays.clear();

      prayerTimesData?.monthlyData.forEach((monthKey, monthDaysData) {
        // monthKey is already a String (e.g., "1", "2")
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
        } else {
          print('No days available for month $monthKey');
        }
      });
      // Update prayersdayskeys if you still use it, e.g., for displaying month tabs
      prayersdayskeys = prayersdays.keys.toList();
      update(); // Notify GetX listeners
    } catch (e, stack) {
      print('Error in fetchPrayerTimes: $e');
      print('Stack trace: $stack');
    }
  }
}

// make a road map for the solution and us ai for doing it
