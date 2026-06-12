import 'package:flutter/material.dart';
import 'package:track_dev/providers/input_validator_provider.dart';

class ServerField extends StatelessWidget {
  const ServerField({
    super.key,
    required this.controller,
    required this.validationState,
    this.errorText,
  });

  final TextEditingController controller;
  final ValidationState validationState;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: 'Адрес сервера Redmine',
        hintText: 'https://demo.redmine.org',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.dns_outlined),
        suffixIcon: _buildSuffix(),
        errorText: errorText,
      ),
    );
  }

  Widget? _buildSuffix() {
    if (controller.text.isEmpty) {
      return null;
    }

    return switch (validationState) {
      ValidationLoading() => const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      ValidationSuccess() => const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
      ),
      ValidationError(message: _) => const Icon(
        Icons.error_rounded,
        color: Colors.redAccent,
      ),
      ValidationIdle() => null,
    };
  }
}
