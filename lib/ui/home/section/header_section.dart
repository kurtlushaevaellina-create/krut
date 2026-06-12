import 'package:flutter/material.dart';
import 'package:track_dev/core/models/project.dart';

class HeaderSection extends StatelessWidget {
  final String username;
  final Project? projectFilter;
  final VoidCallback onFilter;
  final VoidCallback onLogout;

  const HeaderSection({
    super.key,
    required this.username,
    required this.projectFilter,
    required this.onFilter,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _HeaderLayout(
      titleButton: IconButton(icon: Icon(Icons.logout), onPressed: onLogout),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Привет,',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      activeProjectFilter: (projectFilter == null)
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                projectFilter!.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      filterButton: IconButton(
        onPressed: onFilter,
        icon: const Icon(Icons.filter_list),
      ),
    );
  }
}

class _HeaderLayout extends StatelessWidget {
  final Widget titleButton;
  final Widget title;
  final Widget? activeProjectFilter;
  final Widget filterButton;

  const _HeaderLayout({
    required this.titleButton,
    required this.title,
    required this.activeProjectFilter,
    required this.filterButton,
  });

  @override
  Widget build(BuildContext context) {
    final projectFilter = activeProjectFilter;

    return Row(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [titleButton, title],
          ),
        ),
        if (projectFilter != null) ...[projectFilter, const SizedBox(width: 8)],
        filterButton,
      ],
    );
  }
}
