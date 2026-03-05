import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/app_user_model.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  AppUserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromFirebaseUser(user);
  }

  Stream<AppUserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUserModel.fromFirebaseUser(user);
    });
  }

  Future<AppUserModel> signInAnonymously() async {
    try {
      final result = await _firebaseAuth.signInAnonymously();
      final user = result.user;
      if (user == null) {
        throw const ServerException('Anonymous sign-in failed');
      }
      return AppUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Anonymous sign-in failed');
    }
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) {
        throw const ServerException('Sign-in failed');
      }
      return AppUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e.code));
    }
  }

  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) {
        throw const ServerException('Registration failed');
      }
      if (displayName != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      return AppUserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e.code));
    }
  }

  Future<AppUserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const ServerException('Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw const ServerException('Google sign-in failed');
      }
      return AppUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e.code));
    }
  }

  Future<AppUserModel> linkAnonymousToEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        throw const ServerException('No anonymous user to link');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final result = await currentUser.linkWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw const ServerException('Account linking failed');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      return AppUserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e.code));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Sign-out failed');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'credential-already-in-use':
        return 'This credential is already linked to another account';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
