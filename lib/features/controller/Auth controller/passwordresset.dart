import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/widgets/cusstom_dialogue.dart';
import '../../../core/Utils/constants.dart';
import '../Auth%20controller/logincontroller.dart';

class PasswordresetController extends GetxController {
  final LogInController loginctrl = Get.find();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> resetpassword(BuildContext context, String emailtext) async {
    try {
      if (currentUser != null && currentUser!.isAnonymous) {
        await showCustomDialog(
          context: context,
          title: 'anonymous_user'.tr,
          message: 'guest_login_warning'.tr,
          isError: true,
        );
        return;
      }

      if (emailtext.isEmpty) {
        GetSnackBar(
          duration: const Duration(seconds: 10),
          backgroundColor: kmaincolor,
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.FLOATING,
          borderRadius: 20,
          barBlur: 10,
          titleText: Text(
            'invalid_email_title'.tr,
            style: const TextStyle(fontSize: 20, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          messageText: Text(
            'enter_email_first'.tr,
            style: const TextStyle(fontSize: 15, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ).show();
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailtext);
        await showCustomDialog(
          context: context,
          title: 'password_reset'.tr,
          message: "${'reset_link_sent'.tr} $emailtext",
          isSuccess: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      await showCustomDialog(
        context: context,
        title: 'error'.tr,
        message: e.message ?? 'unknown_error'.tr,
        isError: true,
      );
    }
  }
}
