import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/friendship.dart';
import 'package:alertify/failures/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/result.dart';
import '../extensions/documents_snapshot_x.dart';
import '../ui/shared/extensions/iterable_x.dart';

extension type FriendshipService(FirebaseFirestore db) {
  CollectionReference<Json> get _collection => db.collection('friendships');

  FutureResult<List<FriendshipData>> getFriends(String userId) async {
    try {
      final friendships = await _getFriendshipsIds(userId);
      if (friendships.isEmpty) {
        return Success([]);
      }
      final friendshipsIds = friendships
          .map((doc) => doc.users.firstWhere((id) => id != userId))
          .toList();
      final query = db
          .collection('users')
          .orderBy('users')
          .where('id', whereIn: friendshipsIds);

      final snapshots = await query.get();

      final users = snapshots.docs
          .where((element) => element.exists)
          .map((e) => e.toAppUser())
          .toList();
      final data = <FriendshipData>[];
      for (final user in users) {
        final friendship = friendships.firstWhereOrNull(
          (friendship) => friendship.users.contains(user.id),
        );

        data.add((friendships: friendship, user: user));
      }
      return Success(data);
    } catch (_) {
      return Error(Failure(message: _.toString()));
    }
  }

  Future<List<Friendship>> _getFriendshipsIds(String userId) async {
    try {
      final snapshots = await _collection
          .where(
            'status',
            isEqualTo: FriendshipStatus.active.name,
          )
          .where(
            'users',
            arrayContains: userId,
          )
          .get();

      return snapshots.docs.map((elem) => elem.toFriendship()).toList();
    } catch (_) {
      rethrow;
    }
  }

  FutureResult<List<FriendshipData>> getFriendshipRequest(String userId) async {
    try {
      final snapshot = await _collection
          .where(
            'status',
            isEqualTo: FriendshipStatus.pending.name,
          )
          .where('users', arrayContains: userId)
          .where('sender', isNotEqualTo: userId)
          .get();
      final friendships = snapshot.docs.map((e) => e.toFriendship()).toList();
      if (friendships.isEmpty) {
        return Success([]);
      }

      final friendshipsIds = friendships
          .map((friendship) => friendship.users.where((id) => id != userId))
          .toList();

      final userSnapshot = await db
          .collection('users')
          .where('id', arrayContains: friendshipsIds)
          .get();

      final users = userSnapshot.docs.map((doc) => doc.toAppUser()).toList();

      final data = <FriendshipData>[];
      for (final user in users) {
        final friendship = friendships.firstWhereOrNull(
          (friendship) => friendship.users.contains(user.id),
        );

        data.add((friendships: friendship, user: user));
      }
      return Success(data);
    } catch (_) {
      return Error(Failure(message: _.toString()));
    }
  }

  FutureResult<FriendshipData> searchUser(
    String userId,
    String email,
  ) async {
    try {
      final userSnapshot = await db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      final userDocs = userSnapshot.docs;
      if (userDocs.isEmpty) {
        return Error(Failure(message: 'Usuario no existe..'));
      }
      final user = userDocs.first.toAppUser();
      final friendshipSnapshot =
          await _collection.where('users', arrayContains: user.id).get();
      final friendships =
          friendshipSnapshot.docs.map((e) => e.toFriendship()).toList();
      Friendship? friendship;
      if (friendships.isNotEmpty) {
        friendship = friendships.firstWhereOrNull(
          (element) => element.users.contains(userId),
        );
      }
      return Success((friendships: friendship, user: user));
    } catch (_) {
      return Error(Failure(message: _.toString()));
    }
  }

  FutureResult<Friendship> sendFriendshipRequest({
    required String sender,
    required String receiverId,
  }) async {
    try {
      final snapshot = await _collection
          .where('users', arrayContains: receiverId)
          .where('sender', isEqualTo: sender)
          .where('status', isNotEqualTo: FriendshipStatus.archived.name)
          .limit(1)
          .get();
      final docs = snapshot.docs;
      final dateNow = DateTime.now().toIso8601String();
      final data = <String, dynamic>{
        'users': [sender, receiverId],
        'sender': sender,
        'status': FriendshipStatus.pending.name,
        'createdAt': dateNow,
        'updatedAt': dateNow,
      };
      if (docs.isEmpty) {
        final ref = await _collection.add(data);
        return Success((await ref.get()).toFriendship());
      }
      final friendship = docs.first.toFriendship();
      if ([
        FriendshipStatus.active,
        FriendshipStatus.pending,
      ].contains(
        friendship.status,
      )) {
        return Error(Failure(message: 'Solicitud ya existe'));
      }
      return Success(
        Friendship(
          id: friendship.id,
          status: friendship.status,
          createdAt: friendship.createdAt,
          updatedAt: DateTime.timestamp(),
          sender: friendship.sender,
          users: friendship.users,
        ),
      );
    } catch (_) {
      return Error(Failure(message: _.toString()));
    }
  }

  FutureResult<void> cancelFriendshipService(String friendshipId) async {
    try {
      final ref = _collection.doc(friendshipId);
      final snapshot = await ref.get();
      if (!snapshot.exists) {
        return Error(Failure(message: 'Solicitud no existe'));
      }
      await ref.set(
        {
          'status': FriendshipStatus.archived.name,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      return Success(null);
    } catch (_) {
      return Error(Failure(message: _.toString()));
    }
  }
}
