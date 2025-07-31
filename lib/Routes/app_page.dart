import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';
import 'package:synapseride/screens/Home/Drawer/Joined_ride.dart';
import 'package:synapseride/screens/Home/Drawer/complain/complain.dart';
import 'package:synapseride/screens/Home/Drawer/contactUs/contact_us_screen.dart';
import 'package:synapseride/screens/Home/Drawer/modernInfoHub.dart';
import 'package:synapseride/screens/Home/Drawer/profile/profile.dart';
import 'package:synapseride/screens/Home/custom_drawer.dart';
import 'package:synapseride/screens/Home/homescreen.dart';
import 'package:synapseride/screens/Home/notification_screen.dart';
import 'package:synapseride/screens/Ride/accpet_ride.dart';
import 'package:synapseride/screens/Ride/create_ride_screen.dart';
import 'package:synapseride/screens/Ride/edit_ride.dart';
import 'package:synapseride/screens/Ride/joining_ride_screen.dart';
import 'package:synapseride/screens/Ride/location_picker.dart';
import 'package:synapseride/screens/Ride/myride_request.dart';
import 'package:synapseride/screens/Ride/request_ride.dart';
import 'package:synapseride/screens/Ride/request_ride_hub.dart';
import 'package:synapseride/screens/Ride/ride_history.dart';
import 'package:synapseride/screens/Ride/view_ride_request.dart';
import 'package:synapseride/screens/subscreen/chat_screen.dart';
import 'package:synapseride/screens/subscreen/forget_password.dart';
import 'package:synapseride/screens/subscreen/login_screen.dart';
import 'package:synapseride/screens/subscreen/page_screen.dart';
import 'package:synapseride/screens/subscreen/signup_screen.dart';
import 'package:synapseride/screens/subscreen/splash_screen.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.createRide, page: () => CreateRideScreen()),
    GetPage(name: AppRoutes.locationPicker, page: () => LocationPickerScreen()),
    GetPage(name: AppRoutes.editRide, page: () => EditRideScreen()),
    GetPage(name: AppRoutes.joiningRide, page: () => JoiningRideScreen()),
    GetPage(name: AppRoutes.rideHistory, page: () => RideHistoryScreen()),
    GetPage(name: AppRoutes.home, page: () => MapScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.page, page: () => PageScreen()),
    GetPage(name: AppRoutes.complain, page: () => ComplainScreen()),
    GetPage(name: AppRoutes.contactus, page: () => ContactUsScreen()),
    GetPage(name: AppRoutes.customDrawer, page: () => CustomDrawer()),
    GetPage(name: AppRoutes.modernInfoHub, page: () => ModernInfoHubScreen()),
    GetPage(name: AppRoutes.joinedRide, page: () => JoinedRideScreen()),
    GetPage(
        name: AppRoutes.notificationScreen, page: () => NotificationScreen()),
    GetPage(name: AppRoutes.forgetpassword, page: () => ForgotPasswordScreen()),
    GetPage(name: AppRoutes.chat, page: () => ChatScreen()),
    GetPage(
      name: AppRoutes.rideRequestHub,
      page: () => RideRequestHubScreen(),
    ),
    GetPage(
      name: AppRoutes.requestRide,
      page: () => RequestRideScreen(),
    ),
    GetPage(
      name: AppRoutes.viewRideRequests,
      page: () => ViewRideRequestsScreen(),
    ),
    GetPage(
      name: AppRoutes.myRideRequests,
      page: () => MyRideRequestsScreen(),
    ),
    GetPage(
      name: AppRoutes.acceptedRides,
      page: () => AcceptedRidesScreen(),
    ),
  ];
}
