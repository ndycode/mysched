part of 'reminders_screen.dart';

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);
    return CardX(
      backgroundColor: cardBackground,
      borderColor: borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (primaryLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.radius.xl,
                ),
              ),
              child: Text(primaryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.onEdit,
    required this.onSnooze,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onSnooze;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.more_vert_rounded, color: colors.onSurfaceVariant),
      tooltip: 'More actions',
      onPressed: () => _showMenu(context),
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final button = context.findRenderObject() is RenderBox
        ? context.findRenderObject() as RenderBox
        : null;
    final overlayRender = Overlay.maybeOf(context)?.context.findRenderObject();
    if (button == null || overlayRender is! RenderBox) {
      final fallback = await _showMenuAtPosition(
        context: context,
        position: const RelativeRect.fromLTRB(200, 200, 16, 0),
      );
      _handleAction(fallback);
      return;
    }

    final buttonOffset =
        button.localToGlobal(Offset.zero, ancestor: overlayRender);
    final rect = RelativeRect.fromRect(
      Rect.fromLTWH(
        buttonOffset.dx,
        buttonOffset.dy,
        button.size.width,
        button.size.height,
      ),
      Offset.zero & overlayRender.size,
    );

    final action = await _showMenuAtPosition(
      context: context,
      position: rect,
    );
    _handleAction(action);
  }

  Future<_ReminderRowAction?> _showMenuAtPosition({
    required BuildContext context,
    required RelativeRect position,
  }) {
    final colors = Theme.of(context).colorScheme;
    return showMenu<_ReminderRowAction>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.md,
      ),
      items: [
        PopupMenuItem(
          value: _ReminderRowAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: colors.onSurface),
              const SizedBox(width: 12),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ReminderRowAction.snooze,
          child: Row(
            children: [
              Icon(Icons.snooze_outlined, size: 18, color: colors.onSurface),
              const SizedBox(width: 12),
              const Text('Snooze'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ReminderRowAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: colors.error.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 12),
              const Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAction(_ReminderRowAction? action) {
    switch (action) {
      case _ReminderRowAction.edit:
        onEdit();
        break;
      case _ReminderRowAction.snooze:
        onSnooze();
        break;
      case _ReminderRowAction.delete:
        onDelete();
        break;
      case null:
        break;
    }
  }
}

class _ReminderActionsSheet extends StatelessWidget {
  const _ReminderActionsSheet({required this.entry});

  final ReminderEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            entry.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'SFProRounded',
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit reminder'),
            onTap: () => Navigator.of(context).pop(_ReminderRowAction.edit),
          ),
          ListTile(
            leading: const Icon(Icons.snooze_outlined),
            title: const Text('Snooze'),
            onTap: () => Navigator.of(context).pop(_ReminderRowAction.snooze),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete'),
            onTap: () => Navigator.of(context).pop(_ReminderRowAction.delete),
          ),
        ],
      ),
    );
  }
}

class _SnoozeSheet extends StatelessWidget {
  const _SnoozeSheet({required this.entry, required this.formatDue});

  final ReminderEntry entry;
  final String Function(DateTime due) formatDue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = <Duration, String>{
      const Duration(minutes: 5): 'In 5 minutes',
      const Duration(minutes: 15): 'In 15 minutes',
      const Duration(minutes: 30): 'In 30 minutes',
      const Duration(hours: 1): 'In 1 hour',
      const Duration(hours: 3): 'In 3 hours',
      const Duration(hours: 6): 'In 6 hours',
      const Duration(days: 1): 'Tomorrow',
    };

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Snooze reminder',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'SFProRounded',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(entry.title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'Current time: ${formatDue(entry.dueAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...options.entries.map(
            (option) => ListTile(
              leading: const Icon(Icons.snooze_outlined),
              title: Text(option.value),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).pop(option.key),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ReminderRowAction { edit, snooze, delete }
