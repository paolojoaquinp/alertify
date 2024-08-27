import 'package:alertify/core/typedefs.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../../entities/friendship.dart';
import '../../../services/auth_service.dart';
import '../../../services/friendship_service.dart';
import '../../shared/validators/form_validator.dart';
import '../../shared/widgets/user_list.dart';
import '../../shared/widgets/user_tile.dart';
import '../home/tabs/requests/widgets/request_tile.dart';
import 'widgets/app_bar.dart';

// Inicial, Buscando , Resultados, y uno mas
sealed class SearchState {}

class SearchLoadingState extends SearchState {}

class SearchLoadedState extends SearchState {
  SearchLoadedState({required this.data});

  final List<FriendshipData> data;
}

class SearchLoadErrorState extends SearchState {
  SearchLoadErrorState({required this.error});

  final String error;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String route = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchState state = SearchLoadingState();
  final friendshipsService = FriendshipService(FirebaseFirestore.instance);
  final userId = AuthService(FirebaseAuth.instance).currentUserId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => loadFriendshipRequest(),
    );
    super.initState();
  }

  Future<void> loadFriendshipRequest() async {
    state = SearchLoadingState();
    setState(() {});
    final result = await friendshipsService.getFriendshipRequest(userId);
    state = switch (result) {
      Success(value: final requests) => SearchLoadedState(data: requests),
      Error(value: final failure) =>
          SearchLoadErrorState(
            error: failure.message,
          )
    };
    setState(() {});
  }

  Future<void> searchUser(String email) async {
    state = SearchLoadingState();
    setState(() {});
    final result = await friendshipsService.searchUser(userId, email);
    state = switch (result) {
      Success(value: final friendshipData) =>
          SearchLoadedState(data: [friendshipData]),
      Error(value: final failure) =>
          SearchLoadErrorState(error: failure.message),
    };
    setState(() {});
  }

  Future<void> sendFriendship(FriendshipData friendshipData) async {
    final result = await showLoader(
      context,
      friendshipsService.sendFriendshipRequest(
        sender: userId,
        receiverId: friendshipData.user.id,
      ),
    );
    final friendshipsData = switch (result) {
      Success(value: final friendship) =>
          addNewData(friendship, friendshipData),
      Error() => data,
    };
    state = SearchLoadedState(data: friendshipsData);
    setState(() {});
  }

  Future<void> cancelFriendship(FriendshipData friendshipData) async {
    final friendship = friendshipData.friendships!;
    final result = await showLoader(
      context,
      friendshipsService.cancelFriendshipService(friendship.id),
    );
    final friendshipsData = switch (result) {
      Success() =>
          addNewData(Friendship(
            id: friendship.id,
            status: FriendshipStatus.archived,
            createdAt: friendship.createdAt,
            updatedAt: DateTime.now(),
            sender: friendship.sender,
            users: friendship.users,
          ), friendshipData,),
      Error() => data,
    };
    state = SearchLoadedState(data: friendshipsData);
    setState(() {});
  }

  List<FriendshipData> addNewData(Friendship friendship,
      FriendshipData friendshipData,) {
    final friendshipsData = [...data];
    final index =
    friendshipsData.indexWhere((f) => f.user.id == friendshipData.user.id);
    if (index != -1) {
      friendshipsData[index] = (
      user: friendshipsData[index].user,
      friendships: friendship,
      );
    }
    return [];
  }

  List<FriendshipData> get data =>
      switch (state) {
        SearchLoadedState(data: final data) => data,
        _ => [],
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(onSearch: (email) {
        if (email.isEmpty) {
          loadFriendshipRequest();
        }
        if (FormValidator.email(email) == null) {
          searchUser(email);
        }
      }),
      body: switch (state) {
        SearchLoadingState() =>
        const Center(
          child: CircularProgressIndicator(),
        ),
        SearchLoadedState(data: final data) =>
            UserList(
              data: data,
              builder: (_, friendshipData) {
                final user = friendshipData.user;
                final friendship = friendshipData.friendships;
                final status = friendship?.status;
                return switch (status) {
                  null || FriendshipStatus.archived =>
                      UserTile(
                        // TODO(any): add method for sent friendship
                        onPressed: () => sendFriendship(friendshipData),
                        username: user.username,
                        email: user.email,
                        trailingIcon: Icons.person_add_alt_1_rounded,
                      ),
                  FriendshipStatus.pending when friendship?.sender == userId =>
                      UserTile(
                        // TODO(any): add method to cancel frindship
                        onPressed: () => cancelFriendship(friendshipData),
                        username: user.username,
                        email: user.email,
                        trailingIcon: Icons.person_remove_alt_1_rounded,
                      ),
                  FriendshipStatus.pending =>
                      RequestTile(
                        // TODO(any): add method for sent friendship
                        onAccept: () {},
                        // TODO(any): add method for cancel friendship
                        onReject: () {},
                        username: user.username,
                        email: user.email,
                        photoUrl: user.photoUrl,
                      ),
                  FriendshipStatus.active =>
                      UserTile(
                        // TODO(any): add method for delete friend
                        onPressed: () {},
                        username: friendshipData.user.username,
                        email: friendshipData.user.email,
                      ),
                  _ =>
                      UserTile(
                        onPressed: () {},
                        username: friendshipData.user.username,
                        email: friendshipData.user.email,
                      )
                };
              },
            ),
        SearchLoadErrorState(error: final error) =>
            Center(
              child: Text(error),
            ),
      },
    );
  }
}
