import 'package:flutter/widgets.dart';
import 'package:academic_manager_app/view/pages/auth_gate_page.dart';
import 'package:academic_manager_app/view/pages/login_page.dart';
import 'package:academic_manager_app/view/pages/personal_data_page.dart';
import 'package:academic_manager_app/view/pages/study_cycle_setup_page.dart';
import 'package:academic_manager_app/view/pages/user_profile_page.dart';
import 'package:academic_manager_app/view/shell/main_shell.dart';
import '../../view/pages/welcome_page.dart';
import '../../view/pages/register_page.dart';
import '../../view/pages/filtering_page.dart';
import '../../view/pages/university_config_page.dart';
import '../../view/pages/high_school_config_page.dart';
import '../../view/pages/independent_config_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String authGate = '/auth';
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String studentProfile = '/student-profile';
  static const String universityConfig = '/university-config';
  static const String highSchoolConfig = '/high-school-config';
  static const String independentConfig = '/independent-config';
  static const String home = '/home';
  static const String subjects = '/subjects';
  static const String tasks = '/tasks';
  static const String schedule = '/schedule';
  static const String studyCycleSetup = '/study-cycle-setup';
  static const String profile = '/profile';
  static const String personalData = '/personal-data';

  static final Map<String, WidgetBuilder> routes = {
    authGate: (_) => const AuthGatePage(),
    welcome: (_) => const WelcomePage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    studentProfile: (_) => const StudentFilteringPage(),
    universityConfig: (_) => const UniversityConfigPage(),
    highSchoolConfig: (_) => const HighSchoolConfigPage(),
    independentConfig: (_) => const IndependentConfigPage(),
    home: (_) => const MainShell(),
    subjects: (_) => const MainShell(initialIndex: 1),
    tasks: (_) => const MainShell(initialIndex: 2),
    schedule: (_) => const MainShell(initialIndex: 3),
    studyCycleSetup: (_) => const StudyCycleSetupPage(),
    profile: (_) => const UserProfilePage(),
    personalData: (_) => const PersonalDataPage(),
  };

  static Route<T> slideRoute<T>({
    required Widget page,
    Offset begin = const Offset(1, 0),
    Duration duration = const Duration(milliseconds: 230),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 190),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static void toLogin(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const LoginPage()));
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const RegisterPage()));
  }

  static void toStudentProfile(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(slideRoute(page: const StudentFilteringPage()));
  }

  static void toStudentProfileClearingStack(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      slideRoute(page: const StudentFilteringPage()),
      (_) => false,
    );
  }

  static void toUniversityConfig(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const UniversityConfigPage()));
  }

  static void toHighSchoolConfig(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const HighSchoolConfigPage()));
  }

  static void toIndependentConfig(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const IndependentConfigPage()));
  }

  static void toHome(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const MainShell()));
  }

  static void toHomeClearingStack(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      slideRoute(page: const MainShell(), begin: const Offset(0, 0.08)),
      (_) => false,
    );
  }

  static void toStudyCycleSetup(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const StudyCycleSetupPage()));
  }

  static void toProfile(BuildContext context) {
    Navigator.of(context).push(
      slideRoute(page: const UserProfilePage(), begin: const Offset(-1, 0)),
    );
  }

  static void toPersonalData(BuildContext context) {
    Navigator.of(context).push(slideRoute(page: const PersonalDataPage()));
  }

  static void toWelcomeClearingStack(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      slideRoute(page: const WelcomePage(), begin: const Offset(-1, 0)),
      (_) => false,
    );
  }
}
