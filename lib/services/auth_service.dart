import 'package:alertify/core/typedefs.dart';
import 'package:alertify/failures/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/result.dart';

extension type AuthService(FirebaseAuth auth) {
  FutureAuthResult<void, SignInAuthFailure> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if(user != null) {
        return Success(null); // OK
      }
      return Error(SignInAuthFailure.userNotFound);
    } on FirebaseAuthException catch (e) {
      return Error(SignInAuthFailure.values.firstWhere(
        (failure) => failure.code == e.code ,
        orElse: () => SignInAuthFailure.unknown,
      ));
    } catch (_) {
      return Error(SignInAuthFailure.unknown);
    }
  }

  bool get logged => auth.currentUser != null;
}
