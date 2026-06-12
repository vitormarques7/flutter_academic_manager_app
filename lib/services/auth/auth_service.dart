import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<void> ensureInitialized() async {
    if (kIsWeb) {
      await _firebaseAuth.setPersistence(Persistence.LOCAL);
    }

    await _firebaseAuth.authStateChanges().first;
  }

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
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
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

      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
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
        return await _firebaseAuth.signInWithPopup(provider);
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
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
