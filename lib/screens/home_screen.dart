import 'package:flutter/material.dart';
import 'package:mera_ashiana/screens/home/home_top_section.dart';
import 'package:mera_ashiana/screens/home/widgets/home_top_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedOption = 'BUY';

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight =
        MediaQuery.of(context).padding.top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeTopSection(
            selectedOption: _selectedOption,
            statusBarHeight: statusBarHeight,
            onOptionSelected: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
          ),

          /// LIST CONTENT
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.home),
                  title: Text('Property ${index + 1}'),
                  subtitle: const Text('Location details go here'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}