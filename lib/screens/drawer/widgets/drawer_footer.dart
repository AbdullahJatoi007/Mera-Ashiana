import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;

  const DrawerFooter({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ensure the container is wide enough
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.transparent, // Or match drawer background
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
        children: <Widget>[
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
          const SizedBox(height: 16),
          // Increased font size slightly and used a more visible color
          Text(
            'Version 1.0.3',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12, // Increased from 11
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
