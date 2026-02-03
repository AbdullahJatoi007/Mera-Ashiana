import 'package:flutter/cupertino.dart';
import 'package:mera_ashiana/features/screens/login_form.dart';
import 'package:mera_ashiana/features/screens/register_form.dart';

class AuthenticationBottomSheet extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthenticationBottomSheet({super.key, required this.onLoginSuccess});

  @override
  State<AuthenticationBottomSheet> createState() =>
      _AuthenticationBottomSheetState();
}

class _AuthenticationBottomSheetState extends State<AuthenticationBottomSheet> {
  bool isRegister = false;

  @override
  Widget build(BuildContext context) {
    return isRegister
        ? RegisterForm(
            onSuccess: widget.onLoginSuccess,
            onSwitch: () => setState(() => isRegister = false),
          )
        : LoginForm(
            onSuccess: widget.onLoginSuccess,
            onSwitch: () => setState(() => isRegister = true),
          );
  }
}
