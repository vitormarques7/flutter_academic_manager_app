import 'package:flutter/widgets.dart';
import 'package:academic_manager_app/view/pages/auth_gate_page.dart';
import 'package:academic_manager_app/view/pages/login_page.dart';
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
  };

  static void toLogin(BuildContext context) =>
      Navigator.pushNamed(context, login);

  static void toRegister(BuildContext context) =>
      Navigator.pushNamed(context, register);

  static void toStudentProfile(BuildContext context) =>
      Navigator.pushReplacementNamed(context, studentProfile);

  static void toStudentProfileClearingStack(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, studentProfile, (_) => false);

  static void toUniversityConfig(BuildContext context) =>
      Navigator.pushNamed(context, universityConfig);

  static void toHighSchoolConfig(BuildContext context) =>
      Navigator.pushNamed(context, highSchoolConfig);

  static void toIndependentConfig(BuildContext context) =>
      Navigator.pushNamed(context, independentConfig);

  static void toHome(BuildContext context) =>
      Navigator.pushNamed(context, home);

  static void toHomeClearingStack(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, home, (_) => false);

  static void toStudyCycleSetup(BuildContext context) =>
      Navigator.pushNamed(context, studyCycleSetup);

  static void toProfile(BuildContext context) =>
      Navigator.pushNamed(context, profile);

  static void toWelcomeClearingStack(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, welcome, (_) => false);
}
