// coverage:ignore-file
// lib/screens/change_password_page.dart
import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import 'change_password_sheet.dart';

/// Shows the [ChangePasswordSheet] modal via [AppModal.sheet].
/// Use [ChangePasswordPage.show] for direct invocation.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  /// Shows the change password sheet and returns 	rue if password was updated.
  static Future<bool?> show(BuildContext context) {
    return AppModal.sheet<bool>(
      context: context,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ChangePasswordPage.show(context);
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
