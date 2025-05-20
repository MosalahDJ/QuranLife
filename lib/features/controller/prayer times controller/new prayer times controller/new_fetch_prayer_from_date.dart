import 'dart:convert';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/get_response_body.dart';
import 'package:project/features/model/prayer_times_model%20.dart';
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

  // String _formatDate(DateTime date) {
  //   return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  // }

  final GetResponseBody responsectrl = Get.find();

  RxMap prayersdays = <String, Map<String, String>>{}.obs;
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
      if (prayerTimesData == null) return;

      prayerTimesData?.monthlyData.forEach((month, days) {
        if (days.isNotEmpty) {
          var firstDay = days.first;
          Map<String, String> dailyPrayers = {
            'Fajr': firstDay.timings.fajr,
            'Sunrise': firstDay.timings.sunrise,
            'Dhuhr': firstDay.timings.dhuhr,
            'Asr': firstDay.timings.asr,
            'Maghrib': firstDay.timings.maghrib,
            'Isha': firstDay.timings.isha,
          };
          prayersdays[month] = dailyPrayers;
        }
      });
      update();
    } catch (e, stack) {
      print('Error in fetchPrayerTimes: $e');
      print('Stack trace: $stack');
    }
  }
}

// make a road map for the solution and us ai for doing it
