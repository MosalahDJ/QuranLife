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
      print('=== loadPrayerData Start ===');
      List<Map<String, dynamic>>? sqlData = await sqldb.readdata(
        "SELECT * FROM prayer_times ORDER BY last_updated DESC LIMIT 1 ",
      );
      print('SQL Data retrieved: ${sqlData?.length ?? 0} records');

      if (sqlData != null && sqlData.isNotEmpty) {
        String prayerDataStr = sqlData[0]['response_data']
            .toString()
            .replaceAll("@@@", "'");
        print('Prayer data string length: ${prayerDataStr.length}');

        Map<String, dynamic> newData = jsonDecode(prayerDataStr);
        print('JSON decoded successfully');

        if (newData.containsKey('data')) {
          prayerTimesData = PrayerTimesData.fromJson(newData['data']);
          print('PrayerTimesData object created');
          await fetchPrayerTimes();
        } else {
          print('No data key found in JSON');
        }
      } else {
        print('No prayer times data found in database');
      }
    } catch (e, stack) {
      print('Error loading prayer data: $e');
      print('Stack trace: $stack');
    }
  }

  Future<void> fetchPrayerTimes() async {
    try {
      print('=== fetchPrayerTimes Start ===');
      if (prayerTimesData == null) {
        print('prayerTimesData is null in fetchPrayerTimes');
        return;
      }

      print('Monthly Data count: ${prayerTimesData!.monthlyData.length}');
      if (prayerTimesData!.monthlyData.isNotEmpty) {
        // Add debug print to see the actual date string
        String firstDateStr = prayerTimesData!.monthlyData.values.first.first.date.gregorian.date;
        print('Attempting to parse date: $firstDateStr');
        
        try {
          firstResponseDate = DateTime.parse(firstDateStr);
          print('Successfully parsed first response date: $firstResponseDate');
        } catch (e) {
          print('Error parsing date: $e');
          return;
        }

        prayersdays.clear();
        print('Cleared previous prayer days');

        for (var entry in prayerTimesData!.monthlyData.entries) {
          String monthKey = entry.key;
          var monthDaysData = entry.value;
          print('Processing month: $monthKey');
          
          Map<String, Map<String, String>> daysInMonthMap = {};

          for (var dayData in monthDaysData) {
            try {
              // Ensure day is properly formatted
              String dayKey = dayData.date.gregorian.day.toString().padLeft(2, '0');
              print('Processing day: $dayKey in month: $monthKey');

              Map<String, String> dailyPrayers = {
                'Fajr': dayData.timings.fajr.split(' ')[0],  // Remove timezone if present
                'Sunrise': dayData.timings.sunrise.split(' ')[0],
                'Dhuhr': dayData.timings.dhuhr.split(' ')[0],
                'Asr': dayData.timings.asr.split(' ')[0],
                'Maghrib': dayData.timings.maghrib.split(' ')[0],
                'Isha': dayData.timings.isha.split(' ')[0],
              };
              daysInMonthMap[dayKey] = dailyPrayers;
            } catch (e) {
              print('Error processing day data: $e');
              continue;
            }
          }

          String paddedMonthKey = monthKey.padLeft(2, '0');
          if (daysInMonthMap.isNotEmpty) {
            prayersdays[paddedMonthKey] = daysInMonthMap;
            print('Added month $paddedMonthKey with ${daysInMonthMap.length} days');
          }
        }

        print('Final prayersdays map structure:');
        prayersdays.forEach((month, days) {
          print('Month $month has ${days.length} days');
        });
        
        update(); // Notify GetX listeners of the change
      }
    } catch (e, stack) {
      print('Error in fetchPrayerTimes: $e');
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
}

// make a road map for the solution and us ai for doing it
