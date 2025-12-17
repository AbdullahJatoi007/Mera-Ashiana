import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';


class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  Locale _locale = const Locale('en');// default language
  bool _isDarkMode = false;


  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _locale,
      child: Builder(builder: (context) {
        var loc = AppLocalizations.of(context)!; // localized strings

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.accountSettings),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Zubair Ali',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('mrzubair@gmail.com',
                            style:
                            TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(loc.editProfile),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(loc.changeLanguage),
                  trailing: DropdownButton<String>(
                    value: _locale.languageCode,
                    items: [
                      DropdownMenuItem(
                          value: 'en', child: Text(loc.english)),
                      DropdownMenuItem(
                          value: 'ur', child: Text(loc.urdu)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _changeLanguage(value);
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(loc.notifications),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(loc.deleteAccount),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text(loc.darkMode),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                    activeTrackColor: Colors.blue[100],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashRadius: 20,
                    thumbIcon: MaterialStateProperty.all(
                      Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.white,
                      ),
                    ),
                  ),


                )
              ],
            ),
          ),
        );
      }),
    );
  }
}