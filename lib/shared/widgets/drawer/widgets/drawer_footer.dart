import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;
  final bool isGuest;

  const DrawerFooter({super.key, required this.onLogout, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 🔥 SHOW LOGOUT ONLY IF NOT GUEST
          if (!isGuest)
            InkWell(
              onTap: onLogout,
              child: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

          if (!isGuest) const SizedBox(height: 16),

          Text(
            'Version 1.0.3',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
