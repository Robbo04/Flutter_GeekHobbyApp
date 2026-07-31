import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/screens/developer.dart';
import 'package:app_geek_hobby_app/screens/credits.dart';
import 'package:app_geek_hobby_app/core/themes/theme_controller.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget section({required String title, required List<Widget> children}) {
      return Container(
        margin: AppSpacing.paddingSymmetricResponsive(
          context,
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        padding: AppSpacing.paddingAll16Responsive(context),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.verticalMdResponsive(context),
            ...children,
          ],
        ),
      );
    }

    Widget buttonRow({required String label, required VoidCallback onTap, Widget? trailing}) {
      return Container(
        margin: AppSpacing.paddingSymmetricResponsive(
          context,
          vertical: AppSpacing.xs + 2,
        ),
        child: Material(
          color: const Color(0x00000000),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: AppSpacing.paddingSymmetricResponsive(
                context,
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
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
        margin: AppSpacing.paddingSymmetricResponsive(
          context,
          vertical: AppSpacing.xs + 2,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    Widget themeModeRow() {
      return Container(
        margin: AppSpacing.paddingSymmetricResponsive(
          context,
          vertical: AppSpacing.xs + 2,
        ),
        padding: AppSpacing.paddingSymmetricResponsive(
          context,
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            const Expanded(child: Text('Theme mode')),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.themeMode,
              builder: (context, mode, _) {
                return DropdownButton<ThemeMode>(
                  value: mode,
                  onChanged: (selected) {
                    if (selected != null) {
                      ThemeController.setThemeMode(selected);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                        shape: const StadiumBorder(),
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                      ),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ],
            ),
            section(
              title: 'Customisation',
              children: [
                themeModeRow(),
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
                  trailing: Icon(
                    Icons.developer_mode,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}