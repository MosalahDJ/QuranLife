import 'dart:async';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';

class DeterminePrayersController extends GetxController {
  final FetchPrayerFromDate fpfctrl = Get.find();

  @override
  void onInit() {
    print("________________________________________________");
    print('DeterminePrayersController onInit called');
    print("________________________________________________");

    super.onInit();
    _startTimer();
  }


  Timer? _timer;
  RxString currentdate = "".obs;
  RxString currentPrayer = "".obs;
  RxString currentPrayertime = "".obs;
  RxString nextPrayer = "".obs;
  RxString nextPrayerTime = "".obs;
  RxString timeUntilNext = "".obs;
  RxBool isnextprayer = false.obs;

  //timer func for refreshing date and prayertime periodicly after each second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentdate.value =
          "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";
      determineCurrentPrayer();
    });
  }

  //we use this func for changing data type of time from string to Datetime
  //because we cauth it as String from the api
  DateTime _parseTime(String time) {
    try {
      var now = DateTime.now();
      var parts = time.trim().split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid time format: $time');
      }
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0].trim()),
        int.parse(parts[1].trim()),
      );
    } catch (e) {
      // print('Error parsing time: $time - Error: $e');
      // Return a default time in case of error
      return DateTime.now();
    }
  }

  //we use this func for changing data type of time from string to Datetime
  //because we cauth it as String from the api
  //I use this func not the above func because i need in this case tomorow's fajr
  DateTime _parsenextdayfajr(String time) {
    try {
      var tomorow = DateTime.now().add(const Duration(days: 1));
      var parts = time.trim().split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid time format: $time');
      }
      return DateTime(
        tomorow.year,
        tomorow.month,
        tomorow.day,
        int.parse(parts[0].trim()),
        int.parse(parts[1].trim()),
      );
    } catch (e) {
      // print('Error parsing next day fajr time: $time - Error: $e');
      // Return a default time in case of error
      return DateTime.now().add(const Duration(days: 1));
    }
  }

  //making time format for time untile
  String _formatTimeUntil(DateTime target) {
    var now = DateTime.now();
    var difference = target.difference(now);
    var hours = difference.inHours;
    var minutes = difference.inMinutes % 60;
    var seconds = difference.inSeconds % 60;
    //we use padleft to esure that  always have two nums
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  //making time format for next time
  String _formatTime(DateTime target) {
    var hours = target.hour.toString().padLeft(2, '0');
    var minute = target.minute.toString().padLeft(2, '0');
    return "${hours.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  //determining current prayer time
  void determineCurrentPrayer() {
    print('=== Starting determineCurrentPrayer ===');
    try {
      var now = DateTime.now();
      print('Current time: $now');

      String day = now.day.toString().padLeft(2, '0');
      String month = now.month.toString();
      print('Looking for day: $day, month: $month');

      if (!fpfctrl.prayersdays.containsKey(month)) {
        print('ERROR: Month $month not found in prayersdays');
        print('Available months: ${fpfctrl.prayersdays.keys}');
        throw Exception('Month $month not found in prayer times data');
      }
      print('Month $month found successfully');

      var monthData = fpfctrl.prayersdays[month]!;
      print('Month data keys: ${monthData.keys}');

      if (!monthData.containsKey(day)) {
        print('ERROR: Day $day not found in month $month');
        print('Available days in month $month: ${monthData.keys}');
        throw Exception('Day $day not found in prayer times data');
      }
      print('Day $day found successfully');

      List salatday(String salat) {
        print('Processing prayer: $salat');
        var prayerTime = fpfctrl.prayersdays[month]![day]![salat];
        print('Raw prayer time for $salat: $prayerTime');
        var parsedTime = _parseTime(prayerTime!);
        print('Parsed time for $salat: $parsedTime');
        return [salat, parsedTime];
      }

      print('Building prayers list...');
      //we use this list for store iside it list's of prayer name and prayer time
      var prayers = [
        salatday('Fajr'),
        salatday('Sunrise'),
        salatday('Dhuhr'),
        salatday('Asr'),
        salatday('Maghrib'),
        salatday('Isha'),
      ];
      print(
        'Prayers list built successfully: ${prayers.map((p) => '${p[0]}: ${p[1]}').toList()}',
      );

      // Add next day's Fajr to prayers list
      print('Getting next day Fajr...');
      var nextDay = now.add(const Duration(days: 1));
      print('Next day: ${nextDay.day}');

      var nextDayFajr = _parsenextdayfajr(
        fpfctrl.prayersdays["${now.month}"]!["${nextDay.day}"]!['Fajr']!,
      );
      print("________________________________________________");
      print('Next day Fajr: $nextDayFajr');
      print("________________________________________________");

      print('Starting prayer time comparison loop...');
      //loop of prayers list for checking current and next prayer and time untile next
      //we use "as datetime" and "as string" here beacause these data is requerd to be dynamic
      //in prayer's list and it requred to be String or Date time here
      for (int i = 0; i < prayers.length - 1; i++) {
        print(
          'Checking if now ($now) is between ${prayers[i][0]} (${prayers[i][1]}) and ${prayers[i + 1][0]} (${prayers[i + 1][1]})',
        );

        if (now.isAfter(prayers[i][1] as DateTime) &&
            now.isBefore(prayers[i + 1][1] as DateTime)) {
          print('Found current prayer period!');
          currentPrayer.value = prayers[i][0] as String;
          nextPrayer.value = prayers[i + 1][0] as String;
          nextPrayerTime.value = _formatTime(prayers[i + 1][1] as DateTime);
          timeUntilNext.value = _formatTimeUntil(prayers[i + 1][1] as DateTime);
          currentPrayertime.value = _formatTime(prayers[i][1] as DateTime);

          print('Set values:');
          print('  currentPrayer: ${currentPrayer.value}');
          print('  nextPrayer: ${nextPrayer.value}');
          print('  nextPrayerTime: ${nextPrayerTime.value}');
          print('  timeUntilNext: ${timeUntilNext.value}');
          print('  currentPrayertime: ${currentPrayertime.value}');
          return;
        }
      }

      print('Not in regular prayer period, checking special cases...');

      // If we're after Isha
      var ishaTime = _parseTime(
        fpfctrl.prayersdays["${now.month}"]![day]!['Isha']!,
      );
      print('Checking if after Isha ($ishaTime)...');

      if (now.isAfter(ishaTime)) {
        print('After Isha - setting to Isha/Fajr');
        currentPrayer.value = 'Isha';
        nextPrayer.value = 'Fajr';
        nextPrayerTime.value = _formatTime(nextDayFajr);
        timeUntilNext.value = _formatTimeUntil(nextDayFajr);

        print('Set values (after Isha):');
        print('  currentPrayer: ${currentPrayer.value}');
        print('  nextPrayer: ${nextPrayer.value}');
        print('  nextPrayerTime: ${nextPrayerTime.value}');
        print('  timeUntilNext: ${timeUntilNext.value}');
        return;
      }

      //if we are before Fajr
      var fajrTime = _parseTime(
        fpfctrl.prayersdays["${now.month}"]![day]!['Fajr']!,
      );
      print('Checking if before Fajr ($fajrTime)...');

      if (now.isBefore(fajrTime)) {
        print('Before Fajr - setting to Isha/Fajr');
        currentPrayer.value = 'Isha';
        nextPrayer.value = 'Fajr';
        nextPrayerTime.value = _formatTime(prayers[0][1] as DateTime);
        timeUntilNext.value = _formatTimeUntil(prayers[0][1] as DateTime);

        print('Set values (before Fajr):');
        print('  currentPrayer: ${currentPrayer.value}');
        print('  nextPrayer: ${nextPrayer.value}');
        print('  nextPrayerTime: ${nextPrayerTime.value}');
        print('  timeUntilNext: ${timeUntilNext.value}');
        return;
      }

      print('No matching condition found - this should not happen!');
    } catch (e) {
      print('=== ERROR CAUGHT ===');
      print('Error determining prayer times: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
      print('Current prayersdays state: ${fpfctrl.prayersdays}');
      print('Setting all values to "-"');

      currentPrayer.value = "-";
      nextPrayer.value = "-";
      nextPrayerTime.value = "-";
      timeUntilNext.value = "-";

      print('=== END ERROR HANDLING ===');
    }
    print('=== End determineCurrentPrayer ===');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
