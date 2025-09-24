import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/user.dart';
import 'package:hive_flutter/hive_flutter.dart';


class LoginPage extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    void createUser() {
      final email = emailController.text.trim();
      final password = passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('Email and password cannot be empty.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      } else {
      final userBox = Hive.box('users');
      final emailExists = userBox.values.any((user) => user.email == email);
      if (emailExists) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Already Registered'),
            content: const Text('The email you entered is already registered. Please use a different email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      bool isEmailValid = email.contains('@');
      bool isPasswordValid = password.length >= 6;

      if (isEmailValid && isPasswordValid) {
        final TextEditingController usernameController = TextEditingController();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Choose a Username'),
            content: TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final user = User(
                    username: usernameController.text,
                    email: email,
                    password: password,
                  );
                  Hive.box('users').add(user);
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('User Created'),
                      content: Text('Username: ${user.username}\nEmail: ${user.email}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('Please enter a valid email and a password with at least 6 characters.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      }
    }

    void signInUser() {
      // Implement sign-in logic here
      final email = emailController.text.trim();
      final password = passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('Email and password cannot be empty.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      final userBox = Hive.box('users');
      final user = userBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => null,
      );
        if (user == null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Not Found'),
        content: const Text('No account found for this email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  if (user.password == password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Successful'),
        content: Text('Welcome, ${user.username}!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incorrect Password'),
        content: const Text('The password you entered is incorrect.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: signInUser,
              child: const Text('Sign In'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: createUser,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}