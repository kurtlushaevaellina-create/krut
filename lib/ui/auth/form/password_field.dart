import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.errorText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        labelText: 'Пароль',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        errorText: errorText,
      ),
    );
  }
}
