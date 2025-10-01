// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/core/widgets/cusstom_dialogue_with_buttons.dart';
import 'package:project/features/controller/Auth%20controller/user_state_controller.dart';

class LogInController extends GetxController {
  // Controllers for user input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State management
  final RxBool isLoading = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStateController _userStateCtrl = Get.put<UserStateController>(
    UserStateController(),
    permanent: true,
  );

  // Focus nodes for form fields
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Toggles password visibility
  bool isPasswordVisible = true;
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  // Unfocus keyboard
  void unfocusKeyboard() {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
  }

  // User login function
  Future<void> login(BuildContext context) async {
    try {
      isLoading.value = true;

      // Authenticate user with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      final User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        await _userStateCtrl.saveUserState(UserState.emailSignInUser);
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        emailController.clear();
        passwordController.clear();
        Get.offAllNamed("home");
      } else {
        await showCustomDialogWithActions(
          context: context,
          title: 'verify_email_title'.tr,
          message: 'verify_email_desc'.tr,
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
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
        await _userStateCtrl.saveUserState(UserState.noUser);
      }
      Get.offAllNamed("login");
    } on FirebaseAuthException catch (e) {
      showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: e.message ?? 'unknown_error'.tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required bool isMale,
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      await showCustomDialogWithActions(
        context: context,
        title: 'error'.tr,
        message: 'all_fields_required'.tr,
        isError: true,
      );
      return;
    }
    List<ConnectivityResult> conectivity =
        await Connectivity().checkConnectivity();
    if (conectivity.contains(ConnectivityResult.none)) {
      await showCustomDialogWithActions(
        context: context,
        title: 'no_internet'.tr,
        message: 'check_internet_connection'.tr,
        isError: true,
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      await showCustomDialogWithActions(
        context: context,
        title: 'anonymous_user'.tr,
        message: 'guest_login_warning'.tr,
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(currentUser.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'email': currentUser.email,
        'gender': isMale ? 'male' : 'female',
        'updatedAt': FieldValue.serverTimestamp(),
        'displayName': '$firstName $lastName',
      });
      await showCustomDialogWithActions(
        context: context,
        title: 'success'.tr,
        message: 'profile_updated_successfully'.tr,
        isSuccess: true,
      );
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

  // Handle FirebaseAuth exceptions
  void _handleAuthError(BuildContext context, FirebaseAuthException e) {
    String errorMessage =
        e.code == 'invalid-credential'
            ? 'wrong_credentials'.tr
            : e.message ?? 'unknown_error'.tr;
    showCustomDialogWithActions(
      context: context,
      title: 'error'.tr,
      message: errorMessage,
      isError: true,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
