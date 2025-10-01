// Add custom dialog function
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  bool isError = false,
  bool isSuccess = false,
  bool isDismissible = true,
}) {
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
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
        ],
      );
    },
  );
}
