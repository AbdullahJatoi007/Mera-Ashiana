import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mera_ashiana/profile//profile_screen.dart';
import 'package:mera_ashiana/models/user_model.dart';
import 'package:mera_ashiana/services/profile_service.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF0A1D37);
    const Color accentYellow = Color(0xFFFFC400);

    return Material(
      // <--- 1. Added Material to fix the crash
      color: primaryNavy,
      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
        child: FutureBuilder<User>(
          future: ProfileService.fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(color: accentYellow),
              );
            }

            final user = snapshot.data;
            final displayName = user?.username ?? 'Guest User';
            final initial = displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : '?';

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              // Makes the ripple look better
              onTap: () {
                // 2. Optimized Navigation
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }
                });
              },
              child: Padding(
                // Add padding so the ripple isn't touching the edges
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: accentYellow,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user?.email ?? 'Please login',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: accentYellow,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
