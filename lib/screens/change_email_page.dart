// coverage:ignore-file
// lib/screens/change_email_page.dart
import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import 'change_email_sheet.dart';

class ChangeEmailPageArgs {
  const ChangeEmailPageArgs({required this.currentEmail});

  final String currentEmail;
}

/// Shows the [ChangeEmailSheet] modal via [AppModal.sheet].
/// Use [ChangeEmailPage.show] for direct invocation.
class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key, required this.currentEmail});

  final String currentEmail;

  /// Shows the change email sheet and returns `true` if the email was updated.
  static Future<bool?> show(
    BuildContext context, {
    required String currentEmail,
  }) {
    return AppModal.sheet<bool>(
      context: context,
      builder: (_) => ChangeEmailSheet(currentEmail: currentEmail),
    );
  }

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ChangeEmailPage.show(
        context,
        currentEmail: widget.currentEmail,
      );
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder while the sheet opens.
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
