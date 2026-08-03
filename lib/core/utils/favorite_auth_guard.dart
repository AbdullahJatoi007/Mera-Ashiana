import 'package:flutter/material.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';

/// Gates any favorite-toggle (or other login-required) action behind an
/// auth check, matching the exact pattern MainScaffold already uses for
/// the Favorites tab: if logged in, run the action immediately; if not,
/// show AuthenticationBottomSheet and run the action automatically on
/// successful login instead of silently failing with a network-looking error.
Future<void> runIfLoggedIn(
  BuildContext context, {
  required Future<void> Function() action,
}) async {
  if (AuthState.isLoggedIn.value) {
    await action();
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => AuthenticationBottomSheet(
      onLoginSuccess: () {
        // Fire the originally-intended action right after a successful
        // login/register, so tapping the heart while logged out still
        // ends in the property actually being favorited.
        action();
      },
    ),
  );
}
