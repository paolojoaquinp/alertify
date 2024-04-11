import 'package:firebase_auth/firebase_auth.dart';

import '../core/typedefs.dart';
import '../failures/auth_failure.dart';

extension type AuthService(FirebaseAuth auth,) {
  FutureAuthResult<void, SignInAuthFailure> signIn({
    required String email,
    required String password
  }) async {
    try {

    } catch (e) {
      return Error(SignInAuthFailure.unknown);
    }
  }
}

