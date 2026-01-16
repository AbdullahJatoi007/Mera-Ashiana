import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/base_screens/home_screen.dart';
import 'package:mera_ashiana/base_screens/projects_screen.dart';
import 'package:mera_ashiana/base_screens/search_screen.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/base_screens/profile_screen.dart';
import 'package:mera_ashiana/screens/drawer/custom_drawer.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import 'package:mera_ashiana/services/login_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool _isUserLoggedIn = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProjectsScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final cookie = await LoginService.getAuthCookie();
    if (mounted) {
      setState(() => _isUserLoggedIn = cookie != null);
    }
  }

  void _onItemTapped(int index) async {
    HapticFeedback.selectionClick();

    // Protected tabs: Favorites(3), Profile(4)
    if ((index == 3 || index == 4) && !_isUserLoggedIn) {
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
        title: targetIndex == 4 ? "Login to Account" : "Sign In",
        onLoginSuccess: () {
          _checkLoginStatus();
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

    return Scaffold(
      extendBodyBehindAppBar: isHome,
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(context, theme, isHome, loc),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(loc, theme),
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
        return loc.projects ?? 'Projects';
      case 2:
        return loc.propertySearch ?? 'Find Home';
      case 3:
        return loc.favorites;
      case 4:
        return loc.editProfile.split(' ').last;
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
          label: loc.projects ?? 'Projects',
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
