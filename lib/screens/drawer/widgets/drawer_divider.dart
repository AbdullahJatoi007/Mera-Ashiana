import 'package:flutter/material.dart';

class DrawerDivider extends StatelessWidget {
  const DrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 20, // Reduced from standard
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 20,
      endIndent: 20,
    );
  }
}