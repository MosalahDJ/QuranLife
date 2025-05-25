// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/fetch_prayer_from_date.dart';

class DeterminePrayersController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  final FetchPrayerFromDate fpfctrl = Get.find();

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
      print('Error parsing time: $time - Error: $e');
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
      print('Error parsing next day fajr time: $time - Error: $e');
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
    try {
      var now = DateTime.now();
      String day = now.day.toString().padLeft(2, '0');
      String month = now.month.toString();
      // TODO: Handle the case where month is not found
      if (!fpfctrl.prayersdays.containsKey(month)) {
        print('Month $month not found in prayersdays');
        throw Exception('Month $month not found in prayer times data');
      }

      var monthData = fpfctrl.prayersdays[month]!;

      if (!monthData.containsKey(day)) {
        print('Day $day not found in month $month');
        throw Exception('Day $day not found in prayer times data');
      }

      List salatday(String salat) {
        //TODO
        var prayerTime = fpfctrl.prayersdays[month]![day]![salat];
        // print('$salat time: $prayerTime');
        return [salat, _parseTime(prayerTime!)]; // The null check happens here
      }

      //we use this list for store iside it list's of prayer name and prayer time
      var prayers = [
        salatday('Fajr'),
        salatday('Sunrise'),
        salatday('Dhuhr'),
        salatday('Asr'),
        salatday('Maghrib'),
        salatday('Isha'),
      ];

      // Add next day's Fajr to prayers list
      var nextDayFajr = _parsenextdayfajr(
        fpfctrl
            .prayersdays["${now.month}"]!["${now.add(const Duration(days: 1)).day}"]!['Fajr']!,
      );

      //loop of prayers list for checking current and next prayer and time untile next
      //we use "as datetime" and "as string" here beacause these data is requerd to be dynamic
      //in prayer's list and it requred to be String or Date time here
      for (int i = 0; i < prayers.length - 1; i++) {
        if (now.isAfter(prayers[i][1] as DateTime) &&
            now.isBefore(prayers[i + 1][1] as DateTime)) {
          currentPrayer.value = prayers[i][0] as String;
          nextPrayer.value = prayers[i + 1][0] as String;
          nextPrayerTime.value = _formatTime(prayers[i + 1][1] as DateTime);
          timeUntilNext.value = _formatTimeUntil(prayers[i + 1][1] as DateTime);
          currentPrayertime.value = _formatTime(prayers[i][1] as DateTime);
          return;
        }
      }

      // If we're after Isha

      if (now.isAfter(
        _parseTime(fpfctrl.prayersdays["${now.month}"]![day]!['Isha']!),
        // _parseTime(fpfctrl.prayersdays[_formatDate(now)]['Isha']!),
      )) {
        currentPrayer.value = 'Isha';
        nextPrayer.value = 'Fajr';
        nextPrayerTime.value = _formatTime(nextDayFajr);
        timeUntilNext.value = _formatTimeUntil(nextDayFajr);
      }

      //if we are before Fajr

      if (now.isBefore(
        _parseTime(fpfctrl.prayersdays["${now.month}"]![day]!['Fajr']!),
      )) {
        currentPrayer.value = 'Isha';
        nextPrayer.value = 'Fajr';
        nextPrayerTime.value = _formatTime(prayers[0][1] as DateTime);
        timeUntilNext.value = _formatTimeUntil(prayers[0][1] as DateTime);
      }
    } catch (e) {
      // print('Error determining prayer times: $e');
      // print('Current prayersdays state: ${fpfctrl.prayersdays}');
      currentPrayer.value = "-";
      nextPrayer.value = "-";
      nextPrayerTime.value = "-";
      timeUntilNext.value = "-";
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
