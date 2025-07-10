import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_textstyle.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/video_call_controller.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoCallController controller = Get.put(VideoCallController());
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingScreen(controller);
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorScreen(controller);
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Obx(() => controller.isLocalVideoMain.value
                    ? _buildNonMirroredLocalVideo(controller)
                    : controller.buildRemoteVideo()),
              ),
              Obx(() => _buildDraggableVideoTile(controller)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(controller),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNonMirroredLocalVideo(VideoCallController controller) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.14159),
      child: controller.buildLocalPreview(),
    );
  }

  Widget _buildDraggableVideoTile(VideoCallController controller) {
    return Positioned(
      left: controller.tilePosition.value.dx,
      top: controller.tilePosition.value.dy,
      child: GestureDetector(
        onTap: () {
          controller.toggleMainVideo();
        },
        onPanUpdate: (details) {
          controller.updateTilePosition(
              controller.tilePosition.value + details.delta);
        },
        onPanEnd: (details) {
          _snapTileToEdge(controller);
        },
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CustomColors.yellow1,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: controller.isLocalVideoMain.value
                ? controller.buildRemoteVideo()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: controller.buildLocalPreview(),
                  ),
          ),
        ),
      ),
    );
  }

  void _snapTileToEdge(VideoCallController controller) {
    final screenSize = Get.size;
    final tileSize = const Size(120, 160);
    final currentPosition = controller.tilePosition.value;

    double newX = currentPosition.dx;
    double newY = currentPosition.dy;

    if (currentPosition.dx < screenSize.width / 2) {
      newX = 20;
    } else {
      newX = screenSize.width - tileSize.width - 20;
    }
    newY = newY.clamp(
      60.0,
      screenSize.height - tileSize.height - 120,
    );

    controller.updateTilePosition(Offset(newX, newY));
  }

  Widget _buildLoadingScreen(VideoCallController controller) {
    return Container(
      color: CustomColors.textPrimary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: CustomColors.yellow1,
              child: const Icon(
                Icons.person,
                size: 60,
                color: CustomColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text('Starting call with ${controller.otherUserName}...',
                style: AppTextStyles.bodyLargewhite),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.connectionState.value,
                  style: const TextStyle(color: Colors.grey),
                )),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: CustomColors.background,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                controller.endCall();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.error,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(
                Icons.call_end,
                color: CustomColors.background,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(VideoCallController controller) {
    return Container(
      color: CustomColors.textPrimary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: CustomColors.error,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Call Failed',
                style: TextStyle(
                  color: CustomColors.background,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      controller.errorMessage.value = '';
                      controller.isLoading.value = true;
                      controller.initializeAgora();
                    },
                    child: const Text('Try Again'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.error,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(VideoCallController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: CustomColors.yellow1,
            child: const Icon(
              Icons.person,
              color: CustomColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                    controller.isLocalVideoMain.value
                        ? 'You'
                        : (controller.remoteUid.value > 0
                            ? controller.otherUserName
                            : 'You'),
                    style: AppTextStyles.buttonTextLight)),
                Obx(() => Text(
                      controller.remoteUid.value > 0
                          ? 'Connected'
                          : controller.connectionState.value,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: controller.remoteUid.value > 0
                            ? CustomColors.green1
                            : Colors.orange,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(VideoCallController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() => _buildControlButton(
                  icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
                  isActive: !controller.isMuted.value,
                  onPressed: controller.toggleMute,
                )),
            Obx(() => _buildControlButton(
                  icon: controller.isCameraOff.value
                      ? Icons.videocam_off
                      : Icons.videocam,
                  isActive: !controller.isCameraOff.value,
                  onPressed: controller.toggleCamera,
                )),
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              isActive: true,
              onPressed: controller.switchCamera,
            ),
            Obx(() => _buildControlButton(
                  icon: controller.isSpeakerOn.value
                      ? Icons.volume_up
                      : Icons.volume_off,
                  isActive: controller.isSpeakerOn.value,
                  onPressed: controller.toggleSpeaker,
                )),
            _buildControlButton(
              icon: Icons.call_end,
              isActive: false,
              backgroundColor: CustomColors.error,
              onPressed: () {
                HapticFeedback.heavyImpact();
                controller.endCall();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor ??
            (isActive ? CustomColors.yellow1 : Colors.grey[800]),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icon,
              color: backgroundColor == CustomColors.error
                  ? CustomColors.background
                  : (isActive
                      ? CustomColors.textPrimary
                      : CustomColors.background),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
