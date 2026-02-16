import 'package:flutter/material.dart';
import 'package:mera_ashiana/profile/profile_screen.dart';
import 'package:mera_ashiana/models/user_model.dart';
import 'package:mera_ashiana/services/profile_service.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryNavy = isDark ? Colors.black87 : const Color(0xFF0A1D37);
    final accentYellow = const Color(0xFFFFC400);

    return Material(
      color: primaryNavy,
      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
        child: FutureBuilder<User?>(
          future: ProfileService.fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: accentYellow),
              );
            }

            final user = snapshot.data;
            final displayName = user?.username ?? 'Guest User';
            final email = user?.email ?? 'Please login';
            final initial = displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : '?';

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Close the drawer first
                Navigator.of(context).pop();

                // Push after drawer fully closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: accentYellow,
                      child: Text(
                        initial,
                        style: TextStyle(
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
                            email,
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
                    Icon(
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
