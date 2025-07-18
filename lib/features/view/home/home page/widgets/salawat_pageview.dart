import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:project/core/Utils/constants.dart';
import 'package:project/core/Utils/size_config.dart';
import 'package:project/core/widgets/drop_down_button.dart';
import 'package:project/features/controller/home%20controller/myhomecontroller.dart';
import 'package:project/features/controller/settings%20controllers/language_controller.dart';
import 'package:project/features/view/home/salat%20time/widgets/currunet_pray_time.dart';
import 'package:project/features/view/home/salat%20time/widgets/salwatpageview.dart';

class SalawatPageview extends StatelessWidget {
  SalawatPageview({super.key, required this.morebuttoncolor});
  final MyHomeController homectrl = Get.find();
  final HijriCalendar hijri = HijriCalendar.now();
  final LanguageController langctrl = Get.find();
  final Color morebuttoncolor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          Sizeconfig.screenheight! < 768
              ? Sizeconfig.screenheight! / 2.5
              : Sizeconfig.screenheight! / 3.3,
      child: PageView(
        controller: homectrl.salawatPageController,
        onPageChanged: (index) {
          homectrl.salawatPage.value = index;
        },
        children: [
          //salat time
          CurrentPrayTime(
            iconcolor: 
                            Get.isDarkMode ? Colors.white : Colors.black,
            morebuttoncolor: morebuttoncolor,
            moreOnpressed1: () {
              homectrl.showShareDialog(context);
            },
            title1: "share".tr,
            icondata: Icons.share,
            moreIconVisibility: true,
            textcolor2: Get.isDarkMode ? const Color(0xFFFFFFFF) : Colors.black,
            textcolor: Get.isDarkMode ? kmaincolor4 : kmaincolor,
            elevation: 2,
            color:
                Get.isDarkMode
                    ? kmaincolor2dark.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.7),
          ),
          //Salawattime
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  langctrl.language.value == "ar"
                      ? Row(
                        children: [
                          Text(
                            "  ${hijri.hDay}",
                            style: TextStyle(
                              color: morebuttoncolor,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            " - ${hijri.hMonth} - ",
                            style: TextStyle(
                              color: morebuttoncolor,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "${hijri.hYear}",
                            style: TextStyle(
                              color: morebuttoncolor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        "  ${hijri.hDay} - ${hijri.shortMonthName} - ${hijri.hYear}",
                        style: TextStyle(color: morebuttoncolor, fontSize: 18),
                      ),
                  DropDownButton(
                    ontap: () {
                      homectrl.showShareDialog(context);
                    },
                    buttontext: "share".tr,
                    color: 
                            Get.isDarkMode ? Colors.white : Colors.black,
                    
                    icon: Icons.share,
                    // buttontext2: title2,
                    // color2: color,
                    // icon2: icondata2,
                    // ontap2: moreOnpressed2,
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: Ink(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Salwatpageview(
                            icon: "lib/core/assets/images/salat_icons/fajr.png",
                            salatname: "fajr".tr,
                            salattime: "Fajr",
                          ),
                          Salwatpageview(
                            icon: "lib/core/assets/images/salat_icons/fajr.png",
                            salatname: "sunrise".tr,
                            salattime: "Sunrise",
                          ),
                          Salwatpageview(
                            icon: "lib/core/assets/images/salat_icons/duhr.png",
                            salatname: "dhuhr".tr,
                            salattime: "Dhuhr",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Salwatpageview(
                            icon: "lib/core/assets/images/salat_icons/ASR.png",
                            salatname: "asr".tr,
                            salattime: "Asr",
                          ),
                          Salwatpageview(
                            icon:
                                "lib/core/assets/images/salat_icons/MAGHRIB.png",
                            salatname: "maghrib".tr,
                            salattime: "Maghrib",
                          ),
                          Salwatpageview(
                            icon: "lib/core/assets/images/salat_icons/ISHA.png",
                            salatname: "isha".tr,
                            salattime: "Isha",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
