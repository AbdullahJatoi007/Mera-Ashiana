import 'package:flutter/material.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/theme/app_colors.dart';
import 'package:mera_ashiana/screens/favourite_screen.dart';
import 'package:mera_ashiana/screens/home_screen.dart';
import 'package:mera_ashiana/screens/profile_screen.dart';
import 'package:mera_ashiana/screens/projects_screen.dart';
import 'package:mera_ashiana/screens/search_screen.dart';
import 'package:mera_ashiana/screens/drawer/custom_drawer.dart';

// Import your new bottom sheet
import 'package:mera_ashiana/favourite_bottom_sheet.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Change this to false to test the BottomSheet trigger
  bool _isUserLoggedIn = false;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    ProjectsScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // TRIGGER: If Favourites (Index 3) is tapped and user is NOT logged in
    if (index == 3 && !_isUserLoggedIn) {
      _showLoginSheet();
      return; // Stop execution so the tab doesn't change
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to display the login form in a bottom sheet
  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Crucial for form visibility when keyboard opens
      backgroundColor: Colors.transparent,
      // Allows custom container styling
      builder: (context) => const FavouriteBottomSheet(),
    );
  }

  String _getAppBarTitle(BuildContext context, int index) {
    var loc = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return 'Mera-Ashiana.com';
      case 1:
        return loc.currentProjects ?? 'Current Projects';
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
    final bool isHome = _selectedIndex == 0;

    return Scaffold(
      extendBodyBehindAppBar: isHome,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(context, _selectedIndex),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHome ? Colors.white : AppColors.primaryNavy,
          ),
        ),
        iconTheme: IconThemeData(
          color: isHome ? Colors.white : AppColors.primaryNavy,
        ),
        backgroundColor: isHome ? Colors.transparent : AppColors.white,
        elevation: isHome ? 0 : 0.5,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.accentYellow.withOpacity(0.2),
        surfaceTintColor: AppColors.white,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, color: AppColors.primaryNavy),
            selectedIcon: const Icon(Icons.home, color: AppColors.primaryNavy),
            label: loc.home,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.cases_outlined,
              color: AppColors.primaryNavy,
            ),
            selectedIcon: const Icon(Icons.cases, color: AppColors.primaryNavy),
            label: loc.projects ?? 'Projects',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search, color: AppColors.primaryNavy),
            selectedIcon: const Icon(
              Icons.search,
              color: AppColors.primaryNavy,
            ),
            label: loc.search ?? 'Search',
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.primaryNavy,
            ),
            selectedIcon: const Icon(
              Icons.favorite,
              color: AppColors.primaryNavy,
            ),
            label: loc.favorites,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.primaryNavy,
            ),
            selectedIcon: const Icon(
              Icons.person,
              color: AppColors.primaryNavy,
            ),
            label: loc.editProfile.split(' ').last,
          ),
        ],
      ),
    );
  }
}
