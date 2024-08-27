import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../services/auth_service.dart';
import '../../../../../services/friendship_service.dart';
import '../../../../shared/extensions/build_context.dart';
import '../../../../shared/widgets/user_list.dart';
import 'widgets/app_bar.dart';
import 'widgets/request_tile.dart';

sealed class RequestState {
  const RequestState();
}

class RequestLoadingState extends RequestState {
  const RequestLoadingState();
}

class RequestLoadedState extends RequestState {
  final List<FriendshipData> requests;

  RequestLoadedState({required this.requests});
}

class RequestLoadErrorState extends RequestState {
  RequestLoadErrorState({required this.error});

  final String error;
}

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  RequestState state = const RequestLoadingState();
  final friendshipsService = FriendshipService(FirebaseFirestore.instance);
  final userId = AuthService(FirebaseAuth.instance).currentUserId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loadRequest());
    super.initState();
  }

  Future<void> loadRequest() async {
    state = const RequestLoadingState();
    setState(() {});
    final result = await friendshipsService.getFriendshipRequest(userId);
    state = switch (result) {
      Success(value: final requests) => RequestLoadedState(requests: requests),
      Error(value: final failure) =>
        RequestLoadErrorState(error: failure.message),
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          const RequestsAppBar(),
          Expanded(
            child: switch (state) {
              RequestLoadingState() => Center(
                  child: CircularProgressIndicator(),
                ),
              RequestLoadedState(requests: final requests)
                  when requests.isEmpty =>
                const Center(
                  child: Text('No tienes solicitudes pendientes'),
                ),
              RequestLoadedState(requests: final requests) => UserList(
                  data: requests,
                  builder: (_, request) {
                    return RequestTile(
                      onAccept: () {},
                      onReject: () {},
                      username: request.user.username,
                      email: request.user.email,
                      photoUrl: request.user.photoUrl,
                    );
                  },
                ),
              RequestLoadErrorState(error: final error) => Center(
                  child: Text(
                    error,
                  ),
                )
            },
          ),
        ],
      ),
    );
  }
}
