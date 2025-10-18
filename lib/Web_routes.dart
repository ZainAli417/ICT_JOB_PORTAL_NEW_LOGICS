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

/// Enhanced RoleService with proper Firestore querying for your database structure
class RoleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache to avoid repeated lookups during same session
  static final Map<String, String> _roleCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// Clears the role cache (useful after logout)
  static void clearCache() {
    _roleCache.clear();
    _cacheTimestamps.clear();
  }

  /// Main method to determine user role with multiple fallback strategies
  static Future<String?> getUserRole(String uid) async {
    // Check cache first
    if (_roleCache.containsKey(uid)) {
      final timestamp = _cacheTimestamps[uid];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        print('RoleService: Using cached role for $uid: ${_roleCache[uid]}');
        return _roleCache[uid];
      }
    }

    try {
      // Strategy 1: Check Firebase Auth custom claims (fastest if set)
      final customRole = await _checkCustomClaims();
      if (customRole != null) {
        _cacheRole(uid, customRole);
        return customRole;
      }

      // Strategy 2: Check recruiter collection with user_data map field
      final recruiterRole = await _checkRecruiterCollection(uid);
      if (recruiterRole != null) {
        _cacheRole(uid, recruiterRole);
        return recruiterRole;
      }

      // Strategy 3: Check job_seeker collection with user_data map field
      final jobSeekerRole = await _checkJobSeekerCollection(uid);
      if (jobSeekerRole != null) {
        _cacheRole(uid, jobSeekerRole);
        return jobSeekerRole;
      }

      // Strategy 4: Query users collection with auto-generated IDs
      final usersRole = await _checkUsersCollection(uid);
      if (usersRole != null) {
        _cacheRole(uid, usersRole);
        return usersRole;
      }

      // No role found
      print('RoleService: No role found for uid: $uid');
      return null;

    } catch (e, st) {
      print('RoleService.getUserRole ERROR: $e');
      print('Stack trace: $st');
      return null;
    }
  }

  /// Normalize role to lowercase for consistency
  static String? _normalizeRole(String? role) {
    if (role == null) return null;
    final normalized = role.toLowerCase().trim();
    // Map common variations to standard values
    if (normalized == 'recruiter') return 'recruiter';
    if (normalized == 'job_seeker' || normalized == 'jobseeker' || normalized == 'job seeker') {
      return 'job_seeker';
    }
    return null; // Invalid role
  }

  /// Check Firebase Auth custom claims
  static Future<String?> _checkCustomClaims() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult(true);
        final claims = idTokenResult.claims;
        if (claims != null && claims['role'] != null) {
          final role = _normalizeRole(claims['role'].toString());
          if (role != null) {
            print('RoleService: Found role in custom claims: $role');
            return role;
          }
        }
      }
    } catch (e) {
      print('RoleService: Custom claims check failed: $e');
    }
    return null;
  }

  /// Check recruiter/{uid} document with user_data map field
  /// Structure: recruiter/{uid} -> { user_data: { role, email, name } }
  static Future<String?> _checkRecruiterCollection(String uid) async {
    try {
      print('RoleService: Checking recruiter/$uid');
      final doc = await _firestore.collection('recruiter').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Check if user_data is a map field
          if (data['user_data'] is Map) {
            final userData = data['user_data'] as Map<String, dynamic>;
            final rawRole = userData['role']?.toString();
            final role = _normalizeRole(rawRole);
            if (role == 'recruiter') {
              print('RoleService: Found recruiter role in user_data map (raw: $rawRole, normalized: $role)');
              return 'recruiter';
            }
          }

          // Check if role is directly on the document
          final directRole = _normalizeRole(data['role']?.toString());
          if (directRole == 'recruiter') {
            print('RoleService: Found recruiter role directly on document');
            return 'recruiter';
          }

          // If document exists under recruiter collection, assume recruiter
          print('RoleService: Document exists in recruiter collection, assuming recruiter role');
          return 'recruiter';
        }
      }
    } catch (e) {
      print('RoleService: Recruiter collection check failed: $e');
    }
    return null;
  }

  /// Check job_seeker/{uid} document with user_data map field
  /// Structure: job_seeker/{uid} -> { user_data: { role, email, name } }
  static Future<String?> _checkJobSeekerCollection(String uid) async {
    try {
      print('RoleService: Checking job_seeker/$uid');
      final doc = await _firestore.collection('job_seeker').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Check if user_data is a map field
          if (data['user_data'] is Map) {
            final userData = data['user_data'] as Map<String, dynamic>;
            final rawRole = userData['role']?.toString();
            final role = _normalizeRole(rawRole);
            if (role == 'job_seeker') {
              print('RoleService: Found job_seeker role in user_data map (raw: $rawRole, normalized: $role)');
              return 'job_seeker';
            }
          }

          // Check if role is directly on the document
          final directRole = _normalizeRole(data['role']?.toString());
          if (directRole == 'job_seeker') {
            print('RoleService: Found job_seeker role directly on document');
            return 'job_seeker';
          }

          // If document exists under job_seeker collection, assume job_seeker
          print('RoleService: Document exists in job_seeker collection, assuming job_seeker role');
          return 'job_seeker';
        }
      }
    } catch (e) {
      print('RoleService: Job seeker collection check failed: $e');
    }
    return null;
  }

  /// Query users collection with auto-generated IDs
  /// Structure: users/{autoId} -> { uid, role, email, name }
  static Future<String?> _checkUsersCollection(String uid) async {
    try {
      print('RoleService: Querying users collection for uid: $uid');
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final rawRole = data['role']?.toString();
        final role = _normalizeRole(rawRole);

        if (role != null) {
          print('RoleService: Found role in users collection (raw: $rawRole, normalized: $role)');
          return role;
        }
      }
    } catch (e) {
      print('RoleService: Users collection query failed: $e');
    }
    return null;
  }

  /// Cache the role for performance
  static void _cacheRole(String uid, String role) {
    _roleCache[uid] = role;
    _cacheTimestamps[uid] = DateTime.now();
    print('RoleService: Cached role for $uid: $role');
  }
}

/// AuthNotifier: Manages authentication state and role resolution
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  String? userRole;
  bool roleResolved = false;
  bool _isResolving = false;

  AuthNotifier() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _resolveRoleFor(currentUser.uid);
    } else {
      roleResolved = true;
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_isResolving) return; // Prevent concurrent resolutions

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
    print('AuthNotifier: Resolving role for $uid');

    try {
      userRole = await RoleService.getUserRole(uid);

      // Retry once if role is null (handle transient network issues)
      if (userRole == null) {
        print('AuthNotifier: First attempt returned null, retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
        userRole = await RoleService.getUserRole(uid);
      }

      if (userRole == null) {
        print('AuthNotifier: Role resolution failed, signing out user');
        // Sign out user if no role found (prevents unauthorized access)
        try {
          await _auth.signOut();
        } catch (e) {
          print('AuthNotifier: Sign out failed: $e');
        }
      } else {
        print('AuthNotifier: Role resolved successfully: $userRole');
      }

    } catch (e, st) {
      print('AuthNotifier: Role resolution error: $e');
      print('Stack trace: $st');
      userRole = null;
    } finally {
      roleResolved = true;
    }
  }

  /// Force refresh role (useful after profile updates)
  Future<void> refreshRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      RoleService.clearCache();
      roleResolved = false;
      notifyListeners();
      await _resolveRoleFor(user.uid);
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

// Shared auth notifier instance
final _authNotifier = AuthNotifier();

/// Path categorization helpers
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
      p.startsWith('/saved');
}

bool _isPublicPath(String? path) {
  if (path == null) return false;
  return ['/', '/login', '/register', '/recover-password'].contains(path);
}

/// Animated page transition
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
        child: ScaleTransition(scale: scaleAnimation, child: child),
      );
    },
  );
}

/// Main router with enhanced role-based access control
final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,

  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final role = _authNotifier.userRole;
    final roleResolved = _authNotifier.roleResolved;
    final location = state.uri.toString();

    print('Router redirect: location=$location, loggedIn=$isLoggedIn, role=$role, resolved=$roleResolved');

    // Public paths accessible to everyone
    if (_isPublicPath(location)) {
      // If logged in with resolved role, redirect to appropriate dashboard
      if (isLoggedIn && roleResolved && role != null) {
        return role == 'recruiter' ? '/recruiter-dashboard' : '/dashboard';
      }
      return null; // Allow access to public pages
    }

    // Not logged in - redirect to splash/login
    if (!isLoggedIn) {
      return '/';
    }

    // Logged in but role not resolved yet - wait
    if (!roleResolved) {
      print('Router: Role not resolved yet, waiting...');
      return null;
    }

    // Logged in, role resolved but is null - redirect to login
    if (role == null) {
      print('Router: Role is null, redirecting to login');
      return '/login';
    }

    // Role-based access control
    if (role == 'recruiter') {
      if (_isJobSeekerPath(location)) {
        print('Router: Recruiter trying to access job seeker path, redirecting');
        return '/recruiter-dashboard';
      }
    } else if (role == 'job_seeker') {
      if (_isRecruiterPath(location)) {
        print('Router: Job seeker trying to access recruiter path, redirecting');
        return '/dashboard';
      }
    }

    return null; // Allow access
  },

  routes: <GoRoute>[
    // Public routes
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

    // Job Seeker routes
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const JobSeekerDashboard(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const ProfileScreen(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/saved',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: ListAppliedJobsScreen(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/download-cv',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const CVGeneratorDialog(),
        context: context,
        state: state,
      ),
    ),

    // Recruiter routes
    GoRoute(
      path: '/recruiter-dashboard',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const RecruiterDashboard(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/job-posting',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const JobPostingScreen(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/view-applications',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const ApplicantsScreen(),
        context: context,
        state: state,
      ),
    ),
  ],
);