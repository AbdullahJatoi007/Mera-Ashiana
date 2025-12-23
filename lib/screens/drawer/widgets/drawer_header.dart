import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mera_ashiana/base_screens/profile_screen.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF0A1D37);
    const Color accentYellow = Color(0xFFFFC400);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: const BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        child: Row(
          children: <Widget>[
            const CircleAvatar(
              radius: 28,
              backgroundColor: accentYellow,
              child: Icon(Icons.person, size: 30, color: primaryNavy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Zubair Ali',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'mrzubair@gmail.com',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: accentYellow),
          ],
        ),
      ),
    );
  }
}
