// web_routes.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Constant/CV_Generator.dart';
import 'Constant/Forget Password.dart';
import 'Constant/cv_analysis.dart';
import 'Screens/Admin/admin_dashbaord.dart';
import 'Screens/Admin/admin_login.dart';
import 'Screens/Job_Seeker/JS_Profile.dart';
import 'Login.dart';
import 'Screens/Recruiter/Recruiter_Job_Listing.dart';
import 'Sign Up.dart';
import 'Screens/Job_Seeker/job_hub.dart';
import 'Screens/Job_Seeker/job_seeker_dashboard.dart';
import 'Screens/Recruiter/LIst_of_Applicants.dart';
import 'Screens/Recruiter/Login_Recruiter.dart';
import 'Screens/Recruiter/Sign Up_Recruiter.dart';
import 'Constant/Splash.dart';
import 'Screens/Recruiter/Post_A_Job_Dashboard.dart';
import 'Screens/Recruiter/Recruiter_dashboard.dart';
import 'SignUp /signup_UI.dart';

/// Enhanced RoleService with admin detection and caching
class RoleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache to avoid repeated lookups during same session
  static final Map<String, String> _roleCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  static void clearCache() {
    _roleCache.clear();
    _cacheTimestamps.clear();
  }

  static Future<String?> getUserRole(String uid) async {
    // Cache check
    if (_roleCache.containsKey(uid)) {
      final timestamp = _cacheTimestamps[uid];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        debugPrint('RoleService: using cached role for $uid: ${_roleCache[uid]}');
        return _roleCache[uid];
      }
    }

    try {
      // 1) Custom claims (fastest)
      final custom = await _checkCustomClaims();
      if (custom != null) {
        _cacheRole(uid, custom);
        return custom;
      }

      // 2) Admin collection (check admins first so admin users are detected)
      final adminRole = await _checkAdminCollection(uid);
      if (adminRole != null) {
        _cacheRole(uid, adminRole);
        return adminRole;
      }

      // 3) Recruiter collection
      final recruiterRole = await _checkRecruiterCollection(uid);
      if (recruiterRole != null) {
        _cacheRole(uid, recruiterRole);
        return recruiterRole;
      }

      // 4) Job seeker collection
      final jobSeekerRole = await _checkJobSeekerCollection(uid);
      if (jobSeekerRole != null) {
        _cacheRole(uid, jobSeekerRole);
        return jobSeekerRole;
      }

      // 5) Users collection lookup (if you store role here)
      final usersRole = await _checkUsersCollection(uid);
      if (usersRole != null) {
        _cacheRole(uid, usersRole);
        return usersRole;
      }

      debugPrint('RoleService: no role found for $uid');
      return null;
    } catch (e, st) {
      debugPrint('RoleService.getUserRole ERROR: $e\n$st');
      return null;
    }
  }

  static String? _normalizeRole(String? role) {
    if (role == null) return null;
    final normalized = role.toString().toLowerCase().trim();
    if (normalized == 'recruiter' || normalized == 'employer') return 'recruiter';
    if (normalized == 'job_seeker' || normalized == 'jobseeker' || normalized == 'job seeker' || normalized == 'candidate') {
      return 'job_seeker';
    }
    if (normalized == 'admin' || normalized == 'administrator' || normalized == 'superadmin') return 'admin';
    return null;
  }

  static Future<String?> _checkCustomClaims() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdTokenResult(true);
        final claims = idToken.claims;
        if (claims != null && claims['role'] != null) {
          final role = _normalizeRole(claims['role'].toString());
          if (role != null) {
            debugPrint('RoleService: found role in custom claims: $role');
            return role;
          }
        }
      }
    } catch (e) {
      debugPrint('RoleService: custom claims check failed: $e');
    }
    return null;
  }

  static Future<String?> _checkAdminCollection(String uid) async {
    try {
      debugPrint('RoleService: checking admins/$uid');
      final doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final direct = _normalizeRole(data['role']?.toString());
          if (direct == 'admin') return 'admin';
          if (data.containsKey('role') == false) {
            // If doc exists in admins collection, assume admin (conservative)
            return 'admin';
          }
        } else {
          // doc exists but no data: still treat as admin
          return 'admin';
        }
      }
    } catch (e) {
      debugPrint('RoleService: admin collection check failed: $e');
    }
    return null;
  }

  static Future<String?> _checkRecruiterCollection(String uid) async {
    try {
      debugPrint('RoleService: checking recruiter/$uid');
      final doc = await _firestore.collection('recruiter').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (data['user_data'] is Map) {
            final userData = data['user_data'] as Map<String, dynamic>;
            final rawRole = userData['role']?.toString();
            final role = _normalizeRole(rawRole);
            if (role == 'recruiter') return 'recruiter';
          }
          final directRole = _normalizeRole(data['role']?.toString());
          if (directRole == 'recruiter') return 'recruiter';
          // If exists in recruiter collection, treat as recruiter.
          return 'recruiter';
        }
      }
    } catch (e) {
      debugPrint('RoleService: recruiter collection check failed: $e');
    }
    return null;
  }

  static Future<String?> _checkJobSeekerCollection(String uid) async {
    try {
      debugPrint('RoleService: checking job_seeker/$uid');
      final doc = await _firestore.collection('job_seeker').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (data['user_data'] is Map) {
            final userData = data['user_data'] as Map<String, dynamic>;
            final rawRole = userData['role']?.toString();
            final role = _normalizeRole(rawRole);
            if (role == 'job_seeker') return 'job_seeker';
          }
          final directRole = _normalizeRole(data['role']?.toString());
          if (directRole == 'job_seeker') return 'job_seeker';
          return 'job_seeker';
        }
      }
    } catch (e) {
      debugPrint('RoleService: job seeker collection check failed: $e');
    }
    return null;
  }

  static Future<String?> _checkUsersCollection(String uid) async {
    try {
      debugPrint('RoleService: querying users collection for uid=$uid');
      final qs = await _firestore.collection('users').where('uid', isEqualTo: uid).limit(1).get();
      if (qs.docs.isNotEmpty) {
        final data = qs.docs.first.data();
        final rawRole = data['role']?.toString();
        final role = _normalizeRole(rawRole);
        if (role != null) {
          return role;
        }
      }
    } catch (e) {
      debugPrint('RoleService: users collection query failed: $e');
    }
    return null;
  }

  static void _cacheRole(String uid, String role) {
    _roleCache[uid] = role;
    _cacheTimestamps[uid] = DateTime.now();
    debugPrint('RoleService: cached role for $uid: $role');
  }
}

/// AuthNotifier: manages auth & role resolution for GoRouter refresh
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  String? userRole;
  bool roleResolved = false;
  bool _isResolving = false;

  AuthNotifier() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);

    final cur = _auth.currentUser;
    if (cur != null) {
      _resolveRoleFor(cur.uid);
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
      _isResolving = false;
      notifyListeners();
      return;
    }

    await _resolveRoleFor(user.uid);
    _isResolving = false;
    notifyListeners();
  }

  Future<void> _resolveRoleFor(String uid) async {
    debugPrint('AuthNotifier: resolving role for $uid');
    try {
      userRole = await RoleService.getUserRole(uid);

      // Retry once on null (transient network)
      if (userRole == null) {
        debugPrint('AuthNotifier: retrying role lookup for $uid');
        await Future.delayed(const Duration(milliseconds: 500));
        userRole = await RoleService.getUserRole(uid);
      }

      if (userRole == null) {
        debugPrint('AuthNotifier: role resolution failed (null role) for $uid — user will be logged out');
        try {
          await _auth.signOut(); // defensive: prevent unknown-role users from remaining signed in
        } catch (e) {
          debugPrint('AuthNotifier: signOut failed: $e');
        }
      } else {
        debugPrint('AuthNotifier: resolved role=$userRole for $uid');
      }
    } catch (e, st) {
      debugPrint('AuthNotifier: error resolving role: $e\n$st');
      userRole = null;
    } finally {
      roleResolved = true;
    }
  }

  Future<void> refreshRole() async {
    final u = _auth.currentUser;
    if (u != null) {
      RoleService.clearCache();
      roleResolved = false;
      notifyListeners();
      await _resolveRoleFor(u.uid);
      notifyListeners();
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Shared instance used by router refreshListenable
final _authNotifier = AuthNotifier();

/// Path helpers
bool _isRecruiterPath(String? path) {
  if (path == null) return false;
  final p = path.toLowerCase();
  return p.startsWith('/recruiter-dashboard') ||
      p.startsWith('/job-posting') ||
      p.startsWith('/view-applications');
}

bool _isJobSeekerPath(String? path) {
  if (path == null) return false;
  final p = path.toLowerCase();
  return p.startsWith('/dashboard') ||
      p.startsWith('/profile') ||
      p.startsWith('/download-cv') ||
      p.startsWith('/ai-tools') ||
      p.startsWith('/applied-jobs');
}

bool _isAdminPath(String? path) {
  if (path == null) return false;
  final p = path.toLowerCase();
  return p == '/admin' ||
      p.startsWith('/admin/') ||
      p.startsWith('/admin_dashboard') ||
      p.startsWith('/admin-dashboard');
}

/// Public (unauthenticated) paths
bool _isPublicPath(String? location) {
  if (location == null) return false;
  String path;
  try {
    path = Uri.parse(location).path;
  } catch (_) {
    path = location;
  }
  final normalized = (path.length > 1 && path.endsWith('/')) ? path.substring(0, path.length - 1) : path;

  const publicPaths = [
    '/',
    '/login',
    '/register',
    '/recover-password',
    '/admin', // allow direct access to admin login
  ];
  if (publicPaths.contains(normalized)) return true;
  // if you want all /admin/* public (not recommended), use: if (normalized.startsWith('/admin')) return true;
  return false;
}

/// Animated page transition helper
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
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final scale = Tween<double>(begin: 0.99, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(opacity: fade, child: ScaleTransition(scale: scale, child: child));
    },
  );
}

/// Main router
final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final role = _authNotifier.userRole;
    final roleResolved = _authNotifier.roleResolved;
    final location = state.uri.toString();

    debugPrint('Router.redirect -> loc=$location loggedIn=$isLoggedIn role=$role resolved=$roleResolved');

    // allow public pages (including admin login)
    if (_isPublicPath(location)) {
      // if already signed in and role resolved, send to respective dashboard
      if (isLoggedIn && roleResolved && role != null) {
        if (role == 'admin') return '/admin_dashboard';
        if (role == 'recruiter') return '/recruiter-dashboard';
        return '/dashboard';
      }
      return null;
    }

    // if not logged in, redirect to splash
    if (!isLoggedIn) return '/';

    // logged in but role not resolved yet — allow route to wait (don't redirect)
    if (!roleResolved) {
      debugPrint('Router: role not resolved yet; waiting for AuthNotifier');
      return null;
    }

    // logged in, role resolved but not found -> sign-in required
    if (role == null) {
      debugPrint('Router: resolved role is null -> redirecting to /login');
      return '/login';
    }

    // Role-based guard: block access to other roles' pages
    // Admin: allow admin pages, block access to recruiter/job seeker pages
    if (role == 'admin') {
      if (_isRecruiterPath(location) || _isJobSeekerPath(location)) {
        debugPrint('Router: admin attempted non-admin path -> redirect to admin_dashboard');
        return '/admin_dashboard';
      }
      // allow admin pages
      return null;
    }

    // Recruiter: prevent entering admin or job seeker pages
    if (role == 'recruiter') {
      if (_isAdminPath(location)) {
        debugPrint('Router: recruiter attempted admin path -> redirect to recruiter-dashboard');
        return '/recruiter-dashboard';
      }
      if (_isJobSeekerPath(location)) {
        debugPrint('Router: recruiter attempted job-seeker path -> redirect to recruiter-dashboard');
        return '/recruiter-dashboard';
      }
      return null;
    }

    // Job seeker: prevent admin/recruiter pages
    if (role == 'job_seeker') {
      if (_isAdminPath(location)) {
        debugPrint('Router: job seeker attempted admin path -> redirect to /dashboard');
        return '/dashboard';
      }
      if (_isRecruiterPath(location)) {
        debugPrint('Router: job seeker attempted recruiter path -> redirect to /dashboard');
        return '/dashboard';
      }
      return null;
    }

    return null;
  },
  routes: <GoRoute>[
    // Public routes
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithAnimation(child: const SplashScreen(), context: context, state: state),
    ),

    // Admin login (public) and admin dashboard (guarded by redirect logic)
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => _buildPageWithAnimation(child: const AdminLoginScreen(), context: context, state: state),
    ),
    GoRoute(
      path: '/admin_dashboard',
      pageBuilder: (context, state) => _buildPageWithAnimation(child: const AdminDashboardScreen(), context: context, state: state),
    ),

    GoRoute(
      path: '/recover-password',
      pageBuilder: (context, state) => _buildPageWithAnimation(child: const ForgotPasswordScreen(), context: context, state: state),
    ),

    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPageWithAnimation(child: const JobSeekerLoginScreen(), context: context, state: state),
    ),

    GoRoute(
      path: '/register',
      //pageBuilder: (context, state) => _buildPageWithAnimation(child: const SignUp_Screen(), context: context, state: state),
      pageBuilder: (context, state) => _buildPageWithAnimation(child: const SignUp_Screen2(), context: context, state: state),
    ),

    // Job seeker routes
    GoRoute(path: '/dashboard', pageBuilder: (c, s) => _buildPageWithAnimation(child: const job_seeker_dashboard(), context: c, state: s)),
    GoRoute(path: '/profile', pageBuilder: (c, s) => _buildPageWithAnimation(child: const ProfileScreen(), context: c, state: s)),
    GoRoute(path: '/job-hub', pageBuilder: (c, s) => _buildPageWithAnimation(child: job_hub(), context: c, state: s)),
    GoRoute(path: '/ai-tools', pageBuilder: (c, s) => _buildPageWithAnimation(child:  CVAnalysisScreen(), context: c, state: s)),
    GoRoute(path: '/download-cv', pageBuilder: (c, s) => _buildPageWithAnimation(child: const CVGeneratorDialog(), context: c, state: s)),

    // Recruiter routes
    GoRoute(path: '/recruiter-dashboard', pageBuilder: (c, s) => _buildPageWithAnimation(child: const RecruiterDashboard(), context: c, state: s)),
    GoRoute(path: '/recruiter-job-listing', pageBuilder: (c, s) => _buildPageWithAnimation(child: const JobPostingScreen(), context: c, state: s)),
   // GoRoute(path: '/job-posting', pageBuilder: (c, s) => _buildPageWithAnimation(child: const recruiter_job_listing(), context: c, state: s)),
    GoRoute(path: '/view-applications', pageBuilder: (c, s) => _buildPageWithAnimation(child: const ApplicantsScreen(), context: c, state: s)),
  ],
);
