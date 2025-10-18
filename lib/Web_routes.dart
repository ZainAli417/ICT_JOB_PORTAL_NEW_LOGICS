// web_routes.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Constant/CV_Generator.dart';
import 'Constant/Forget Password.dart';
import 'Screens/Job_Seeker/JS_Profile.dart';
import 'Login.dart';
import 'Sign Up.dart';
import 'Screens/Job_Seeker/JS_Dashboard.dart';
import 'Screens/Job_Seeker/List_Applied_jobs_application.dart';
import 'Screens/Recruiter/LIst_of_Applicants.dart';
import 'Screens/Recruiter/Login_Recruiter.dart';
import 'Screens/Recruiter/Sign Up_Recruiter.dart';
import 'Constant/Splash.dart';
import 'Screens/Recruiter/Post_A_Job_Dashboard.dart';
import 'Screens/Recruiter/Recruiter_dashboard.dart';

/// A small service that determines a user's role by checking Firestore.
/// It supports both patterns:
///  - top-level collections: /recruiters/{uid} or /job_seekers/{uid}
///  - nested user_data doc pattern: /recruiters/{uid}/user_data/...
/// Returns 'recruiter', 'job_seeker', or null (unknown).
class RoleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String?> getUserRole(String uid) async {
    try {
      // 1) Quick check: top-level collections
      final recDoc = await _firestore.collection('recruiters').doc(uid).get();
      if (recDoc.exists) return 'recruiter';

      final jsDoc = await _firestore.collection('job_seekers').doc(uid).get();
      if (jsDoc.exists) return 'job_seeker';

      // 2) Fallback: check for 'user_data' subcollections (common pattern)
      // Check recruiter subcollection
      final recSub = await _firestore
          .collection('recruiters')
          .doc(uid)
          .collection('user_data')
          .limit(1)
          .get();
      if (recSub.docs.isNotEmpty) return 'recruiter';

      // Check job_seekers subcollection
      final jsSub = await _firestore
          .collection('job_seekers')
          .doc(uid)
          .collection('user_data')
          .limit(1)
          .get();
      if (jsSub.docs.isNotEmpty) return 'job_seeker';

      // 3) Last resort: a more generic collection scan (caution: costs small reads)
      // We avoid scanning large collections. If your project uses another collection name,
      // add checks here.

      return null;
    } catch (e, st) {
      // don't crash routing on Firestore issues — log & return null
      // ignore: avoid_print
      print('RoleService.getUserRole error: $e\n$st');
      return null;
    }
  }
}

/// AuthNotifier listens to FirebaseAuth and updates cached role when the user signs in/out.
/// It doubles as the GoRouter refreshListenable.
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  /// Cached role of the currently signed-in user.
  /// 'recruiter' | 'job_seeker' | null
  String? userRole;

  /// Whether the notifier has finished an initial role lookup
  /// (used to avoid immediate mis-redirects while role is being fetched).
  bool roleResolved = false;

  AuthNotifier() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    // If user already signed in at startup, attempt to resolve role immediately
    final u = _auth.currentUser;
    if (u != null) {
      _resolveRoleFor(u.uid);
    } else {
      roleResolved = true;
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    roleResolved = false;
    if (user == null) {
      userRole = null;
      roleResolved = true;
      notifyListeners();
      return;
    }
    await _resolveRoleFor(user.uid);
    notifyListeners();
  }

  Future<void> _resolveRoleFor(String uid) async {
    try {
      final role = await RoleService.getUserRole(uid);
      userRole = role;
    } catch (e) {
      // ignore and keep userRole null
      userRole = null;
    } finally {
      roleResolved = true;
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Single top-level AuthNotifier instance (used for GoRouter refresh)
final _authNotifier = AuthNotifier();

/// Utility to test if a route path belongs to recruiter-only screens.
bool _isRecruiterPath(String? path) {
  if (path == null) return false;
  final p = path.toLowerCase();
  return p.startsWith('/recruiter') ||
      p.startsWith('/job-posting') ||
      p.startsWith('/view-applications') ||
      p.startsWith('/recruiter-dashboard');
}

/// Utility to test job seeker-only screens.
bool _isJobSeekerPath(String? path) {
  if (path == null) return false;
  final p = path.toLowerCase();
  return p.startsWith('/dashboard') ||
      p.startsWith('/profile') ||
      p.startsWith('/download-cv') ||
      p.startsWith('/saved');
}

/// Page builder with a subtle animation (keeps your previous behaviour).
CustomTransitionPage<T> _buildPageWithAnimation<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 370),
    reverseTransitionDuration: const Duration(milliseconds: 370),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      final scaleAnimation = Tween<double>(begin: 0.99, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
  );
}

/// The router with role-aware redirects and per-route guards.
final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final role = _authNotifier.userRole;
      final roleResolved = _authNotifier.roleResolved;

      final location = state.uri.toString(); // e.g., '/login', '/dashboard'
      final isOnSplash = location == '/';

      // unified auth pages (both roles use same login/register screens)
      final isOnAuth = ['/login', '/register', '/recover-password'].contains(location);

      // If user is not logged in and not on an allowed public/auth page -> send to splash.
      if (!isLoggedIn && !isOnAuth && !isOnSplash) {
        return '/';
      }

      // If logged in but role lookup still pending: don't redirect yet
      if (isLoggedIn && !roleResolved) return null;

      // If logged in and role resolved, enforce role-based routing
      if (isLoggedIn && roleResolved) {
        final effectiveRole = role ?? 'job_seeker';

        // If on splash, send to appropriate dashboard
        if (isOnSplash) return effectiveRole == 'recruiter' ? '/recruiter-dashboard' : '/dashboard';

        // Prevent role mismatches
        if (effectiveRole == 'recruiter' && _isJobSeekerPath(location)) return '/recruiter-dashboard';
        if (effectiveRole == 'job_seeker' && _isRecruiterPath(location)) return '/dashboard';

        // Prevent logged-in users from visiting auth pages
        if (isOnAuth) {
          return effectiveRole == 'recruiter' ? '/recruiter-dashboard' : '/dashboard';
        }
      }

      return null;
    },

    // Otherwise allow navigation

  routes: <GoRoute>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const SplashScreen(),
        context: context,
        state: state,
      ),
    ),

    GoRoute(
      path: '/recover-password',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const ForgotPasswordScreen(),
        context: context,
        state: state,
      ),
    ),

    // Job seeker auth
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const JobSeekerLoginScreen(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const SignUp_Screen(),
        context: context,
        state: state,
      ),
    ),

    // Job seeker main screens
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) {
        // guard: allow only job_seekers (or fallback if role unknown)
        final role = _authNotifier.userRole;
        if (role != null && role != 'job_seeker') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(
          child: const JobSeekerDashboard(),
          context: context,
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) {
        final role = _authNotifier.userRole;
        if (role != null && role != 'job_seeker') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(child: const ProfileScreen(), context: context, state: state);
      },
    ),
    GoRoute(
      path: '/saved',
      pageBuilder: (context, state) {
        final role = _authNotifier.userRole;
        if (role != null && role != 'job_seeker') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(child: ListAppliedJobsScreen(), context: context, state: state);
      },
    ),
    GoRoute(
      path: '/download-cv',
      pageBuilder: (context, state) {
        final role = _authNotifier.userRole;
        if (role != null && role != 'job_seeker') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(child: const CVGeneratorDialog(), context: context, state: state);
      },
    ),


    // Recruiter-only routes (guarded)
    GoRoute(
      path: '/recruiter-dashboard',
      pageBuilder: (context, state) {
        final role = _authNotifier.userRole;
        if (role != 'recruiter') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(child: const RecruiterDashboard(), context: context, state: state);
      },
    ),
    GoRoute(
      path: '/job-posting',
      pageBuilder: (context, state) {
        final role = _authNotifier.userRole;
        if (role != 'recruiter') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(child: const JobPostingScreen(), context: context, state: state);
      },
    ),
    GoRoute(
      path: '/view-applications',
      pageBuilder: (context, state) {
        final role = _authNotifier.userRole;
        if (role != 'recruiter') {
          return _buildPageWithAnimation(
            child: const Scaffold(body: Center(child: Text('Access denied'))),
            context: context,
            state: state,
          );
        }
        return _buildPageWithAnimation(child: const ApplicantsScreen(), context: context, state: state);
      },
    ),
  ],
);

