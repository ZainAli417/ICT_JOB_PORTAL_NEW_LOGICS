// web_routes.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Constant/Forget Password.dart';
import 'Constant/cv_analysis.dart';
import 'Constant/onboarding.dart';
import 'Screens/Admin/admin_dashbaord.dart';
import 'Screens/Admin/admin_login.dart';
import 'Screens/Job_Seeker/JS_Profile/JS_Profile.dart';
import 'Login.dart';
import 'Screens/Job_Seeker/job_hub.dart';
import 'Screens/Job_Seeker/job_seeker_dashboard.dart';
import 'Screens/Recruiter/LIst_of_Applicants.dart';
import 'Constant/Splash.dart';
import 'Screens/Recruiter/Post_A_Job_Dashboard.dart';
import 'Screens/Recruiter/Recruiter_dashboard.dart';
import 'SignUp /signup_UI.dart';

// ========== ROLE SERVICE ==========
class RoleService {
  static final _firestore = FirebaseFirestore.instance;
  static final _roleCache = <String, _CachedRole>{};
  static const _cacheExpiry = Duration(minutes: 5);

  static void clearCache() => _roleCache.clear();

  static Future<String?> getUserRole(String uid) async {
    // Check cache
    final cached = _roleCache[uid];
    if (cached != null && !cached.isExpired) {
      debugPrint('RoleService: cache hit for $uid → ${cached.role}');
      return cached.role;
    }

    // Parallel fetching for faster resolution
    final results = await Future.wait([
      _checkCustomClaims(),
      _checkCollection('admin', uid, 'admin'),
      _checkCollection('recruiter', uid, 'recruiter'),
      _checkCollection('job_seeker', uid, 'job_seeker'),
    ]);

    // First non-null wins
    final role = results.firstWhere((r) => r != null, orElse: () => null);

    // Fallback to users collection if still null
    final finalRole = role ?? await _checkUsersCollection(uid);

    if (finalRole != null) {
      _roleCache[uid] = _CachedRole(finalRole);
      debugPrint('RoleService: resolved role for $uid → $finalRole');
    } else {
      debugPrint('RoleService: no role found for $uid');
    }

    return finalRole;
  }

  static Future<String?> _checkCustomClaims() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdTokenResult(true);
      final role = idToken?.claims?['role'];
      return _normalizeRole(role?.toString());
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _checkCollection(String collection, String uid, String expectedRole) async {
    try {
      final doc = await _firestore.collection(collection).doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return expectedRole; // Doc exists, assume role

      // Check nested user_data
      if (data['user_data'] is Map) {
        final userData = data['user_data'] as Map<String, dynamic>;
        final role = _normalizeRole(userData['role']?.toString());
        if (role == expectedRole) return expectedRole;
      }

      // Check direct role field
      final directRole = _normalizeRole(data['role']?.toString());
      if (directRole == expectedRole) return expectedRole;

      // Default to expected role if doc exists in collection
      return expectedRole;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _checkUsersCollection(String uid) async {
    try {
      final qs = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) return null;
      return _normalizeRole(qs.docs.first.data()['role']?.toString());
    } catch (_) {
      return null;
    }
  }

  static String? _normalizeRole(String? role) {
    if (role == null) return null;

    final normalized = role.toLowerCase().trim();
    if (['recruiter', 'employer'].contains(normalized)) return 'recruiter';
    if (['job_seeker', 'jobseeker', 'job seeker', 'candidate'].contains(normalized)) return 'job_seeker';
    if (['admin', 'administrator', 'superadmin'].contains(normalized)) return 'admin';

    return null;
  }
}

class _CachedRole {
  final String role;
  final DateTime timestamp;

  _CachedRole(this.role) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > RoleService._cacheExpiry;
}

// ========== AUTH NOTIFIER ==========
class AuthNotifier extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  String? userRole;
  bool roleResolved = false;
  bool _isResolving = false;

  AuthNotifier() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    final user = _auth.currentUser;

    if (user != null) {
      _resolveRole(user.uid);
    } else {
      roleResolved = true;
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_isResolving) return;

    _isResolving = true;
    roleResolved = false;

    if (user == null) {
      userRole = null;
      roleResolved = true;
      RoleService.clearCache();
    } else {
      await _resolveRole(user.uid);
    }

    _isResolving = false;
    notifyListeners();
  }

  Future<void> _resolveRole(String uid) async {
    try {
      userRole = await RoleService.getUserRole(uid);

      // Retry once on failure
      if (userRole == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        userRole = await RoleService.getUserRole(uid);
      }

      // Force logout on persistent failure
      if (userRole == null) {
        debugPrint('AuthNotifier: role resolution failed → signing out');
        await _auth.signOut();
      }
    } catch (e) {
      debugPrint('AuthNotifier: error resolving role: $e');
      userRole = null;
    } finally {
      roleResolved = true;
    }
  }

  Future<void> refreshRole() async {
    final user = _auth.currentUser;
    if (user == null) return;

    RoleService.clearCache();
    roleResolved = false;
    notifyListeners();

    await _resolveRole(user.uid);
    notifyListeners();
  }

  bool get isLoggedIn => _auth.currentUser != null;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// ========== ROUTE CONFIGURATION ==========
class RouteConfig {
  static const publicPaths = ['/', '/login', '/register', '/recover-password', '/admin'];

  static const roleRoutes = {
    'admin': ['/admin', '/admin_dashboard', '/admin-dashboard'],
    'recruiter': ['/recruiter-dashboard', '/job-posting', '/view-applications', '/recruiter-job-listing'],
    'job_seeker': ['/dashboard', '/profile', '/download-cv', '/ai-tools', '/applied-jobs', '/job-hub'],
  };

  static const roleDashboards = {
    'admin': '/admin_dashboard',
    'recruiter': '/recruiter-dashboard',
    'job_seeker': '/dashboard',
  };

  static bool isPublicPath(String? location) {
    if (location == null) return false;

    final path = _extractPath(location);
    return publicPaths.contains(path);
  }

  static bool isAllowedForRole(String? location, String role) {
    if (location == null) return false;

    final path = _extractPath(location);
    final allowedPaths = roleRoutes[role] ?? [];

    return allowedPaths.any((allowed) => path.startsWith(allowed));
  }

  static String getDashboard(String role) => roleDashboards[role] ?? '/';

  static String _extractPath(String location) {
    try {
      final path = Uri.parse(location).path;
      return (path.length > 1 && path.endsWith('/'))
          ? path.substring(0, path.length - 1)
          : path;
    } catch (_) {
      return location;
    }
  }
}

// ========== PAGE TRANSITIONS ==========
CustomTransitionPage<T> _buildPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final scale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
// ========== ROUTER ==========
final _authNotifier = AuthNotifier();
final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final role = _authNotifier.userRole;
    final roleResolved = _authNotifier.roleResolved;
    final location = state.uri.toString();

    // Allow public paths
    if (RouteConfig.isPublicPath(location)) {
      // Redirect authenticated users to their dashboard
      if (isLoggedIn && roleResolved && role != null) {
        return RouteConfig.getDashboard(role);
      }
      return null;
    }

    // Require authentication
    if (!isLoggedIn) return '/';

    // Wait for role resolution
    if (!roleResolved) return null;

    // Handle null role (should not happen after resolution)
    if (role == null) {
      debugPrint('Router: null role after resolution → /login');
      return '/login';
    }

    // Enforce role-based access
    if (!RouteConfig.isAllowedForRole(location, role)) {
      debugPrint('Router: unauthorized access attempt by $role → redirecting to dashboard');
      return RouteConfig.getDashboard(role);
    }

    return null;
  },
  routes: [
    // ========== PUBLIC ROUTES ==========
    GoRoute(
      path: '/',
      pageBuilder: (c, s) => _buildPage(child: const SplashScreen(), context: c, state: s),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) => _buildPage(child: const JobSeekerLoginScreen(), context: c, state: s),
    ),

    GoRoute(
      path: '/register',
      pageBuilder: (c, s) => _buildPage(child: const SignUp_Screen2(), context: c, state: s),
    ),
    GoRoute(
      path: '/recover-password',
      pageBuilder: (c, s) => _buildPage(child: const ForgotPasswordScreen(), context: c, state: s),
    ),

    // ========== ADMIN ROUTES ==========
    GoRoute(
      path: '/admin',
      pageBuilder: (c, s) => _buildPage(child: const AdminLoginScreen(), context: c, state: s),
    ),
    GoRoute(
      path: '/admin_dashboard',
      pageBuilder: (c, s) => _buildPage(child: const AdminDashboardScreen(), context: c, state: s),
    ),

    // ========== JOB SEEKER ROUTES ==========
    GoRoute(
      path: '/dashboard',
      pageBuilder: (c, s) => _buildPage(child: const job_seeker_dashboard(), context: c, state: s),//index0
    ),
  /*  GoRoute(
      path: '/profile',
      pageBuilder: (c, s) => _buildPage(child: const ProfileScreen(), context: c, state: s),//index1
    ),*/
    GoRoute(

      path: '/profile',
      pageBuilder: (c, s) => _buildPage(child: const ProfileScreen_NEW(), context: c, state: s),//index1
    ),
    GoRoute(
      path: '/ai-tools',
      pageBuilder: (c, s) => _buildPage(child: CVAnalysisScreen(), context: c, state: s),//index2
    ),
    GoRoute(
      path: '/job-hub',
      pageBuilder: (c, s) => _buildPage(child: job_hub(), context: c, state: s),//index3
    ),



    // ========== RECRUITER ROUTES ==========
    GoRoute(
      path: '/recruiter-dashboard',
      pageBuilder: (c, s) => _buildPage(child: const RecruiterDashboard(), context: c, state: s),
    ),
    GoRoute(
      path: '/recruiter-job-listing',
      pageBuilder: (c, s) => _buildPage(child: const JobPostingScreen(), context: c, state: s),
    ),
    GoRoute(
      path: '/view-applications',
      pageBuilder: (c, s) => _buildPage(child: const ApplicantsScreen(), context: c, state: s),
    ),
  ],
);