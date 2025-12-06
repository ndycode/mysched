// coverage:ignore-file
// lib/screens/delete_account_page.dart
import 'package:flutter/material.dart';

import '../ui/kit/kit.dart';
import 'delete_account_sheet.dart';

/// Shows the [DeleteAccountSheet] modal via [AppModal.sheet].
/// Use [DeleteAccountPage.show] for direct invocation.
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  /// Shows the delete account sheet and returns 	rue if account was deleted.
  static Future<bool?> show(BuildContext context) {
    return AppModal.sheet<bool>(
      context: context,
      dismissible: false,
      builder: (_) => const DeleteAccountSheet(),
    );
  }

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await DeleteAccountPage.show(context);
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
