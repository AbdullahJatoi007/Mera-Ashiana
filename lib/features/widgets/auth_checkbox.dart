import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final bool isTerms; // toggle clickable link
  final bool isDark;

  const AuthCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.isTerms = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (val) {
        HapticFeedback.selectionClick();
        onChanged(val);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primaryNavy,
      checkColor: AppColors.accentYellow,
      dense: true,
      title: isTerms
          ? RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                children: [
                  const TextSpan(text: "I accept the "),
                  TextSpan(
                    text: "Terms & Privacy Policy",
                    style: TextStyle(
                      color: isDark ? AppColors.accentYellow : Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri url = Uri.parse(
                          'https://mera-ashiana.com/about',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                  ),
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ],
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
    );
  }
}
