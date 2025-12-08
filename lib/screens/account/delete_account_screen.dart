// coverage:ignore-file
import 'package:flutter/material.dart';

import '../../ui/kit/kit.dart';
import 'delete_account_sheet.dart';

/// Shows the [DeleteAccountSheet] modal via [AppModal.sheet].
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  /// Shows the delete account sheet and returns true if account was deleted.
  static Future<bool?> show(BuildContext context) {
    return AppModal.sheet<bool>(
      context: context,
      dismissible: false,
      builder: (_) => const DeleteAccountSheet(),
    );
  }

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  @override
  void initState() {
    super.initState();
    // Show the sheet immediately when this page is pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await DeleteAccountScreen.show(context);
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
