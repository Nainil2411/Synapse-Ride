import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ChatController controller = Get.put(ChatController());
  late AnimationController _fabAnimationController;
  late AnimationController _messageAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<ImageProvider?> _getImageFromPrefs(String imageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString(imageKey);
    if (base64Image != null) {
      final bytes = base64Decode(base64Image);
      return MemoryImage(bytes);
    }
    return null;
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    HapticFeedback.lightImpact();
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();

    });
    controller.sendMessage();
    _messageAnimationController.forward().then((_) {
      _messageAnimationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F0F0F),
                      const Color(0xFF1A1A1A).withOpacity(0.8),
                    ],
                  ),
                ),
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(
                          milliseconds: 300 + (index * 50).clamp(0, 1000)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        final clampedValue = value.clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: 0.8 + (clampedValue * 0.2),
                          child: Opacity(
                            opacity: clampedValue,
                            child: _buildMessageBubble(message, index),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      foregroundColor: CustomColors.yellow1,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D).withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      leadingWidth: 30,
      title: Row(
        children: [
          Hero(
            tag: 'user_avatar',
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CustomColors.yellow1,
                    CustomColors.yellow1.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.yellow1.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.otherUserName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: CustomColors.yellow1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(() => _buildActionButton(
              Icons.videocam,
              controller.isVideoCallInProgress.value
                  ? () {}
                  : controller.startVideoCall,
              isDisabled: controller.isVideoCallInProgress.value,
            )),
        _buildActionButton(Icons.phone, controller.makePhoneCall),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed,
      {bool isDisabled = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDisabled
              ? [
                  Colors.grey.withOpacity(0.2),
                  Colors.grey.withOpacity(0.1),
                ]
              : [
                  CustomColors.yellow1.withOpacity(0.2),
                  CustomColors.yellow1.withOpacity(0.1),
                ],
        ),
      ),
      child: IconButton(
        icon:
            Icon(icon, color: isDisabled ? Colors.grey : CustomColors.yellow1),
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed();
              },
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              'Today',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Transform.scale(
            scale: 0.8 + (clampedValue * 0.2),
            child: Opacity(
              opacity: clampedValue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          CustomColors.yellow1.withOpacity(0.2),
                          CustomColors.yellow1.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 60,
                      color: CustomColors.yellow1.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No messages yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with ${controller.otherUserName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isMe = message['isMe'] as bool;
    final timestamp = message['timestamp'] as Timestamp?;
    final timeString =
        timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : '';
    final isImage = message['type'] == 'image';

    return Container(
      margin: EdgeInsets.only(
        bottom: 4,
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.75,
            minWidth: 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CustomColors.yellow1,
                      CustomColors.yellow1.withOpacity(0.9),
                      CustomColors.yellow1.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF323232),
                      const Color(0xFF383838),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  isMe ? const Radius.circular(18) : const Radius.circular(4),
              bottomRight:
                  isMe ? const Radius.circular(4) : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: (isMe ? CustomColors.yellow1 : Colors.black)
                    .withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: isMe
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 40, bottom: 14),
                child: isImage
                    ? FutureBuilder<ImageProvider?>(
                        future: _getImageFromPrefs(message['imageUrl']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                                height: 120,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else if (snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: snapshot.data!,
                                fit: BoxFit.cover,
                                width: 180,
                              ),
                            );
                          } else {
                            return const Text('Image not found',
                                style: TextStyle(color: Colors.redAccent));
                          }
                        },
                      )
                    : Text(
                        message['message'] ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isMe ? Colors.black87 : Colors.white,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
              if (timeString.isNotEmpty)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Text(
                        timeString,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: (isMe ? Colors.black : Colors.white)
                              .withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: controller.messageController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          onPressed: () {
                            controller.showImageSourceDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _onSendPressed(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          CustomColors.yellow1,
                          CustomColors.yellow1.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CustomColors.yellow1.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap:
                            controller.isLoading.value ? null : _onSendPressed,
                        child: Center(
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
