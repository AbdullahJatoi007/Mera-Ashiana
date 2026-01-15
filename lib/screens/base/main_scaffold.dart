import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/base_screens/home_screen.dart';
import 'package:mera_ashiana/base_screens/profile_screen.dart';
import 'package:mera_ashiana/base_screens/projects_screen.dart';
import 'package:mera_ashiana/base_screens/search_screen.dart';
import 'package:mera_ashiana/screens/drawer/custom_drawer.dart';
import 'package:mera_ashiana/favourite_bottom_sheet.dart';
import 'package:mera_ashiana/services/login_service.dart'; // IMPORT THIS

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool _isUserLoggedIn = false;

  final List<Widget> _screens = const <Widget>[
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

  // Check if a cookie exists in storage
  Future<void> _checkLoginStatus() async {
    final cookie = await LoginService.getAuthCookie();
    setState(() {
      _isUserLoggedIn = (cookie != null);
    });
  }

  void _onItemTapped(int index) async {
    // Re-check status whenever a tab is tapped to stay in sync
    await _checkLoginStatus();

    // If tapping Favorites (3) or Profile (4) and not logged in, show sheet
    if ((index == 3 || index == 4) && !_isUserLoggedIn) {
      _showLoginSheet();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FavouriteBottomSheet(
        onLoginSuccess: () {
          _checkLoginStatus(); // Update state after login
          setState(() => _selectedIndex = 3); // Move to Favorites
        },
      ),
    );
  }

  String _getAppBarTitle(BuildContext context, int index) {
    var loc = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return 'Mera-Ashiana.com';
      case 1:
        return loc.projects ?? 'Current Projects';
      case 2:
        return loc.propertySearch ?? 'Property Search';
      case 3:
        return loc.favorites;
      case 4:
        return loc.editProfile.split(' ').last;
      default:
        return 'Mera Ashiana';
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isHome = _selectedIndex == 0;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) setState(() => _selectedIndex = 0);
      },
      child: Scaffold(
        extendBodyBehindAppBar: isHome,
        drawer: const CustomDrawer(),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _getAppBarTitle(context, _selectedIndex),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isHome ? Colors.white : colorScheme.onSurface,
            ),
          ),
          iconTheme: IconThemeData(
            color: isHome ? Colors.white : colorScheme.primary,
          ),
          backgroundColor: isHome ? Colors.transparent : colorScheme.surface,
          elevation: 0,
        ),
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: _buildBottomNav(loc, theme),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations loc, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.secondary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: loc.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business_center_outlined),
            activeIcon: const Icon(Icons.business_center),
            label: loc.projects ?? 'Projects',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            activeIcon: const Icon(Icons.search),
            label: loc.search ?? 'Search',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: loc.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: loc.editProfile.split(' ').last,
          ),
        ],
      ),
    );
  }
}
