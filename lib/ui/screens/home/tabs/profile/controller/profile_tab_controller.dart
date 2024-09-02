import 'package:alertify/core/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../services/auth_service.dart';
import '../../../../../../services/user_service.dart';

final profileDataProvider = FutureProvider.autoDispose(
  (ref) async {
    final authService = AuthService(FirebaseAuth.instance);
    final currentUserId = authService.currentUserId;

    final userService = UserService(FirebaseFirestore.instance);
    final result = await userService.userFromId(currentUserId);

    return switch (result) {
      Success(value: final user) => user,
      Error(value: final failure) => throw Exception(failure.message),
    };});
