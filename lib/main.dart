// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Constant/Forget Password Provider.dart';
import 'Screens/Job_Seeker/List_applied_jobs_provider.dart';
import 'Screens/Job_Seeker/Profile_Provider.dart';
import 'Screens/Job_Seeker/Signup_Provider.dart';
import 'Screens/Job_Seeker/job_seeker_provider.dart';
import 'Screens/Job_Seeker/jobs_application_provider.dart';
import 'Screens/Job_Seeker/login_provider.dart';
import 'Screens/Recruiter/LIst_of_Applicants_provider.dart';
import 'Screens/Recruiter/Signup_Provider_Recruiter.dart';
import 'Screens/Recruiter/Recruiter_provider_old.dart';
import 'Screens/Recruiter/login_provider_Recruiter.dart';
import 'Screens/Recruiter/sidebar_provider.dart';
import 'Top_Nav_Provider.dart';
import 'Web_routes.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ─── If targeting web, you can reintroduce URL strategy here:
  if (kIsWeb) {
     setUrlStrategy(PathUrlStrategy());
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Precache a dummy inter text so it’s ready immediately
    TextPainter(
      text: TextSpan(text: " ", style: GoogleFonts.inter()),
      textDirection: TextDirection.ltr,
    ).layout();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider_Recruiter()),
        ChangeNotifierProvider(create: (_) => LoginProvider_Recruiter()),
        ChangeNotifierProvider(create: (_) => JS_TopNavProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => R_TopNavProvider()),
        ChangeNotifierProvider(create: (_) => JobPostingProvider()),
        ChangeNotifierProvider(create: (_) => JobSeekerProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationsProvider()),
        ChangeNotifierProvider(create: (_) => ListAppliedJobsProvider()),
        ChangeNotifierProvider(create: (_) => ApplicantsProvider()),

      ],
      child: const JobPortalApp(),
    ),
  );
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hire Flow',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF003366),
          secondary: const Color(0xFF003366),
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          buttonColor: const Color(0xFF003366),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}

/// RoleProvider: holds the selected role (job seeker / recruiter)
class RoleProvider extends ChangeNotifier {
  /// Either "Job Seeker" or "Recruiter"
  String? _selectedRole;
  String? get selectedRole => _selectedRole;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }
}
