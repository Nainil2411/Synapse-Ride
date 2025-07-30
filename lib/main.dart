import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/app_page.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/common/custom_color.dart';
import 'package:synapseride/controller/profile_controller.dart';
import 'package:synapseride/firebase_options.dart';
import 'package:synapseride/utils/firebase.dart';
import 'package:synapseride/utils/notifications.dart';
import 'package:synapseride/utils/utility.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(FirebaseAuthService());
  Get.put(ProfileController());
  ConnectivityService().initialize();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<bool> isOffline = ConnectivityService().isOffline;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    isOffline.addListener(_handleOfflineState);
    NotificationService().subscribeToTopic('general');
  }

  void _handleOfflineState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isCurrentlyOffline = isOffline.value;

      if (isCurrentlyOffline) {
        _showNoInternetDialog();
      } else {
        _dismissDialogIfAny();
      }
    });
  }

  void _showNoInternetDialog() {
    if (!_dialogShown && navigatorKey.currentContext != null) {
      _dialogShown = true;
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.signal_wifi_off,
              color: Colors.red,
              size: 50,
            ),
            title: const Text('No Internet'),
            content: const Text('Please check your internet connection.'),
          );
        },
      );
    }
  }

  void _dismissDialogIfAny() {
    if (_dialogShown && navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
          .maybePop();
      _dialogShown = false;
    }
  }

  @override
  void dispose() {
    isOffline.removeListener(_handleOfflineState);
    NotificationService().dispose();
    ConnectivityService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Synapse Ride',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: (context, child) {
        return GestureDetector(
          child: child,
          onTap: () => UIUtils.keyboardDismiss(context),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CustomColors.textPrimary,
      ),
    );
  }
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isOffline = ValueNotifier(false);
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    _checkInitialConnection();
  }

  void dispose() {
    _subscription.cancel();
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection =
        results.any((result) => result != ConnectivityResult.none);
    isOffline.value = !hasConnection;
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }
}
