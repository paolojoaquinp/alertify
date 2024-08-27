import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../core/result.dart';
import '../../../../../core/typedefs.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/friendship_service.dart';
import '../../../../shared/extensions/build_context.dart';
import '../../../../shared/widgets/user_list.dart';
import '../../../../shared/widgets/user_tile.dart';
import '../../../search/search_screen.dart';
import 'widgets/app_bar.dart';

sealed class FriendsState {
  const FriendsState();
}

class FriendsLoadingState extends FriendsState {}

class FriendsLoadedState extends FriendsState {
  FriendsLoadedState({required this.friends});

  final List<FriendshipData> friends;
}

class FriendsLoadErrorState extends FriendsState {
  FriendsLoadErrorState({required this.error});

  final String error;
}

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  FriendsState state = FriendsLoadingState();
  final friendshipsService = FriendshipService(FirebaseFirestore.instance);
  final userId = AuthService(FirebaseAuth.instance).currentUserId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loadFriends());
    super.initState();
  }

  Future<void> loadFriends() async {
    state = FriendsLoadingState();
    setState(() {});
    final result = await friendshipsService.getFriends(userId);
    state = switch (result) {
      Success(value: final friends) => FriendsLoadedState(friends: friends),
      Error(value: final failure) => FriendsLoadErrorState(
          error: failure.message,
        ),
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          FriendsAppbar(onAdd: () => context.pushNamed(SearchScreen.route)),
          Expanded(
            child: switch (state) {
              FriendsLoadingState() => const Center(
                  child: CircularProgressIndicator(),
                ),
              FriendsLoadedState(friends: final friends) when friends.isEmpty =>
                const Center(
                  child: Text(
                    'No tienes amigos....',
                  ),
                ),
              FriendsLoadedState(friends: final friends) => UserList(
                  data: friends,
                  builder: (_, friendshipData) => UserTile(
                    onPressed: () {},
                    username: friendshipData.user.username,
                    email: friendshipData.user.email,
                  ),
                ),
              FriendsLoadErrorState(error: final error) => Center(
                  child: Text(error),
                ),
            },
          ),
          // Expanded(
          //   child: UserList(
          //     data: const [1, 2, 3, 4, 5, 6, 7, 8, 9],
          //     builder: (_, data) => UserTile(
          //       onPressed: () {},
          //       username: 'username',
          //       email: 'email',
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
