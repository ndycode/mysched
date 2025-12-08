// coverage:ignore-file
import 'package:flutter/material.dart';

import '../../ui/kit/kit.dart';
import 'change_password_sheet.dart';

/// Shows the [ChangePasswordSheet] modal via [AppModal.sheet].
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  /// Shows the change password sheet and returns true if password was updated.
  static Future<bool?> show(BuildContext context) {
    return AppModal.sheet<bool>(
      context: context,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ChangePasswordScreen.show(context);
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
