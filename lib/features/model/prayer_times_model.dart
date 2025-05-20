import 'package:intl/intl.dart';

class PrayerTimesData {
  final Map<String, List<DayData>> monthlyData;

  PrayerTimesData({required this.monthlyData});

  factory PrayerTimesData.fromJson(Map<String, dynamic> json) {
    Map<String, List<DayData>> data = {};
    
    json.forEach((month, monthData) {
      if (monthData is List) {
        // Convert month to string if it's an integer
        String monthKey = month.toString();
        data[monthKey] = monthData.map((day) => DayData.fromJson(day)).toList();
      }
    });

    return PrayerTimesData(monthlyData: data);
  }

  DayData? getDayData(DateTime date) {
    String month = date.month.toString();
    if (!monthlyData.containsKey(month)) return null;
    
    return monthlyData[month]?.firstWhere(
      (day) => day.gregorianDate == DateFormat('dd-MM-yyyy').format(date),
      orElse: () => DayData(
        timings: Timings(
          fajr: '',
          sunrise: '',
          dhuhr: '',
          asr: '',
          sunset: '',
          maghrib: '',
          isha: '',
          imsak: '',
          midnight: '',
          firstthird: '',
          lastthird: ''
        ),
        date: DateInfo(
          readable: '',
          timestamp: 0,
          gregorian: GregorianDate(
            date: '',
            format: '',
            day: '',
            weekday: {},
            month: {},
            year: ''
          ),
          hijri: HijriDate(
            date: '',
            format: '',
            day: '',
            weekday: {},
            month: {},
            year: '',
            holidays: []
          )
        ),
        meta: Meta(
          latitude: 0,
          longitude: 0,
          timezone: '',
          method: {}
        )
      ),
    );
  }
}

class DayData {
  final Timings timings;
  final DateInfo date;
  final Meta meta;

  DayData({
    required this.timings,
    required this.date,
    required this.meta,
  });

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      timings: Timings.fromJson(json['timings']),
      date: DateInfo.fromJson(json['date']),
      meta: Meta.fromJson(json['meta']),
    );
  }

  String get gregorianDate => date.gregorian.date;
}

class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final String firstthird;
  final String lastthird;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.firstthird,
    required this.lastthird,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    String cleanTime(String time) => time.split(' ')[0]; // Remove timezone

    return Timings(
      fajr: cleanTime(json['Fajr']),
      sunrise: cleanTime(json['Sunrise']),
      dhuhr: cleanTime(json['Dhuhr']),
      asr: cleanTime(json['Asr']),
      sunset: cleanTime(json['Sunset']),
      maghrib: cleanTime(json['Maghrib']),
      isha: cleanTime(json['Isha']),
      imsak: cleanTime(json['Imsak']),
      midnight: cleanTime(json['Midnight']),
      firstthird: cleanTime(json['Firstthird']),
      lastthird: cleanTime(json['Lastthird']),
    );
  }
}

class DateInfo {
  final String readable;
  final int timestamp;
  final GregorianDate gregorian;
  final HijriDate hijri;

  DateInfo({
    required this.readable,
    required this.timestamp,
    required this.gregorian,
    required this.hijri,
  });

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      readable: json['readable'],
      timestamp: int.tryParse(json['timestamp'].toString()) ?? 0, // Safely parse to int
      gregorian: GregorianDate.fromJson(json['gregorian']),
      hijri: HijriDate.fromJson(json['hijri']),
    );
  }
}

class GregorianDate {
  final String date;
  final String format;
  final String day;
  final Map<String, String> weekday;
  final Map<String, dynamic> month; // month can be {number: 1, en: January} or similar
  final String year;

  GregorianDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'],
      format: json['format'],
      day: json['day'].toString(),
      weekday: Map<String, String>.from(json['weekday']),
      month: json['month'] is Map ? Map<String, dynamic>.from(json['month']) : {'number': 0, 'en': 'Unknown'}, // Ensure month is a map
      year: json['year'].toString(),
    );
  }
}

class HijriDate {
  final String date;
  final String format;
  final String day;
  final Map<String, String> weekday;
  final Map<String, dynamic> month; // month can be {number: 7, en: Rajab, ar: رَجَب, days: 30} or similar
  final String year;
  final List<String> holidays;

  HijriDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
    required this.holidays,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'],
      format: json['format'],
      day: json['day'].toString(),
      weekday: Map<String, String>.from(json['weekday']),
      month: json['month'] is Map ? Map<String, dynamic>.from(json['month']) : {'number': 0, 'en': 'Unknown', 'ar': '', 'days': 0}, // Ensure month is a map
      year: json['year'].toString(),
      holidays: List<String>.from(json['holidays'] ?? []),
    );
  }
}

class Meta {
  final double latitude;
  final double longitude;
  final String timezone;
  final Map<String, dynamic> method;

  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.method,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0, // Safely parse to double
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0, // Safely parse to double
      timezone: json['timezone'],
      method: json['method'] is Map ? Map<String, dynamic>.from(json['method']) : {},
    );
  }
}