import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/auth_session.dart';
import 'package:track_dev/providers/sources_provider.dart';

Future<void> showAuthSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const AuthSettingsSheet(),
  );
}

class AuthSettingsSheet extends HookConsumerWidget {
  const AuthSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = useState<AuthMethod?>(null);
    final loading = useState(true);

    useEffect(() {
      Future.microtask(() async {
        final prefs = ref.read(preferencesRepositoryProvider);
        final saved = await prefs.getAuthMethod();
        if (context.mounted) {
          selected.value = saved;
          loading.value = false;
        }
      });
      return null;
    }, const []);

    Future<void> save() async {
      final method = selected.value;
      if (method == null) return;

      final prefs = ref.read(preferencesRepositoryProvider);
      await prefs.setAuthMethod(method);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.security, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Способ авторизации',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Выберите предпочтительный метод аутентификации для подключения к Redmine:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (loading.value)
            const Center(child: CircularProgressIndicator())
          else
            RadioGroup<AuthMethod>(
              groupValue: selected.value,
              onChanged: (value) => selected.value = value,
              child: Column(
                children: [
                  RadioListTile<AuthMethod>(
                    title: const Text('Логин и пароль (Basic Auth)'),
                    subtitle: const Text('Стандартный вход'),
                    value: AuthMethod.basic,
                  ),
                  RadioListTile<AuthMethod>(
                    title: const Text('Ключ API (API Token)'),
                    subtitle: const Text('Для повышенной безопасности'),
                    value: AuthMethod.apiKey,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: loading.value ? null : save,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
