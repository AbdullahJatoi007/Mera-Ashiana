import 'package:flutter/material.dart';
import 'package:mera_ashiana/screens/favourite_screen.dart';
import 'package:mera_ashiana/screens/home_screen.dart';
import 'package:mera_ashiana/screens/profile_screen.dart';
import 'package:mera_ashiana/screens/projects_screen.dart';
import 'package:mera_ashiana/screens/search_screen.dart';
import 'package:mera_ashiana/screens/drawer/custom_drawer.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    ProjectsScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Mera-Ashiana.com';
      case 1:
        return 'Current Projects';
      case 2:
        return 'Property Search';
      case 3:
        return 'My Favourites';
      case 4:
        return 'Profile';
      default:
        return 'Ashiana App';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isHome = _selectedIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHome ? Colors.white : colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(
          color: isHome ? Colors.white : colorScheme.onSurface,
        ),
        backgroundColor:
        isHome ? Colors.transparent : colorScheme.surface,
        elevation: isHome ? 0 : 1,
        scrolledUnderElevation: isHome ? 0 : 1,
      ),

      // Only Home goes behind the AppBar
      extendBodyBehindAppBar: isHome,

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      drawer: const CustomDrawer(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.cases_outlined),
            selectedIcon: Icon(Icons.cases),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}