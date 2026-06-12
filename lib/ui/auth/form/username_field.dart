import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
  const UsernameField({
    super.key,
    required this.controller,
    this.errorText,
  });

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Имя пользователя',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        errorText: errorText,
      ),
    );
  }
}
