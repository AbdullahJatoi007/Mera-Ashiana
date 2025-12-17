import 'package:flutter/material.dart';

class DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;

  const DrawerFooter({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Logout Button
          ListTile(
            leading: Icon(
              Icons.logout,
              color: colorScheme.error,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: onLogout,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const SizedBox(height: 8),
          // App Version
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'App Version 1.0.0',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}