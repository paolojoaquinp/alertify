import '../core/result.dart';
import '../core/typedefs.dart';
import '../entities/app_user.dart';
import '../failures/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../extensions/documents_snapshot_x.dart';

extension type UserService(FirebaseFirestore db) {
  CollectionReference<Json> get _collection => db.collection('users');

  FutureResult<AppUser> userFromId(String id) async {
    try {
      final snapshot = await _collection.doc(id).get();
      if (!snapshot.exists) {
        return Error(Failure(message: 'User not found'));
      }
      return Success(snapshot.toAppUser());
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  FutureResult<AppUser> createUser({
    required String id,
    required String username,
    required String email,
    String? photoUrl,
  }) async {
    await _collection.doc(id).set({
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
    });
    return Success(
      AppUser(
        id: id,
        username: username,
        email: email,
        photoUrl: photoUrl,
      ),
    );
  }
}
