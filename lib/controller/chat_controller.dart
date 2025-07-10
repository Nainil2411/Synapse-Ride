import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/screens/subscreen/video_call.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker imagePicker = ImagePicker();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  var isLoading = false.obs;
  var isUploadingImage = false.obs;
  var isVideoCallInProgress = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  String rideId = '';
  String rideOwnerId = '';
  String passengerId = '';
  String otherUserId = '';
  String otherUserName = '';
  String otherUserPhone = '';
  String currentUserId = '';
  bool isRideOwner = false;

  @override
  void onInit() {
    super.onInit();
    currentUserId = auth.currentUser?.uid ?? '';

    final args = Get.arguments as Map<String, dynamic>;
    rideId = args['rideId'] ?? '';
    rideOwnerId = args['rideOwnerId'] ?? '';
    otherUserId = args['otherUserId'] ?? '';
    otherUserName = args['otherUserName'] ?? '';
    otherUserPhone = args['otherUserPhone'] ?? '';
    isRideOwner = args['isRideOwner'] ?? false;

    if (isRideOwner) {
      passengerId = otherUserId;
    } else {
      passengerId = currentUserId;
    }
    if (rideId.isNotEmpty && rideOwnerId.isNotEmpty && passengerId.isNotEmpty) {
      listenToMessages();
    }
  }

  void listenToMessages() {
    firestore
        .collection('chats')
        .doc(getChatId())
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'message': data['message'] ?? '',
          'senderId': data['senderId'] ?? '',
          'senderName': data['senderName'] ?? '',
          'timestamp': data['timestamp'],
          'isMe': data['senderId'] == currentUserId,
          'type': data['type'] ?? 'text',
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  String getChatId() {
    return '${rideOwnerId}_${passengerId}_$rideId';
  }

  Future<void> startVideoCall() async {
    if (isVideoCallInProgress.value) {
      return;
    }

    try {
      isVideoCallInProgress.value = true;
      await _sendMessageToFirestore('📹 Video call started', 'video_call');
      await Get.to(
            () => const VideoCallScreen(),
        arguments: {
          'otherUserName': otherUserName,
        },
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
      isVideoCallInProgress.value = false;
    } catch (e) {
      isVideoCallInProgress.value = false;

      Get.snackbar(
        'Error',
        'Failed to start video call: $e',
        backgroundColor: CustomColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    isLoading.value = true;
    messageController.clear();

    try {
      await _sendMessageToFirestore(message, 'text');
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to send message: $e',
        backgroundColor: CustomColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendMessageToFirestore(String content, String type, {String? imageUrl}) async {
    final chatId = getChatId();
    final currentUserData = await firestore
        .collection('users')
        .doc(currentUserId)
        .get();

    final userData = currentUserData.data() ?? {};
    final senderName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    String otherUserNameForChat = otherUserName;
    if (otherUserNameForChat.isEmpty) {
      final otherUserData = await firestore
          .collection('users')
          .doc(otherUserId)
          .get();
      final otherData = otherUserData.data() ?? {};
      otherUserNameForChat = '${otherData['firstName'] ?? ''} ${otherData['lastName'] ?? ''}'.trim();
    }

    String lastMessage = type == 'image' ? '📷 Photo' :
    type == 'video_call' ? '📹 Video call' : content;
    await firestore.collection('chats').doc(chatId).set({
      'rideId': rideId,
      'rideOwnerId': rideOwnerId,
      'passengerId': passengerId,
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [rideOwnerId, passengerId],
      'rideOwnerName': isRideOwner ? senderName : otherUserNameForChat,
      'passengerName': isRideOwner ? otherUserNameForChat : senderName,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final messageData = {
      'message': content,
      'senderId': currentUserId,
      'senderName': senderName.isNotEmpty ? senderName : 'Unknown User',
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
    };

    if (type == 'image' && imageUrl != null) {
      messageData['imageUrl'] = imageUrl;
    }

    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CustomColors.yellow1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomColors.yellow1.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: CustomColors.yellow1,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        isUploadingImage.value = true;
        await uploadAndSendImage(File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to pick image: $e',
        backgroundColor: CustomColors.error,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> uploadAndSendImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      final imageKey = 'chat_image_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(imageKey, base64Image);
    } catch (e) {
      log("Error: $e");
    }
  }

  Future<void> makePhoneCall() async {
    if (otherUserPhone.isEmpty) {
      Get.snackbar(
        AppStrings.error,
        'Phone number not available',
        backgroundColor: CustomColors.error,
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: otherUserPhone,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to make phone call',
        backgroundColor: CustomColors.error,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}