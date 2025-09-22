import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/user.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    void createUser() {
      final email = emailController.text.trim();
      final password = passwordController.text;

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

    void signInUser() {
      // Implement sign-in logic here
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