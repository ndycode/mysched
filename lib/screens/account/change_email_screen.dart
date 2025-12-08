// coverage:ignore-file
import 'package:flutter/material.dart';

import '../../ui/kit/kit.dart';
import 'change_email_sheet.dart';

class ChangeEmailScreenArgs {
  const ChangeEmailScreenArgs({required this.currentEmail});

  final String currentEmail;
}

/// Shows the [ChangeEmailSheet] modal via [AppModal.sheet].
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key, required this.currentEmail});

  final String currentEmail;

  /// Shows the change email sheet and returns true if the email was updated.
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
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ChangeEmailScreen.show(
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
