import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Pages/Login.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/navigation_bar.dart';

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({super.key});

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate> {
  bool isLoggedIn = false;

  void onLoginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? MainTabScaffold()
        : LoginPage(onLoginSuccess: onLoginSuccess);
  }
}