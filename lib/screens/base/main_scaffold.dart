import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/base_screens/favourite_screen.dart';
import 'package:mera_ashiana/base_screens/home_screen.dart';
import 'package:mera_ashiana/base_screens/profile_screen.dart';
import 'package:mera_ashiana/base_screens/projects_screen.dart';
import 'package:mera_ashiana/base_screens/search_screen.dart';
import 'package:mera_ashiana/screens/drawer/custom_drawer.dart';
import 'package:mera_ashiana/favourite_bottom_sheet.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final bool _isUserLoggedIn = false;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    ProjectsScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 3 && !_isUserLoggedIn) {
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
      builder: (context) => const FavouriteBottomSheet(),
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
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
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
              // Fixed: Use White for transparent Home, otherwise use theme text color
              color: isHome ? Colors.white : colorScheme.onSurface,
            ),
          ),
          iconTheme: IconThemeData(
            color: isHome ? Colors.white : colorScheme.primary,
          ),
          // Fixed: Use transparent for Home, otherwise use theme surface color
          backgroundColor: isHome ? Colors.transparent : colorScheme.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
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
            // Fixed: Use theme divider color or a subtle version of onSurface
            color: theme.dividerColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // Fixed: Use theme surface color instead of hardcoded white
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.secondary,
        // Fixed: Use theme text color with opacity for unselected
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 22,
        elevation: 0,
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
