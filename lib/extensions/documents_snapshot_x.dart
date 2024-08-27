import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/friendship.dart';

extension DocumentsSnapshotX on DocumentSnapshot<Json> {
  AppUser toAppUser() {
    return AppUser(
      id: id,
      email: this['email'],
      username: this['username'],
      photoUrl: this['photoUrl'],
    );
  }

  Friendship toFriendship() {
    return Friendship(
      id: id,
      status: FriendshipStatus.values.firstWhere(
        (element) => element.name == this['status'],
        orElse: () => FriendshipStatus.archived,
      ),
      createdAt: DateTime.parse(this['createdAt']),
      updatedAt: DateTime.parse(this['updatedAt']),
      sender: this['sender'],
      users: (this['users'] as List).map((elem) => elem.toString()).toList(),
    );
  }
}
