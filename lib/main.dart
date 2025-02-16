import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reswipe/backend/company_backend.dart';
import 'package:reswipe/backend/user_backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reswipe/home_screen/screens/company_home_screen.dart';
import 'auth/auth_wrapper.dart';
import 'auth/login_screen.dart';
import 'auth/splash_screen.dart';
import 'firebase_options.dart';
import 'home_screen/screens/job_seeker_home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Optional: Configure foreground message handling
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  final prefs = await SharedPreferences.getInstance();
  runApp(JobFinderApp(prefs: prefs));
}

class JobFinderApp extends StatefulWidget {
  final SharedPreferences prefs;

  const JobFinderApp({
    super.key,
    required this.prefs,
  });

  @override
  State<JobFinderApp> createState() => _JobFinderAppState();
}

class _JobFinderAppState extends State<JobFinderApp> {
  late UserBackend _userBackend;

  @override
  void initState() {
    super.initState();
    _userBackend = UserBackend();

    // Call update token on startup
    _updateFCMTokenOnInitialize();

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      _updateFCMTokenOnInitialize();
    });
  }

  Future<void> _updateFCMTokenOnInitialize() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _userBackend.initialize(currentUser.uid);
      await _userBackend.updateFCMToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<JobBloc>(
              create: (context) => JobBloc(prefs: widget.prefs),
              lazy: false,
            ),
            BlocProvider<LogoutBloc>(
              create: (context) => LogoutBloc(prefs: widget.prefs),
            ),
            BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(
                userBackend: UserBackend(),
              )..add(LoadProfile()),
              lazy: false,
            ),
            BlocProvider<ApplicationsBloc>(
              create: (context) => ApplicationsBloc(UserBackend()),
              lazy: false,
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Job Finder',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: const SplashScreen(), // Redirect to SplashScreen
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/':
                  page = SplashScreen();
                  break;
                case '/login':
                  page = LoginScreen();
                  break;
                case '/company_home':
                  page = const CompanyMainScreen();
                  break;
                case '/job_seeker_home':
                  page = const JobSeekerHomeScreen();
                  break;
                default:
                  return null;
              }

              return MaterialPageRoute(
                builder: (context) => page,
              );
            },
          ),
        );
      },
    );
  }
}

