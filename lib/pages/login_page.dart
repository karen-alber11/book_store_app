import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/DBHelper.dart';
import '../widgets/drop_down_button.dart';
import '../theme/colors.dart';
import 'dart:convert';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignUp = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedUserType = "User";

  final UserDatabaseHelper dbHelper = UserDatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp ? "Sign Up" : "Sign In"),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 23),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSignUp)
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            if (isSignUp) SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            if (isSignUp) SizedBox(height: 16),
            if (isSignUp)
              DropDownButtonWidget(
                selectedValue: selectedUserType,
                onChanged: (value) {
                  setState(() {
                    selectedUserType = value ?? "User";
                  });
                },
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSignUp ? handleSignUp : handleSignIn,
              child: Text(isSignUp ? "Sign Up" : "Sign In"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isSignUp = !isSignUp;
                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();
                  selectedUserType = "User";
                });
              },
              child: Text(
                isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleSignUp() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar("Please fill all fields");
      return;
    }
    final newUser = {
      UserDatabaseHelper.colUname: nameController.text,
      UserDatabaseHelper.colUemail: emailController.text,
      UserDatabaseHelper.colUpass: passwordController.text,
      UserDatabaseHelper.colUtype: selectedUserType,
    };
    int userId = await dbHelper.insertUser(newUser);
    if (userId > 0) {
      final user = {
        'uid': userId,
        'uname': nameController.text,
        'uemail': emailController.text,
        'utype': selectedUserType,
      };

      // Save user data in Shared Preferences
      await saveUserToPreferences(user);

      // Print user ID and name to the console for verification
      print("User ID: ${user['uid']}, Name: ${user['uname']}");

      navigateToHome();
    } else {
      showSnackBar("Sign-up failed. Try again.");
    }
  }

  void handleSignIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar("Please fill all fields");
      return;
    }

    final users = await dbHelper.fetchUsers();
    final user = users.firstWhere(
          (u) => u[UserDatabaseHelper.colUemail] == emailController.text &&
          u[UserDatabaseHelper.colUpass] == passwordController.text,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      // Save user data in Shared Preferences
      await saveUserToPreferences(user);

      // Print user ID and name to the console for verification
      print("User ID: ${user['uid']}, Name: ${user['uname']}");

      navigateToHome();
    } else {
      showSnackBar("Invalid email or password");
    }
  }

  Future<void> saveUserToPreferences(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentUserId', user['uid']);
    prefs.setString('currentUserName', user['uname']);
  }

  void navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');
    final userName = prefs.getString('currentUserName');

    if (userId != null && userName != null) {
      // Print the user ID and name to the console for verification
      print("Navigating to Home with User ID: $userId, Name: $userName");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } else {
      showSnackBar("User data not found. Please log in again.");
    }
  }


  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
