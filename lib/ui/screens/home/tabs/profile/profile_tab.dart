import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../services/auth_service.dart';
import '../../../../shared/extensions/build_context.dart';
import '../../../../shared/theme/palette.dart';
import '../../../auth/auth_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const CircleAvatar(radius: 50),
              const SizedBox(height: 10),
              const Text(
                'username',
                textAlign: TextAlign.center,
              ),
              Text(
                'email',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: Palette.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  AuthService(FirebaseAuth.instance).logout().whenComplete(
                      () => context.pushNamedAndRemoveUntil(AuthScreen.route));
                },
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
      ),
    );
  }
}
