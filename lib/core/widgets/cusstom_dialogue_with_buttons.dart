
  // Custom dialog function
  import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              TextButton(onPressed: () => Get.back(), child: Text(btnCancelText?.tr ?? 'cancel'.tr)),
              ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError ? Colors.red : Colors.blue,
                ),
                child: Text('confirm'.tr),
              ),
            ] else
              TextButton(onPressed: () => Get.back(), child: Text(btnConfirmText?.tr ?? 'ok'.tr)),
          ],
        );
      },
    );
  }