import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reswipe/home_screen/screens/company_home_screen.dart';
import 'State_management/company_state.dart';
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

  Bloc.observer = SimpleBlocObserver();
  runApp(const JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  const JobFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<JobBloc>(
              create: (context) => JobBloc(),
              lazy: false, // Initialize immediately
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
              // Wrap all routes that need JobBloc access with BlocProvider
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

              // Wrap the page with BlocProvider to ensure JobBloc is available
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