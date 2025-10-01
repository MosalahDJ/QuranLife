import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/core/widgets/cusstom_dialogue_with_buttons.dart';
import 'package:project/features/controller/Auth%20controller/user_state_controller.dart';

class DeletAccount extends GetxController {
  final RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userstatectrl = Get.put<UserStateController>(
    UserStateController(),
    permanent: true,
  );

  // // Custom dialog function
  // Future<void> showCustomDialogWithActions({
  //   required BuildContext context,
  //   required String title,
  //   required String message,
  //   bool isError = false,
  //   bool isSuccess = false,
  //   VoidCallback? onConfirm,
  //   bool isDismissible = true,
  // }) {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: isDismissible,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           title,
  //           style: TextStyle(
  //             color:
  //                 isError
  //                     ? Colors.red
  //                     : isSuccess
  //                     ? Colors.green
  //                     : Theme.of(context).textTheme.titleLarge?.color,
  //           ),
  //         ),
  //         content: Text(message),
  //         actions: [
  //           if (onConfirm != null) ...[
  //             TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
  //             ElevatedButton(
  //               onPressed: onConfirm,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: isError ? Colors.red : Colors.blue,
  //               ),
  //               child: Text('confirm'.tr),
  //             ),
  //           ] else
  //             TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Update the deleteUserAccount method
  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        await showCustomDialogWithActions(
          context: context,
          title: 'no_internet'.tr,
          message: 'check_internet_connection'.tr,
          isError: true,
        );
        return;
      }

      // Get current user
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('no_user_logged_in'.tr);
      }

      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'delete_account'.tr,
              style: const TextStyle(color: Colors.red),
            ),
            content: Text('delete_account_confirmation'.tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('confirm'.tr),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) return;

      // Start loading state
      isLoading.value = true;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser.uid).delete();

      // Delete user from Authentication
      await currentUser.delete();
      await _userstatectrl.saveUserState(UserState.noUser);

      await showCustomDialogWithActions(
        context: context,
        title: 'success'.tr,
        message: 'account_deleted_successfully'.tr,
        isSuccess: true,
        isDismissible: false,
        onConfirm: () => Get.offAllNamed('login'),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage =
          e.code == 'ERROR_SESSION_EXPIRED'
              ? 'please_login_again_to_delete'.tr
              : e.message ?? 'unknown_error'.tr;

      await showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: errorMessage,
        isError: true,
      );
    } catch (e) {
      await showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: 'unknown_error'.tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> anonymousSignout(BuildContext context) async {
    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        await showCustomDialogWithActions(
          context: context,
          title: 'no_internet'.tr,
          message: 'check_internet_connection'.tr,
          isError: true,
        );
        return;
      }

      // Get current user
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('no_user_logged_in'.tr);
      }

      // Start loading state
      isLoading.value = true;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser.uid).delete();

      // Delete user from Authentication
      await currentUser.delete();
      await _userstatectrl.saveUserState(UserState.noUser);

      Get.offAllNamed('login');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'ERROR_SESSION_EXPIRED':
          errorMessage = 'please_login_again_to_delete'.tr;
          break;
        default:
          errorMessage = e.message ?? 'unknown_error'.tr;
      }

      await showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: errorMessage,
        isError: true,
      );
    } catch (e) {
      await showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: 'unknown_error'.tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // User logout function
  Future<void> signOut(BuildContext context) async {
    List<ConnectivityResult> conectivity =
        await Connectivity().checkConnectivity();
    if (conectivity.contains(ConnectivityResult.none)) {
      await showCustomDialogWithActions(
        context: context,
        title: 'no_internet'.tr,
        message: 'internet_required_for_signout'.tr,
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (currentUser.isAnonymous) {
          await _firestore.collection('users').doc(currentUser.uid).delete();
          await currentUser.delete();
        } else {
          if (await GoogleSignIn().isSignedIn()) {
            await GoogleSignIn().signOut();
          }
        }
        await FirebaseAuth.instance.signOut();
        await _userstatectrl.saveUserState(UserState.noUser);
      }
      Get.offAllNamed("login");
    } on FirebaseAuthException catch (e) {
      await showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: e.message ?? 'unknown_error'.tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
