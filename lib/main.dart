import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reswipe/home_screen/screens/company_home_screen.dart';
import 'State_management/Company_state.dart';
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
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  );
                case '/company_home':
                  return MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: BlocProvider.of<JobBloc>(context),
                      child: const CompanyMainScreen(),
                    ),
                  );
                case '/job_seeker_home':
                  return MaterialPageRoute(
                    builder: (_) => JobSeekerHomeScreen(),
                  );
                default:
                  return null;
              }
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