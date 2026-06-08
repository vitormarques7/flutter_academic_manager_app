import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../repositories/user_profile_repository.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    UserProfileRepository? userProfileRepository,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']),
       _userProfileRepository =
           userProfileRepository ??
           UserProfileRepository(firebaseAuth: firebaseAuth);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserProfileRepository _userProfileRepository;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isGoogleSignInSupported {
    if (kIsWeb) return true;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _ensureUserDocument(credential);
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } on UserProfileRepositoryException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final displayName = name.trim();
      if (displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      await _ensureUserDocument(
        credential,
        displayName: displayName,
        email: email,
      );

      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } on UserProfileRepositoryException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (!isGoogleSignInSupported) {
      throw const AuthException(
        'Login com Google não está disponível nesta plataforma.',
      );
    }

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        final credential = await _firebaseAuth.signInWithPopup(provider);
        await _ensureUserDocument(credential);
        return credential;
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      await _ensureUserDocument(userCredential);
      return userCredential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } on UserProfileRepositoryException catch (error) {
      throw AuthException(error.message);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Não foi possível entrar com Google. Tente novamente.',
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();

      if (isGoogleSignInSupported && !kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      throw const AuthException(
        'Não foi possível sair da conta. Tente novamente.',
      );
    }
  }

  Future<void> ensureCurrentUserDocument() {
    final user = currentUser;

    return _userProfileRepository.ensureCurrentUserDocument(
      displayName: user?.displayName,
      email: user?.email,
    );
  }

  Future<void> _ensureUserDocument(
    UserCredential credential, {
    String? displayName,
    String? email,
  }) {
    final user = credential.user;

    return _userProfileRepository.ensureCurrentUserDocument(
      displayName: displayName ?? user?.displayName,
      email: email ?? user?.email,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    return switch (error.code) {
      'account-exists-with-different-credential' =>
        'Já existe uma conta com este e-mail usando outro método de login.',
      'credential-already-in-use' =>
        'Esta credencial já está vinculada a outra conta.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'invalid-credential' => 'E-mail ou senha inválidos.',
      'invalid-email' => 'Informe um e-mail válido.',
      'network-request-failed' =>
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      'operation-not-allowed' =>
        'Este método de login não está habilitado no Firebase.',
      'popup-blocked' =>
        'O navegador bloqueou a janela de login. Libere pop-ups e tente novamente.',
      'popup-closed-by-user' => 'Login com Google cancelado.',
      'requires-recent-login' =>
        'Por segurança, entre novamente para continuar.',
      'too-many-requests' =>
        'Muitas tentativas em pouco tempo. Aguarde alguns minutos.',
      'user-disabled' => 'Esta conta foi desativada.',
      'user-not-found' => 'Não encontramos uma conta com este e-mail.',
      'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
      'wrong-password' => 'Senha incorreta.',
      _ => error.message ?? 'Não foi possível autenticar. Tente novamente.',
    };
  }
}
