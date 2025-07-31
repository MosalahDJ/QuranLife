import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../fcm%20controllers/fcm_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagingController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FCMController fcmController = Get.find();
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void onInit() async {
    await _checkIfUserExists();
    super.onInit();
  }

  Future<bool> _checkIfUserExists() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        return false;
      }

      if (userDoc.data()?['isBanned'] == true) {
        await FirebaseAuth.instance.signOut();

        await Get.dialog(
          AlertDialog(
            title: Text('account_banned'.tr),
            content: Text('violation_rules'.tr),
            actions: [
              Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      // Replace with your support account URL
                      final Uri url = Uri.parse('https://t.me/0655663020');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Text(
                      'contact_support_if_error'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop(); // Close the app
                    },
                    child: Text('ok'.tr),
                  ),
                ],
              ),
            ],
          ),
          barrierDismissible: false, // User must use one of the buttons
        );

        return false;
      }

      await currentUser.reload();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await FirebaseAuth.instance.signOut();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Show a dialog using AwesomeDialog
  void _showDialog(
    BuildContext context,
    String title,
    String desc,
    DialogType type,
  ) {
    AwesomeDialog(
      context: context,
      title: title,
      desc: desc,
      dialogType: type,
    ).show();
  }

  // Stream للرسائل
  Stream<QuerySnapshot> get messagesStream =>
      FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();

  // إرسال رسالة
  Future<void> sendMessage(BuildContext context) async {
    if (messageController.text.trim().isEmpty) return;
    List<ConnectivityResult> conectivity =
        await Connectivity().checkConnectivity();
    if (conectivity.contains(ConnectivityResult.none)) {
      _showDialog(
        // ignore: use_build_context_synchronously
        context,
        'no_internet'.tr,
        'internet_required_for_sendmessage'.tr,
        DialogType.warning,
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': currentUser?.uid,
        'senderName': currentUser?.displayName,
        'senderEmail': currentUser?.email,
        'senderPhotoUrl': currentUser?.photoURL,
      });

      // إرسال إشعار FCM
      fcmController.sendmessage(
        'chat',
        currentUser?.displayName ?? 'user'.tr,
        messageController.text,
        'chat',
      );

      messageController.clear();
      scrollToBottom();
    } catch (e) {
      Get.snackbar('error'.tr, 'send_failed'.tr);
    }
  }

  // التمرير إلى أسفل القائمة
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // التحقق مما إذا كان المستخدم الحالي هو مرسل الرسالة
  bool isCurrentUserSender(String senderId) {
    return senderId == currentUser?.uid;
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
