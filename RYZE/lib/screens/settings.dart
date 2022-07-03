import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:get/get.dart';
import 'package:ryze/screens/auth/test_ui_auth.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:ryze/shared/network/shared_pref.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: .5,
      ),
      body: SettingsList(
        contentPadding: const EdgeInsets.only(top: 10),
        sections: [
          SettingsSection(
            title: 'User Interface',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: const Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.switchTile(
                title: 'Dark Mode',
                leading: const Icon(Icons.dark_mode_outlined),
                switchValue: CashHelper.getData(key: 'isDarkMode')??false,
                onToggle: (bool value) async{
                  CashHelper.saveData(key: 'isDarkMode',value:  value);
                  setState((){
                    if (! CashHelper.getData(key: 'isDarkMode')) {
                      Get.changeThemeMode(ThemeMode.light);
                    } else {
                      Get.changeThemeMode(ThemeMode.dark);
                    }
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile.switchTile(
                title: 'Private Account',
                leading: const Icon(Icons.privacy_tip_outlined),
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile(
                title: 'profile',
                leading: const Icon(Icons.person_outline),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: 'Friends',
                leading: const Icon(Icons.people_outline),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: 'Chat',
                leading: const Icon(Icons.message_outlined),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            tiles: [
              SettingsTile(
                title: 'Contact Us',
                leading: const Icon(Icons.call_outlined),
                onPressed: (BuildContext context) {},
              ),SettingsTile(
                title: 'About Ryze',
                leading: const Icon(Icons.info_outline),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Logins',
            tiles: [
              SettingsTile(
                title: 'LogOut',
                leading: const Icon(Icons.logout),
                onPressed: (BuildContext context) async{
                  await FirebaseAuth.instance.signOut();
                  user=null;
                  navigateToAndReplace(context, const TestUiAuth());
                },
              ),

            ],
          ),
        ],
      ),
    );
  }
}
