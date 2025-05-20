import 'dart:convert';
// import 'dart:developer';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/get_response_body.dart';
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

  Future<void> loadPrayerData() async {
    try {
      List<Map<String, dynamic>>? sqlData = await sqldb.readdata(
        "SELECT * FROM prayer_times ORDER BY last_updated DESC LIMIT 1 ",
      );

      if (sqlData != null && sqlData.isNotEmpty) {
        // Access the response_data field instead of data
        String prayerDataStr = sqlData[0]['response_data']
            .toString()
            .replaceAll("@@@", "'");

        // Parse the JSON string
        Map<String, dynamic> newData = jsonDecode(prayerDataStr);

        // Access the data field from the parsed JSON
        if (newData.containsKey('data')) {
          prayerData = newData['data'];

          String currentDateStr = _formatDate(DateTime.now());
          if (!prayerData.containsKey(currentDateStr)) {
            await responsectrl.initileresponse();
            return;
          }

          await fetchPrayerTimes();
          update();
        } else {
          print("No 'data' field found in the parsed JSON");
        }
      } else {
        print("No SQL data found");
      }
    } catch (e) {
      print('Error loading prayer data: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

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
      prayersdayskeys = prayerData.keys.toList();
      for (int i = 0; i < prayersdayskeys.length; i++) {
        // The correct way to access timings
        var timings = prayerData[prayersdayskeys[i]]['timings'];
        
        if (i == 0) {
          print("________________________________________________________");
          print("Debug - prayerData structure: ${prayerData[prayersdayskeys[0]]}");
          print("Debug - timings: $timings");
          print("Debug - Fajr time: ${timings['Fajr']}");
          print("________________________________________________________");
        }
        
        Map<String, String> dailyPrayers = {
          'Fajr': timings['Fajr'],
          'Sunrise': timings['Sunrise'],
          'Dhuhr': timings['Dhuhr'],
          'Asr': timings['Asr'],
          'Maghrib': timings['Maghrib'],
          'Isha': timings['Isha'],
        };
        //Add every value to his key on prayersdays map
        prayersdays[prayersdayskeys[i]] = dailyPrayers;
      }
    } catch (e) {
      print('Error in fetchPrayerTimes: $e');
      print('Current prayerData: $prayerData');
    }
  }
}

// make a road map for the solution and us ai for doing it
