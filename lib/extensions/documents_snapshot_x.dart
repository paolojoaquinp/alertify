import '../core/typedefs.dart';
import '../entities/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension DocumentsSnapshotX on DocumentSnapshot<Json> {
  AppUser toAppUser() {
    return AppUser(
      id: id,
      email: this['email'],
      username: this['username'],
      photoUrl: this['photoUrl'],
    );
  }
}