import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/repository/auth.dart';
import 'package:track_dev/providers/auth_provider.dart';
import 'package:track_dev/providers/input_validator_provider.dart';
import 'package:track_dev/ui/auth/form/password_field.dart';
import 'package:track_dev/ui/auth/form/server_field.dart';
import 'package:track_dev/ui/auth/form/submit_button.dart';
import 'package:track_dev/ui/auth/form/username_field.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverController = useTextEditingController();
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();

    final serverValidationState = ref.watch(servernameValidationProvider);
    final serverValidationError = useState<String?>(null);
    final usernameValidationError = useState<String?>(null);
    final passwordValidationError = useState<String?>(null);
    final submitFailed = useState<bool>(false);
    final isSubmitting = useState<bool>(false);

    useEffect(() {
      Future.microtask(() async {
        final notifier = ref.read(authStateProvider.notifier);
        final lastUsername = await notifier.lastLoggedUsername() ?? '';
        final savedServer = await notifier.lastLoggedServername() ?? '';

        if (context.mounted) {
          usernameController.text = lastUsername;
          serverController.text = savedServer;
        }
      });

      return null;
    }, const []);

    useEffect(() {
      void listener() {
        if (serverValidationError.value != null) {
          serverValidationError.value = null;
        }

        final validator = ref.read(servernameValidationProvider.notifier);
        validator.validate(serverController.text);
      }

      serverController.addListener(listener);
      return () => serverController.removeListener(listener);
    }, [serverController]);

    String? getServerErrorText() {
      if (serverValidationError.value != null) {
        return serverValidationError.value;
      }

      if (serverValidationState is ValidationError) {
        return serverValidationState.message;
      }

      return null;
    }

    useEffect(() {
      void listener() {
        if (usernameValidationError.value != null) {
          usernameValidationError.value = null;
        }
      }

      usernameController.addListener(listener);
      return () => usernameController.removeListener(listener);
    }, [usernameController]);

    useEffect(() {
      void listener() {
        if (passwordValidationError.value != null) {
          passwordValidationError.value = null;
        }
        if (submitFailed.value) {
          submitFailed.value = false;
        }
      }

      passwordController.addListener(listener);
      return () => passwordController.removeListener(listener);
    }, [passwordController]);

    Future<void> submit() async {
      FocusScope.of(context).unfocus();

      final server = serverController.text.trim();
      final username = usernameController.text.trim();
      final password = passwordController.text;

      var isValid = true;
      if (server.isEmpty) {
        serverValidationError.value = 'Адрес сервера не может быть пустым';
        isValid = false;
      }
      if (username.isEmpty) {
        usernameValidationError.value = 'Имя пользователя не может быть пустым';
        isValid = false;
      }
      if (password.isEmpty) {
        passwordValidationError.value = 'Пароль не может быть пустым';
        isValid = false;
      }

      if (!isValid) return;

      isSubmitting.value = true;
      submitFailed.value = false;

      try {
        await ref.read(authStateProvider.notifier).logIn(server, username, password);
      } on AuthException catch (e) {
        submitFailed.value = true;

        switch (e.kind) {
          case UserNotFoundErrorKind():
            usernameValidationError.value = e.message;
          case IncorrectPasswordErrorKind():
            passwordValidationError.value = e.message;
          default:
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
        }
      } catch (e) {
        submitFailed.value = true;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Произошла неизвестная ошибка: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServerField(
          controller: serverController,
          validationState: serverValidationState,
          errorText: getServerErrorText(),
        ),
        const SizedBox(height: 18),
        UsernameField(
          controller: usernameController,
          errorText: usernameValidationError.value,
        ),
        const SizedBox(height: 18),
        PasswordField(
          controller: passwordController,
          errorText: passwordValidationError.value,
          onSubmitted: submit,
        ),
        const SizedBox(height: 32),
        LoginSubmitButton(
          onPressed: isSubmitting.value ? null : submit,
          isSubmitting: isSubmitting.value,
          submitFailed: submitFailed.value,
        ),
      ],
    );
  }
}
