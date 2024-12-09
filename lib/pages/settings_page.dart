import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';
import '../theme/colors.dart';

class UserSettingsScreen extends StatefulWidget {
  UserSettingsScreen({Key? key}) : super(key: key);

  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  bool isSwitched = false,
      isLockApp = true,
      isFingerPrintEnabled = false,
      isChangePass = false;

  Future<void> signOut() async {
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to the login page and remove the current screen from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Settings", style: TextStyle(color: secondary,fontSize: 23, fontWeight: FontWeight.w600),),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
                onPressed: (context) {
                  // Handle language selection
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
                initialValue: isSwitched,
                leading: const Icon(Icons.phone_android),
                title: const Text('Use System Theme'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Account'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.phone),
                title: const Text('Phone number'),
                onPressed: (context) {
                  // Handle phone number action
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                onPressed: (context) {
                  // Handle email action
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onPressed: (context) async {
                  await signOut();
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Security'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    isLockApp = value;
                  });
                },
                initialValue: isLockApp,
                leading: const Icon(Icons.phonelink_lock_sharp),
                title: const Text('Lock app in background'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    isFingerPrintEnabled = value;
                  });
                },
                initialValue: isFingerPrintEnabled,
                leading: const Icon(Icons.fingerprint),
                title: const Text('Use fingerprint'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    isChangePass = value;
                  });
                },
                initialValue: isChangePass,
                leading: const Icon(Icons.lock_rounded),
                title: const Text('Change Password'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
