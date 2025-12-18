// web_routes.dart - OPTIMIZED VERSION
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
import 'SignUp /profile_builder.dart';
import 'SignUp /signup_screen_auth.dart';
import 'SignUp /test.dart';

// ========== OPTIMIZED ROLE SERVICE ==========
class RoleService {
  static final _firestore = FirebaseFirestore.instance;
  static final _roleCache = <String, _CachedRole>{};
  static const _cacheExpiry = Duration(minutes: 10); // Extended cache

  // Preload roles to avoid repeated queries
  static final _pendingRequests = <String, Future<String?>>{};

  static void clearCache() {
    _roleCache.clear();
    _pendingRequests.clear();
  }

  static Future<String?> getUserRole(String uid) async {
    // Check cache first
    final cached = _roleCache[uid];
    if (cached != null && !cached.isExpired) {
      return cached.role;
    }

    // Deduplicate simultaneous requests for same UID
    if (_pendingRequests.containsKey(uid)) {
      return _pendingRequests[uid];
    }

    // Create and cache the future
    final future = _fetchRole(uid);
    _pendingRequests[uid] = future;

    try {
      final role = await future;
      if (role != null) {
        _roleCache[uid] = _CachedRole(role);
      }
      return role;
    } finally {
      _pendingRequests.remove(uid);
    }
  }

  static Future<String?> _fetchRole(String uid) async {
    try {
      // Strategy: Check most common first (job_seeker > recruiter > admin)
      // Single query approach - faster than parallel for web

      // 1. Check job_seeker collection (most common)
      final jsDoc = await _firestore.collection('job_seeker').doc(uid).get();
      if (jsDoc.exists) {
        return 'job_seeker';
      }

      // 2. Check recruiter collection
      final recDoc = await _firestore.collection('recruiter').doc(uid).get();
      if (recDoc.exists) {
        return 'recruiter';
      }

      // 3. Check admin collection
      final adminDoc = await _firestore.collection('admin').doc(uid).get();
      if (adminDoc.exists) {
        return 'admin';
      }

      // 4. Fallback to users collection
      final userQuery = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return _normalizeRole(userQuery.docs.first.data()['role']?.toString());
      }

      return null;
    } catch (e) {
      debugPrint('RoleService: error fetching role: $e');
      return null;
    }
  }

  static String? _normalizeRole(String? role) {
    if (role == null || role.isEmpty) return null;

    switch (role.toLowerCase().trim()) {
      case 'recruiter':
      case 'employer':
        return 'recruiter';
      case 'job_seeker':
      case 'jobseeker':
      case 'job seeker':
      case 'candidate':
        return 'job_seeker';
      case 'admin':
      case 'administrator':
      case 'superadmin':
        return 'admin';
      default:
        return null;
    }
  }
}

class _CachedRole {
  final String role;
  final DateTime timestamp;

  _CachedRole(this.role) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > RoleService._cacheExpiry;
}

// ========== OPTIMIZED AUTH NOTIFIER ==========
class AuthNotifier extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  String? userRole;
  bool roleResolved = false;
  User? _currentUser;

  AuthNotifier() {
    _currentUser = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);

    if (_currentUser != null) {
      _resolveRole(_currentUser!.uid);
    } else {
      roleResolved = true;
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_currentUser?.uid == user?.uid && roleResolved) {
      // Same user, skip resolution
      return;
    }

    _currentUser = user;
    roleResolved = false;

    if (user == null) {
      userRole = null;
      roleResolved = true;
      RoleService.clearCache();
    } else {
      await _resolveRole(user.uid);
    }

    notifyListeners();
  }

  Future<void> _resolveRole(String uid) async {
    try {
      userRole = await RoleService.getUserRole(uid);

      // Single retry with exponential backoff
      if (userRole == null) {
        await Future.delayed(const Duration(milliseconds: 800));
        userRole = await RoleService.getUserRole(uid);
      }

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

  bool get isLoggedIn => _currentUser != null;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// ========== ROUTE CONFIGURATION ==========
class RouteConfig {
  // Use Set for O(1) lookup instead of List
  static const _publicPaths = {
    '/',
    '/login',
    '/register',
    '/recover-password',
    '/admin',
  };

  static const _roleRoutes = {
    'admin': {'/admin', '/admin_dashboard', '/admin-dashboard'},
    'recruiter': {'/recruiter-dashboard', '/job-posting', '/view-applications', '/recruiter-job-listing'},
    'job_seeker': {'/dashboard', '/profile', '/download-cv', '/ai-tools', '/applied-jobs', '/job-hub', '/profile-builder'},
  };

  static const _roleDashboards = {
    'admin': '/admin_dashboard',
    'recruiter': '/recruiter-dashboard',
    'job_seeker': '/dashboard',
  };

  static bool isPublicPath(String? location) {
    if (location == null) return false;
    final path = _extractPath(location);
    return _publicPaths.contains(path);
  }

  static bool isAllowedForRole(String? location, String role) {
    if (location == null) return false;
    final path = _extractPath(location);
    final allowedPaths = _roleRoutes[role];

    if (allowedPaths == null) return false;

    // Direct match first
    if (allowedPaths.contains(path)) return true;

    // Then check startsWith for sub-routes
    return allowedPaths.any((allowed) => path.startsWith(allowed));
  }

  static String getDashboard(String role) => _roleDashboards[role] ?? '/';

  static String _extractPath(String location) {
    final uri = Uri.tryParse(location);
    if (uri == null) return location;

    final path = uri.path;
    return (path.length > 1 && path.endsWith('/'))
        ? path.substring(0, path.length - 1)
        : path;
  }
}

// ========== OPTIMIZED PAGE TRANSITIONS ==========
CustomTransitionPage<T> _buildPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250), // Faster
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Single animation for better performance
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}

// ========== PROFILE CHECK SERVICE ==========
class ProfileCheckService {
  static final _cache = <String, bool>{};
  static final _pendingChecks = <String, Future<bool>>{};

  static Future<bool> hasProfile(String uid) async {
    // Check cache
    if (_cache.containsKey(uid)) {
      return _cache[uid]!;
    }

    // Deduplicate requests
    if (_pendingChecks.containsKey(uid)) {
      return _pendingChecks[uid]!;
    }

    final future = _checkProfile(uid);
    _pendingChecks[uid] = future;

    try {
      final exists = await future;
      _cache[uid] = exists;
      return exists;
    } finally {
      _pendingChecks.remove(uid);
    }
  }

  static Future<bool> _checkProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('job_seeker')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('ProfileCheckService: error checking profile: $e');
      return false;
    }
  }

  static void invalidate(String uid) {
    _cache.remove(uid);
  }

  static void clearCache() {
    _cache.clear();
  }
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
      if (isLoggedIn && roleResolved && role != null) {
        return RouteConfig.getDashboard(role);
      }
      return null;
    }

    // Require authentication
    if (!isLoggedIn) return '/';

    // Wait for role resolution
    if (!roleResolved) return null;

    // Handle null role
    if (role == null) {
      debugPrint('Router: null role → forcing logout');
      FirebaseAuth.instance.signOut();
      return '/';
    }

    // Enforce role-based access
    if (!RouteConfig.isAllowedForRole(location, role)) {
      debugPrint('Router: unauthorized → redirecting to dashboard');
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
      pageBuilder: (c, s) => _buildPage(child: const SignUp_Screen(), context: c, state: s),
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

// ========== JOB SEEKER ROUTES WITH PROFILE CHECK (FINAL FIXED VERSION) ==========
    ShellRoute(
      builder: (context, state, child) {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          return Scaffold(body: Center(child: Text('Authentication error')));
        }

        final uid = user.uid;

        // Use a StatefulShellBranch or a simple ValueNotifier to avoid rebuilding Future every time
        // But the cleanest way: use a singleton cache + direct check
        return _JobSeekerShell(
          uid: uid,
          child: child,
          currentPath: state.uri.path,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (c, s) => _buildPage(child: const job_seeker_dashboard(), context: c, state: s),
        ),
        GoRoute(
          path: '/profile-builder',
          pageBuilder: (c, s) => _buildPage(child: const ProfileBuilderScreen(), context: c, state: s),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (c, s) => _buildPage(child: const ProfileScreen_NEW(), context: c, state: s),
        ),
        GoRoute(
          path: '/ai-tools',
          pageBuilder: (c, s) => _buildPage(child: CVAnalysisScreen(), context: c, state: s),
        ),
        GoRoute(
          path: '/job-hub',
          pageBuilder: (c, s) => _buildPage(child: job_hub(), context: c, state: s),
        ),
      ],
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

class _JobSeekerShell extends StatefulWidget {
  final String uid;
  final Widget child;
  final String currentPath;

  const _JobSeekerShell({
    required this.uid,
    required this.child,
    required this.currentPath,
  });

  @override
  State<_JobSeekerShell> createState() => _JobSeekerShellState();
}

class _JobSeekerShellState extends State<_JobSeekerShell> {
  bool? _hasProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final hasProfile = await ProfileCheckService.hasProfile(widget.uid);
    if (mounted) {
      setState(() {
        _hasProfile = hasProfile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loader ONLY on first load
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigo),
              SizedBox(height: 24),
              Text(
                'Encrypting Your Session...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    final hasProfile = _hasProfile!;

    // Redirect logic (only once)
    if (!hasProfile && widget.currentPath != '/profile-builder') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/profile-builder');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasProfile && widget.currentPath == '/profile-builder') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/dashboard');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Normal navigation — no loader anymore
    return widget.child;
  }
}