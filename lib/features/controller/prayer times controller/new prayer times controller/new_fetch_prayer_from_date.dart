import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/get_response_body.dart';
import 'package:project/features/model/prayer_times_model.dart';
import 'package:project/features/model/sql_db.dart';

SqlDb sqldb = SqlDb();

Map<String, dynamic> prayerData = {};

class NewFetchPrayerFromDate extends GetxController {
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
  List prayersdayskeys = [];

  // func for getting akey from list of keys
  String? getDateByIndex(int index) {
    final dates = prayersdayskeys;
    if (index >= 0 && index < dates.length) {
      return dates[index];
    }
    return null;
  }

  Future<void> fetchPrayerTimes() async {
    try {
      if (prayerTimesData == null) {
        print('prayerTimesData is null in fetchPrayerTimes');
        return;
      }

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
            'Sunset': dayData.timings.sunset, // Assuming Sunset is available, if not use Maghrib
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
      
      // // Update prayersdayskeys if you still use it, e.g., for displaying month tabs
      // prayersdayskeys = prayersdays.keys.toList();
      // // Sort month keys if necessary, e.g., numerically
      // prayersdayskeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      log('Updated prayersdays structure: ${prayersdays.toString()}');

      update(); // Notify GetX listeners
    } catch (e, stack) {
      print('Error in fetchPrayerTimes: $e');
      print('Stack trace: $stack');
    }
  }
}

// make a road map for the solution and us ai for doing it
