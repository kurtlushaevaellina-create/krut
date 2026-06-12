import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/ui/auth/form/login_form.dart';
import 'package:track_dev/ui/auth/section/login_header_section.dart';
import 'package:track_dev/ui/auth/settings/auth_settings_sheet.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LoginLayout(
      settingsButton: IconButton(
        icon: const Icon(Icons.settings_outlined),
        tooltip: 'Настройки авторизации',
        onPressed: () => showAuthSettingsSheet(context),
      ),
      headerSection: const LoginHeaderSection(),
      formSection: const LoginForm(),
    );
  }
}

class _LoginLayout extends StatelessWidget {
  const _LoginLayout({
    required this.settingsButton,
    required this.headerSection,
    required this.formSection,
  });

  final Widget settingsButton;
  final Widget headerSection;
  final Widget formSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: settingsButton,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerSection,
                    const SizedBox(height: 48),
                    formSection,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
