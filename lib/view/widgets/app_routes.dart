import 'package:flutter/material.dart';
import '../../view/pages/welcome_page.dart';
import '../../config/register_page.dart';
import '../../view/pages/filtering_page.dart';
import '../../view/pages/university_config_page.dart';
//import '../../view/pages/high_school_config_page.dart';
import '../../view/pages/independent_config_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String register = '/register';
  static const String studentProfile = '/student-profile';
  static const String universityConfig = '/university-config';
  static const String highSchoolConfig = '/high-school-config';
  static const String independentConfig = '/independent-config';

  static final Map<String, WidgetBuilder> routes = {
    welcome: (_) => const WelcomePage(),
    register: (_) => const RegisterPage(),
    studentProfile: (_) => const StudentFilteringPage(),
    universityConfig: (_) => const UniversityConfigPage(),
    //highSchoolConfig:  (_) => const HighSchoolConfigPage(),
    independentConfig: (_) => const IndependentConfigPage(),
  };

  static void toRegister(BuildContext context) =>
      Navigator.pushNamed(context, register);

  static void toStudentProfile(BuildContext context) =>
      Navigator.pushReplacementNamed(context, studentProfile);

  static void toUniversityConfig(BuildContext context) =>
      Navigator.pushNamed(context, universityConfig);

  static void toHighSchoolConfig(BuildContext context) =>
      Navigator.pushNamed(context, highSchoolConfig);

  static void toIndependentConfig(BuildContext context) =>
      Navigator.pushNamed(context, independentConfig);
}
