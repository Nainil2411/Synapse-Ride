class AppStrings {
  // App Name
  static const String appName = 'SynapseRide';

  // Common Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
  static const String change = 'Change';
  static const String generate = 'Generate';
  static const String call = 'Call';
  static const String success = 'Success!';
  static const String remove = 'Remove';
  static const String or = 'OR';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String submit = 'Submit';
  static const String welcome = 'Welcome!';

  // Authentication
  static const String login = 'Log In';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithFacebook = 'Continue with Facebook';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String sendResetLink = 'Send Reset Link';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String mobileNo = 'Mobile No';
  static const String enterDOB = 'Enter D.O.B';
  static const String selectGender = 'Select Gender';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String other = 'Other';
  static const String createAccount = 'Create an account to continue!';
  static const String signInToAccount = 'Sign in to your\nAccount';
  static const String enterEmailPassword =
      'Enter your email and password to log in';
  static const String enterPassword = 'Enter your password';
  static const String entervalidemail = 'Enter valid Email';
  static const String entervalidphone = 'Enter valid Phone Number';
  static const String enteremail = 'Enter your Email';
  static const String emailassosiated = 'Please enter your associated email';
  static const String passwordRequirements =
      'Password must contain: At least 6 characters \n Uppercase letter \n Lowercase letter';
  static const String successfulPasswordReset = 'Password reset successful';
  static const String linksent = 'Password reset link sent to your email';
  static const String wrongPassword = 'Wrong password provided.';

  // Navigation
  static const String back = 'Back';
  static const String next = 'Next';

  // Create Ride Screen
  static const String createRide = 'Create Ride';
  static const String userDetails = 'User Details';
  static const String rideDetails = 'Ride Details';
  static const String vehicleDetails = 'Vehicle Details';
  static const String name = 'Name';
  static const String address = 'Address';
  static const String phoneNumber = 'Phone Number';
  static const String leavingTime = 'Leaving Time';
  static const String selectSeats = 'Available Seats';
  static const String car = 'Car';
  static const String bike = 'Bike';
  static const String selectAddress = 'Please select an address';
  static const String selectSeatsError = 'Please select the number of seats';
  static const String rideCreated = 'Your ride has been created';
  static const String closingIn = 'Closing in';

  // Joining Ride Screen
  static const String availableRides = 'Available Rides';
  static const String noRidesAvailable = 'No rides available';
  static const String checkBackLater =
      'Check back later or create your own ride';
  static const String joinRide = 'Join Ride';
  static const String rideJoined = 'You have successfully joined the ride!';
  static const String noSeatsAvailable = 'No seats available';
  static const String rideJoinConfirmation = 'Are you sure you want to join';
  static const String dropOff = 'Drop-off';
  static const String availableSeats = 'Available seats';
  static const String dropOffAddress = 'Drop-off Address';
  static const String noAddressProvided = 'No address provided';
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String seats = 'seats';

  // Edit Ride Screen
  static const String editRide = 'Edit Ride';
  static const String rideUpdated = 'Ride updated successfully';
  static const String enterAddress = 'Please enter an address';
  static const String failedToUpdate = 'Failed to update ride';

  // Map Screen
  static const String joiningRide = 'Joining Ride';
  static const String rideInProgress = 'Ride Already in Progress';
  static const String cannotJoinRide = 'Cannot Join Ride';
  static const String alreadyHasRideMessage =
      'You already have an active ride. Delete it to create a new one.';
  static const String alreadyJoinedRideMessage =
      'You already have joined someone else\'s ride.';
  static const String deleteRide = 'Delete Ride';
  static const String viewJoinedRide = 'View Joined Ride';
  static const String alreadyJoinedRide = 'Already Joined a Ride';
  static const String alreadyJoinedRideDescription =
      'You have already joined someone else\'s ride.';

  // Ride History Screen
  static const String rideHistory = 'Ride History';
  static const String noRideHistory = 'No ride history found';
  static const String loginRequired =
      'You need to be logged in to view ride history';
  static const String joinedPassengers = 'Joined Passengers:';
  static const String joinedmessage = 'No joined ride yet';
  static const String noPassengersJoined = 'No passengers joined yet.';
  static const String removePassenger = 'Remove Passenger';
  static const String confirmRemovePassenger =
      'Are you sure you want to remove';
  static const String passengerRemoved = 'Passenger removed successfully';
  static const String errorRemovingPassenger = 'Error removing passenger:';
  static const String confirmDeleteRide =
      'Are you sure you want to delete this ride? This action cannot be undone.';
  static const String confirmDeleteuser =
      'Are you sure you want to delete this User? This action cannot be undone.';
  static const String rideDeleted = 'Ride deleted successfully';
  static const String errorDeletingRide = 'Error deleting ride:';

  // Location Picker Screen
  static const String pickLocation = 'Pick Location';
  static const String selectedLocation = 'Selected Location';
  static const String confirmLocation = 'Confirm Location';
  static const String fetchingAddress = 'Fetching address...';
  static const String unableToFetchAddress = 'Unable to fetch address';
  static const String locationPermissionDenied =
      'Location permissions are denied';
  static const String locationPermissionPermanentlyDenied =
      'Location permissions are permanently denied';
  static const String errorGettingLocation = 'Error getting location:';

  // Error Messages
  static const String errorLoadingRides = 'Failed to load rides';
  static const String errorJoiningRide =
      'Failed to join the ride. Please try again.';
  static const String errorSavingRide = 'Failed to save ride details';
  static const String errorLoadingUserData = 'Failed to load user data';
  static const String errorGettingRoute = 'Failed to get route';
  static const String errorProcessingRoute = 'Error processing route data';
  static const String error = 'Error: ';

  // Success Messages
  static const String rideJoinedSuccessfully = 'Ride joined successfully';
  static const String rideCreatedSuccessfully = 'Ride created successfully';
  static const String rideUpdatedSuccessfully = 'Ride updated successfully';
  static const String rideDeletedSuccessfully = 'Ride deleted successfully';

  static const String enterfirstname = 'Enter your first name';
  static const String enterlastname = 'Enter your last name';
  static const String enterphoneno = 'Enter your phone number';
  static const String enterdob = 'Enter your date of birth';
  static const String selectgender = 'Select your gender';
  static const String enteraddress = 'Enter your address';
  static const String addnewaddress = 'Add New Address';
  static const String addressdetails = 'Address Details';
  static const String nameofaddress = 'Name of Address';
  static const String aboutus = 'About Us';
  static const String privacy = 'Privacy Policy';
  static const String helpandsupport = 'Help & Support';
  static const String contactus = 'Contact Us';
  static const String complain = 'Complain';
  static const String logout = 'Logout';
  static const String deleteaccount = 'Delete Account';
  static const String editprofile = 'Edit Profile';
  static const String profile = 'Profile';
  static const String editaddress = 'Edit Address';
  static const String deleteaddress = 'Delete Address';
  static const String addressdeleted = 'Address deleted successfully';
  static const String messagesent = 'Message sent successfully';
  static const String viewall = 'View All';
  static const String upcomingride = 'Upcoming Ride';
  static const String logoutmessage = 'Are you sure you want to logout?';
  static const String nocomplain = 'No complaint history';
  static const String writecomplain =
      'Write your complaint here (minimum 10 characters)';
  static const String complainsubmitted = 'Complaint submitted successfully';
  static const String complainfailed = 'Failed to submit complaint';
  static const String complainempty = 'Complaint cannot be empty';
  static const String complaintooshort =
      'Complaint must be at least 10 characters long';
  static const String referral = 'Referral';

  static const String aboutustext =
      "Welcome to our Carpooling System — a smart initiative designed for effective transportation. Our goal is to foster a more sustainable and community-driven mode of transportation by making carpooling accessible and efficient. We're focused on reducing traffic congestion, lowering carbon footprints, and building connections among people. Whether you're a regular commuter or an occasional traveler, this platform provides a reliable and secure way to share rides, save money, and contribute to a greener environment. Join us in transforming the way we travel — one ride at a time.";
  static const String privacyPolicyTitle = 'Privacy Policy for SynapseRide';
  static const String privacyPolicyText =
      'At SynapseRide, your privacy is one of our top priorities. This Privacy Policy outlines the types of personal information we collect, how it is used, and the measures we take to protect it. By using SynapseRide, you agree to the practices described in this policy.\n\n'
      'We collect limited user data including name,phone number, email, contact information, and location data, solely to provide and improve our carpooling services. None of your data is shared with third parties without your consent, unless required by law.\n\n'
      'All personal data is stored securely and only accessible by authorized personnel. You may request to view or delete your data at any time.\n\n'
      'This Privacy Policy applies exclusively to SynapseRides mobile application and services. It does not cover any third-party services or external websites that may be linked within the app.\n\n'
      'If you have any questions or concerns about our Privacy Policy, please dont hesitate to contact our support team through the app or email.\n\n'
      'By using SynapseRide, you consent to our Privacy Policy and agree to its terms.';
  static const notificationsTitle = 'Notifications';
  static const markAllAsRead = 'Mark all as read';
  static const noNotifications = 'No notifications';
  static const notificationDismissed = 'Notification dismissed';

  // Sample notification titles and messages (optional if dynamic)
  static const updateAvailableTitle = 'New Update Available';
  static const updateAvailableMessage =
      'A new version of the app is available for download.';

  static const routeSavedTitle = 'Route Saved';
  static const routeSavedMessage =
      'Your recent route to Ahmedabad has been saved.';

  static const trafficAlertTitle = 'Traffic Alert';
  static const trafficAlertMessage =
      'Heavy traffic reported on your saved route.';

  static const locationSharedTitle = 'Location Shared';
  static const locationSharedMessage =
      'Your location has been shared with a contact.';

  static const welcomeTitle = 'Welcome!';
  static const welcomeMessage =
      'Thank you for installing our navigation application.';

  static const String joinedRide = 'Joined Ride';
  static const String failedToLoadJoinedRide = 'Failed to load joined ride.';
  static const String failedToLeaveRide = 'Failed to leave the ride.';
  static const String youLeftTheRide = 'You have left the ride.';
  static const String rideInfoNotAvailable = 'Ride information not available.';
  static const String couldNotLaunchDialer = 'Could not launch dialer';
  static const String noJoinedRides = 'No joined rides';
  static const String noJoinedRidesDescription =
      'You have not joined any rides yet.';
  static const String unknown = 'Unknown';
  static const String notSpecified = 'Not specified';
  static const String notAvailable = 'Not available';
  static const String rideWith = 'Ride with';
  static const String dropOffLocation = 'Drop-off Location';
  static const String joinedOn = 'Joined On';
  static const String vehicleType = 'Vehicle Type';
  static const String callDriver = 'Call Driver';
  static const String leaveRide = 'Leave Ride';
  static const String leaveRideConfirm =
      'Are you sure you want to leave this ride?';
  static const String seatWillBeAvailable =
      'The seat will become available to others.';
  static const String yesLeaveRide = 'Yes, Leave Ride';
  static const String phoneNumberNotAvailable = 'Phone number not available.';
  static const String phoneNumberrequire = 'Please enter your phone no';

  static const messageSentSuccessfully = 'Your message has been sent successfully.';
  static const complaintDeletedSuccessfully = 'Complaint deleted successfully';
  static const errorDeletingComplaint = 'Error deleting complaint';
  static const contactUsForSynapseRide = 'Contact us for SynapseRide';
  static const universityAddress = 'Indus University Near: Rancharda, Via: Shilaj, Ahmedabad - 382115 Gujarat - India';
  static const callNumber = 'Call : 90999 44444';
  static const supportEmail = 'Email : support@synapseride.com';
  static const sendMessage = 'Send Message';
  static const enterYourName = 'Enter your name';
  static const enterYourNameError = 'Please enter your name';
  static const enterYourEmail = 'Enter your email';
  static const enterValidEmailError = 'Please enter a valid email';
  static const message = 'Message';
  static const enterYourIssueHere = 'Enter your issue here';
  static const enterYourMessageError = 'Please enter your message';
  static const yourPreviousComplaints = 'Your Previous Complaints';
  static const noComplaintsFound = 'No complaints found';
  static const dateNotAvailable = 'Date not available';
  static const noMessage = 'No message';
  static const from = 'From';
  static const phone = 'Phone';
  static const requestride =  'Request Ride';
}
