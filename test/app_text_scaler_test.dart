import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mysched/app/bootstrap_gate.dart';
import 'package:mysched/env.dart';
import 'package:mysched/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('MySchedApp clamps text scaler to 1.6x', (tester) async {
    BootstrapGate.debugBypassPermissions = true;
    Env.debugInstallMock(
      SupabaseClient(
        'https://test.supabase.co',
        'anon',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.pkce,
        ),
      ),
    );
    const initialMedia = MediaQueryData(
      textScaler: TextScaler.linear(2.4),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: initialMedia,
        child: const MySchedApp(),
      ),
    );
    await tester.pump();

    final mediaWidgets =
        tester.widgetList<MediaQuery>(find.byType(MediaQuery)).toList();
    final MediaQueryData effective = mediaWidgets.last.data;

    final double appliedScale = effective.textScaler.scale(10) / 10;
    expect(appliedScale, equals(1.6));
    BootstrapGate.debugBypassPermissions = false;
  });
}
