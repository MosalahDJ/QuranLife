// Custom dialog function
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/Utils/constants.dart';
import 'package:project/features/controller/settings%20controllers/theme_controller.dart';

Future<void> showCustomDialogWithActions({
  required BuildContext context,
  required String title,
  required Widget body,
  bool isError = false,
  bool isSuccess = false,
  VoidCallback? onConfirm,
  bool isDismissible = true,
  String? btnCancelText,
  String? btnConfirmText,
}) {
  final ThemeController themeCtrl = Get.find();

  return showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color:
                isError
                    ? Colors.red
                    : isSuccess
                    ? Colors.green
                    : Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: body,
        actions: [
          if (onConfirm != null) ...[
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                btnCancelText?.tr ?? 'cancel'.tr,
                style: TextStyle(
                  color: themeCtrl.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    themeCtrl.isDarkMode ? kmaincolor4 : kmaincolor,
              ),
              child: Text('confirm'.tr, style: TextStyle(color: Colors.white)),
            ),
          ] else
            TextButton(
              onPressed: () => Get.back(),
              child: Text(btnConfirmText?.tr ?? 'ok'.tr),
            ),
        ],
      );
    },
  );
}
