import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/utils/agora_config.dart';

class VideoCallController extends GetxController {
  RtcEngine? agoraEngine;
  var isJoined = false.obs;
  var isMuted = false.obs;
  var isCameraOff = false.obs;
  var isSpeakerOn = true.obs;
  var remoteUid = 0.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var connectionState = 'Connecting...'.obs;
  RxBool isLocalVideoMain = false.obs;
  Rx<Offset> tilePosition = const Offset(20, 60).obs;
  String otherUserName = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    otherUserName = args['otherUserName'] ?? 'User';
    initializeTilePosition();
    initializeAgora();
  }

  void toggleMainVideo() {
    isLocalVideoMain.value = !isLocalVideoMain.value;
    HapticFeedback.selectionClick();
  }

  void updateTilePosition(Offset newPosition) {
    tilePosition.value = newPosition;
  }

  void initializeTilePosition() {
    final screenSize = Get.size;
    tilePosition.value = Offset(
      screenSize.width - 140,
      60,
    );
  }

  Future<void> initializeAgora() async {
    try {
      connectionState.value = 'Requesting permissions...';

      bool permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        throw Exception('Camera and microphone permissions required');
      }

      connectionState.value = 'Initializing video call...';

      agoraEngine = createAgoraRtcEngine();

      await agoraEngine!.initialize(RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      agoraEngine!
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);

      _registerEventHandlers();

      await agoraEngine!.enableVideo();
      await agoraEngine!.enableAudio();

      await agoraEngine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 0,
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );

      connectionState.value = 'Starting camera...';
      await agoraEngine!.startPreview();

      connectionState.value = 'Joining call...';
      await _joinChannel();
    } catch (e) {
      log("Error initializing Agora: $e");
      errorMessage.value = 'Failed to start video call';
      isLoading.value = false;

      Get.snackbar(
        'Video Call Error',
        'Unable to start video call. Please try again.',
        backgroundColor: CustomColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _registerEventHandlers() {
    agoraEngine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log("Successfully joined channel with UID: ${connection.localUid}");
        isJoined.value = true;
        isLoading.value = false;
        connectionState.value = 'Connected';
      },
      onUserJoined: (RtcConnection connection, int uid, int elapsed) {
        log("Remote user joined: $uid");
        remoteUid.value = uid;
        connectionState.value = 'Call connected';
      },
      onUserOffline:
          (RtcConnection connection, int uid, UserOfflineReasonType reason) {
        log("Remote user left: $uid");
        if (uid == remoteUid.value) {
          remoteUid.value = 0;
          connectionState.value = 'User disconnected';
        }
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        log("Left channel");
        isJoined.value = false;
        remoteUid.value = 0;
      },
      onError: (ErrorCodeType err, String msg) {
        log("Agora error: $err - $msg");
        errorMessage.value = 'Connection error occurred';
        isLoading.value = false;
      },
      onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state, ConnectionChangedReasonType reason) {
        switch (state) {
          case ConnectionStateType.connectionStateConnecting:
            connectionState.value = 'Connecting...';
            break;
          case ConnectionStateType.connectionStateConnected:
            connectionState.value = 'Connected';
            break;
          case ConnectionStateType.connectionStateReconnecting:
            connectionState.value = 'Reconnecting...';
            break;
          case ConnectionStateType.connectionStateDisconnected:
            connectionState.value = 'Disconnected';
            break;
          case ConnectionStateType.connectionStateFailed:
            connectionState.value = 'Connection failed';
            errorMessage.value = 'Unable to connect';
            isLoading.value = false;
            break;
        }
      },
    ));
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cameraGranted =
        permissions[Permission.camera] == PermissionStatus.granted;
    bool micGranted =
        permissions[Permission.microphone] == PermissionStatus.granted;

    if (!cameraGranted || !micGranted) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'Please allow camera and microphone access to make video calls.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _joinChannel() async {
    await agoraEngine!.joinChannel(
      token: AgoraConfig.token,
      channelId: AgoraConfig.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> toggleMute() async {
    if (agoraEngine != null) {
      isMuted.value = !isMuted.value;
      await agoraEngine!.muteLocalAudioStream(isMuted.value);
    }
  }

  Future<void> toggleCamera() async {
    if (agoraEngine != null) {
      isCameraOff.value = !isCameraOff.value;
      await agoraEngine!.muteLocalVideoStream(isCameraOff.value);
    }
  }

  Future<void> switchCamera() async {
    if (agoraEngine != null) {
      await agoraEngine!.switchCamera();
    }
  }

  Future<void> toggleSpeaker() async {
    if (agoraEngine != null) {
      isSpeakerOn.value = !isSpeakerOn.value;
      await agoraEngine!.setEnableSpeakerphone(isSpeakerOn.value);
    }
  }

  Future<void> endCall() async {
    if (agoraEngine != null && isJoined.value) {
      await agoraEngine!.leaveChannel();
      await agoraEngine!.release();
    }
  }

  Widget buildLocalPreview() {
    if (agoraEngine == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white, size: 40),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget buildRemoteVideo() {
    if (agoraEngine == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 80),
        ),
      );
    }

    if (remoteUid.value == 0) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: CustomColors.yellow1,
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Calling $otherUserName...',
                style: const TextStyle(
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

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: agoraEngine!,
        canvas: VideoCanvas(uid: remoteUid.value),
        connection: RtcConnection(channelId: AgoraConfig.channelName),
      ),
    );
  }

  @override
  void onClose() {
    if (agoraEngine != null) {
      agoraEngine!.leaveChannel();
      agoraEngine!.release();
    }
    super.onClose();
  }
}
