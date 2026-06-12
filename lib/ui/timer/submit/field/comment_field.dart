import 'package:flutter/material.dart';

class CommentField extends StatelessWidget {
  const CommentField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.commentLength,
    required this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int commentLength;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          maxLength: 255,
          maxLines: 4,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'Комментарий',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$commentLength/255',
            style: theme.textTheme.bodySmall?.copyWith(
              color: commentLength >= 255
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
