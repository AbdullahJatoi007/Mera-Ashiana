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
import 'package:mera_ashiana/services/auth_state.dart'; // Import global state

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // These are constant so they don't rebuild unnecessarily
  final List<Widget> _screens = const [
    HomeScreen(),
    PropertiesScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();

    // BEST PRACTICE:
    // Only block Favorites(3) if not logged in.
    // Let the user click Profile(4) so they see the Guest View/Register option.
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
          // No need for checkLoginStatus() here, the BottomSheet
          // already updates AuthState.isLoggedIn.value
          setState(() => _selectedIndex = targetIndex);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isHome = _selectedIndex == 0;

    // Wrap with ValueListenableBuilder so the UI (like App Bar titles)
    // updates immediately when the user logs in/out.
    return ValueListenableBuilder<bool>(
      valueListenable: AuthState.isLoggedIn,
      builder: (context, isLoggedIn, _) {
        return Scaffold(
          extendBodyBehindAppBar: isHome,
          drawer: const CustomDrawer(),
          appBar: _buildAppBar(context, theme, isHome, loc),
          // IndexedStack keeps the state of all screens alive
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: _buildBottomNav(loc, theme),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool isHome,
    AppLocalizations loc,
  ) {
    return AppBar(
      centerTitle: true,
      systemOverlayStyle: isHome
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Text(
        _getAppBarTitle(loc, _selectedIndex),
        style: TextStyle(
          color: isHome ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconTheme: IconThemeData(
        color: isHome ? Colors.white : theme.colorScheme.primary,
      ),
      backgroundColor: isHome ? Colors.transparent : theme.colorScheme.surface,
      elevation: isHome ? 0 : 0.5,
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
        return "Account"; // Simplified
      default:
        return 'MERA ASHIANA';
    }
  }

  Widget _buildBottomNav(AppLocalizations loc, ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home_rounded),
          label: loc.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.apartment_outlined),
          activeIcon: const Icon(Icons.apartment_rounded),
          label: loc.properties ?? 'Properties',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search_rounded),
          activeIcon: const Icon(Icons.search_rounded),
          label: loc.search ?? 'Search',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline_rounded),
          activeIcon: const Icon(Icons.favorite_rounded),
          label: loc.favorites,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
          label: 'Account',
        ),
      ],
    );
  }
}
