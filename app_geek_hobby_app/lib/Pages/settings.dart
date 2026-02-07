import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Pages/developer.dart';
import 'package:app_geek_hobby_app/Pages/credits.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget section({required String title, required List<Widget> children}) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                )),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      );
    }

    Widget buttonRow({required String label, required VoidCallback onTap, Widget? trailing}) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text(label)),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget readOnlyRow({required String label, required String value}) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.grey[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            section(
              title: 'Account Details',
              children: [
                readOnlyRow(label: 'Name', value: 'Your Name'),
                readOnlyRow(label: 'Date', value: '01/01/2025'),
                readOnlyRow(label: 'Email', value: 'you@email.com'),
                Row(
                  children: [
                    Expanded(child: Text('Password: *****')),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        backgroundColor: Colors.grey[400],
                      ),
                      child: Text('Change'),
                    ),
                  ],
                ),
              ],
            ),
            section(
              title: 'Customisation',
              children: [
                buttonRow(
                  label: 'Colour scheme',
                  onTap: () {},
                  trailing: Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.red],
                      ),
                    ),
                  ),
                ),
                buttonRow(
                  label: 'Font size',
                  onTap: () {},
                  trailing: Icon(Icons.chevron_right),
                ),
                buttonRow(
                  label: 'Language',
                  onTap: () {},
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
            section(
              title: 'About',
              children: [
                readOnlyRow(label: 'App Version:', value: '1.0.0'),
                buttonRow(
                  label: 'Privacy Policy',
                  onTap: () {},
                  trailing: Icon(Icons.chevron_right),
                ),
                buttonRow(
                  label: 'Terms and conditions',
                  onTap: () {},
                  trailing: Icon(Icons.chevron_right),
                ),
                buttonRow(
                  label: 'Credits',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreditsPage()),
                    );
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
            section(
              title: 'Developer',
              children: [
                buttonRow(
                  label: 'Developer Tools',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DeveloperPage()),
                    );
                  },
                  trailing: Icon(Icons.developer_mode, color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}