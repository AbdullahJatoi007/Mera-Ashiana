import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/base_screens/home_screen.dart';
import 'package:mera_ashiana/base_screens/properties_screen.dart';
import 'package:mera_ashiana/base_screens/search_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/base_screens/profile_screen.dart';
import 'package:mera_ashiana/screens/drawer/custom_drawer.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import 'package:mera_ashiana/services/auth_state.dart';

// Brand Palette
class AppColors {
  static const Color primaryNavy = Color(0xFF0A1D37);
  static const Color accentYellow = Color(0xFFFFC400);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F5F5);
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PropertiesScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    if (index == 3 && !AuthState.isLoggedIn.value) {
      _showLoginSheet(targetIndex: index);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _showLoginSheet({required int targetIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => AuthenticationBottomSheet(
        title: "Sign In",
        onLoginSuccess: () {
          setState(() => _selectedIndex = targetIndex);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final isHome = _selectedIndex == 0;

    return ValueListenableBuilder<bool>(
      valueListenable: AuthState.isLoggedIn,
      builder: (context, isLoggedIn, _) {
        return Scaffold(
          extendBodyBehindAppBar: isHome,
          drawer: const CustomDrawer(),
          appBar: _buildAppBar(context, theme, isHome, loc, isDark),
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: _buildBottomNav(loc, theme, isDark),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool isHome,
    AppLocalizations loc,
    bool isDark,
  ) {
    // Dynamic Icon Color
    Color iconColor;
    if (isHome) {
      iconColor = Colors.white;
    } else {
      iconColor = isDark ? AppColors.accentYellow : AppColors.primaryNavy;
    }

    return AppBar(
      centerTitle: true,
      // Adjust status bar icons based on mode
      systemOverlayStyle: isHome || isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Text(
        _getAppBarTitle(loc, _selectedIndex),
        style: TextStyle(
          color: isHome
              ? Colors.white
              : (isDark ? Colors.white : AppColors.primaryNavy),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
      iconTheme: IconThemeData(color: iconColor),
      backgroundColor: isHome
          ? Colors.transparent
          : (isDark ? theme.cardColor : Colors.white),
      elevation: isHome ? 0 : 0.5,
      bottom: isHome
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: theme.dividerColor.withOpacity(0.05),
              ),
            ),
    );
  }

  Widget _buildBottomNav(AppLocalizations loc, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,

        // High Contrast colors for visibility
        selectedItemColor: AppColors.accentYellow,
        unselectedItemColor: isDark ? Colors.white54 : Colors.black38,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),

        items: [
          _navItem(Icons.home_outlined, Icons.home_rounded, loc.home),
          _navItem(
            Icons.apartment_outlined,
            Icons.apartment_rounded,
            loc.properties ?? 'Properties',
          ),
          _navItem(
            Icons.search_rounded,
            Icons.search_rounded,
            loc.search ?? 'Search',
          ),
          _navItem(
            Icons.favorite_outline_rounded,
            Icons.favorite_rounded,
            loc.favorites,
          ),
          _navItem(
            Icons.person_outline_rounded,
            Icons.person_rounded,
            'Account',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }

  String _getAppBarTitle(AppLocalizations loc, int index) {
    switch (index) {
      case 0:
        return 'MERA ASHIANA';
      case 1:
        return loc.properties ?? 'Properties';
      case 2:
        return loc.propertySearch ?? 'Find Home';
      case 3:
        return loc.favorites;
      case 4:
        return "Account";
      default:
        return 'MERA ASHIANA';
    }
  }
}
