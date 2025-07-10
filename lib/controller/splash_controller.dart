import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapseride/Routes/routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Future.delayed(Duration(seconds: 3), () {
      checkLoginStatus();
    });
    super.onInit();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed('/page');
    }
  }
}
