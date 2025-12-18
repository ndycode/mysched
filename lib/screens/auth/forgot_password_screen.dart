// coverage:ignore-file
import 'package:flutter/material.dart';

import '../../ui/kit/kit.dart';
import 'forgot_password_sheet.dart';

/// Arguments for navigating to the forgot password screen.
class ForgotPasswordScreenArgs {
  const ForgotPasswordScreenArgs({this.email});

  /// Pre-fill the email field if known.
  final String? email;
}

/// Shows the [ForgotPasswordSheet] modal via [AppModal.sheet].
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  /// Pre-fill the email field if known.
  final String? initialEmail;

  /// Shows the forgot password sheet and returns true if email was sent.
  static Future<bool?> show(BuildContext context, {String? email}) {
    return AppModal.sheet<bool>(
      context: context,
      builder: (_) => ForgotPasswordSheet(initialEmail: email),
    );
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ForgotPasswordScreen.show(
        context,
        email: widget.initialEmail,
      );
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Transparent placeholder - AppModal.sheet provides its own barrier.
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
