// coverage:ignore-file
import 'package:flutter/material.dart';

import '../../ui/kit/kit.dart';
import 'verify_email_sheet.dart';

// Re-export for backward compatibility
export 'verify_email_sheet.dart' show VerificationIntent;

class VerifyEmailScreenArgs {
  const VerifyEmailScreenArgs({
    required this.email,
    this.intent = VerificationIntent.signup,
    this.fromLogin = false,
    this.onVerified,
  });

  final String email;
  final VerificationIntent intent;
  final bool fromLogin;
  final VoidCallback? onVerified;
}

/// Shows the [VerifyEmailSheet] modal via [AppModal.sheet].
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.intent = VerificationIntent.signup,
    this.fromLogin = false,
    this.onVerified,
  });

  final String email;
  final VerificationIntent intent;
  final bool fromLogin;
  final VoidCallback? onVerified;

  /// Shows the verify email sheet and returns true if verified.
  static Future<bool?> show(
    BuildContext context, {
    required String email,
    VerificationIntent intent = VerificationIntent.signup,
    bool fromLogin = false,
    VoidCallback? onVerified,
  }) {
    return AppModal.sheet<bool>(
      context: context,
      dismissible: false,
      builder: (_) => VerifyEmailSheet(
        email: email,
        intent: intent,
        fromLogin: fromLogin,
        onVerified: onVerified,
      ),
    );
  }

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await VerifyEmailScreen.show(
        context,
        email: widget.email,
        intent: widget.intent,
        fromLogin: widget.fromLogin,
        onVerified: widget.onVerified,
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
