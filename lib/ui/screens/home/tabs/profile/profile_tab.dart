import 'package:alertify/ui/shared/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/build_context.dart';
import 'controller/profile_tab_controller.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  // ProfileState state = ProfileLoadingState();
  // final authService = AuthService(FirebaseAuth.instance);
  // final userService = UserService(FirebaseFirestore.instance);
  // late final currentUserId = authService.currentUserId;

  // void logout() async {
  //   authService.logout().whenComplete(
  //           () => context.pushNamedAndRemoveUntil(AuthScreen.route));
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(profileDataProvider);
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: profileData.when(
          data: (user) => Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                const CircleAvatar(radius: 50),
                const SizedBox(height: 10),
                Text(
                  user.username,
                  textAlign: TextAlign.center,
                ),
                Text(
                  user.email,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Palette.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.darkGray,
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Palette.pink),
                  ),
                ),
              ],
            ),
          ),
          error: (_, __) => const Center(
            child: Text('Oops you have an error'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
