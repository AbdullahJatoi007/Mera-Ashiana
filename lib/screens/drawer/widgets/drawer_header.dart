import 'package:flutter/material.dart';
import '../../profile_screen.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: 40,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // close drawer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primary.withOpacity(0.15),
              child: Icon(
                Icons.person,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Zubair Ali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'mrzubair@gmail.com',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}