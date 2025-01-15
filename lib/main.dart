import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reswipe/backend/company_backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reswipe/home_screen/screens/company_home_screen.dart';
import 'auth/auth_wrapper.dart';
import 'auth/login_screen.dart';
import 'firebase_options.dart';
import 'home_screen/screens/job_seeker_home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  Bloc.observer = SimpleBlocObserver();
  runApp(JobFinderApp(prefs: prefs));
}

class JobFinderApp extends StatelessWidget {
  final SharedPreferences prefs;

  const JobFinderApp({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<JobBloc>(
              create: (context) => JobBloc(prefs: prefs),
              lazy: false,
            ),
            BlocProvider<LogoutBloc>(
              create: (context) => LogoutBloc(prefs: prefs),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Job Finder',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: const AuthWrapper(),
            onGenerateRoute: (settings) {
              Widget? page;
              switch (settings.name) {
                case '/login':
                  page = LoginScreen();
                  break;
                case '/company_home':
                  page = const CompanyMainScreen();
                  break;
                case '/job_seeker_home':
                  page = JobSeekerHomeScreen();
                  break;
                default:
                  return null;
              }

              return MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: BlocProvider.of<JobBloc>(context),
                  child: page,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}