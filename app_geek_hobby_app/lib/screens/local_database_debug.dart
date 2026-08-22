import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:app_geek_hobby_app/local_database/local_seed_data.dart';
import 'package:app_geek_hobby_app/models/collection/collection.dart';
import 'package:app_geek_hobby_app/models/franchise/franchise.dart';
import 'package:app_geek_hobby_app/models/media/media.dart';
import 'package:app_geek_hobby_app/models/studio/studio.dart';
import 'package:app_geek_hobby_app/models/user/user_media.dart';

class LocalDatabaseDebugPage extends StatefulWidget {
  const LocalDatabaseDebugPage({super.key});

  @override
  State<LocalDatabaseDebugPage> createState() => _LocalDatabaseDebugPageState();
}

class _LocalDatabaseDebugPageState extends State<LocalDatabaseDebugPage> {
  final TextEditingController _searchController = TextEditingController();
  final Box<Media> _mediaBox = Hive.box<Media>('media');
  final Box<Franchise> _franchiseBox = Hive.box<Franchise>('franchises');
  final Box<Studio> _studioBox = Hive.box<Studio>('studios');
  final Box<AppCollection> _collectionBox = Hive.box<AppCollection>('collections');
  final Box<UserMedia> _userMediaBox = Hive.box<UserMedia>('user_media');

  String _query = '';
  String _selectedTable = 'media';

  List<dynamic> get _filteredItems {
    final lower = _query.trim().toLowerCase();

    switch (_selectedTable) {
      case 'media':
        final items = _mediaBox.values.toList();
        if (lower.isEmpty) return items;
        return items.where((item) {
          final title = item.title.toLowerCase();
          final id = item.id.toLowerCase();
          final type = item.type.toLowerCase();
          return title.contains(lower) || id.contains(lower) || type.contains(lower);
        }).toList();
      case 'franchises':
        final items = _franchiseBox.values.toList();
        if (lower.isEmpty) return items;
        return items.where((item) {
          final title = item.name.toLowerCase();
          final id = item.id.toLowerCase();
          return title.contains(lower) || id.contains(lower);
        }).toList();
      case 'studios':
        final items = _studioBox.values.toList();
        if (lower.isEmpty) return items;
        return items.where((item) {
          final title = item.name.toLowerCase();
          final id = item.id.toLowerCase();
          return title.contains(lower) || id.contains(lower);
        }).toList();
      case 'collections':
        final items = _collectionBox.values.toList();
        if (lower.isEmpty) return items;
        return items.where((item) {
          final title = item.name.toLowerCase();
          final id = item.id.toLowerCase();
          return title.contains(lower) || id.contains(lower);
        }).toList();
      case 'user_media':
        final items = _userMediaBox.values.toList();
        if (lower.isEmpty) return items;
        return items.where((item) {
          final mediaId = item.mediaId.toLowerCase();
          final status = item.status.toLowerCase();
          return mediaId.contains(lower) || status.contains(lower);
        }).toList();
      default:
        return const [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Database Debug'),
      ),
      body: Padding(
        padding: AppSpacing.paddingAll16Responsive(context),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                selected: {_selectedTable},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedTable = selection.first;
                    _query = '';
                    _searchController.clear();
                  });
                },
                segments: const [
                  ButtonSegment(value: 'media', label: Text('Media')),
                  ButtonSegment(value: 'franchises', label: Text('Franchises')),
                  ButtonSegment(value: 'studios', label: Text('Studios')),
                  ButtonSegment(value: 'collections', label: Text('Collections')),
                  ButtonSegment(value: 'user_media', label: Text('User media')),
                ],
              ),
            ),
            AppSpacing.verticalMdResponsive(context),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${_selectedTable.replaceAll('_', ' ')}',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            AppSpacing.verticalMdResponsive(context),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Entries: ${_filteredItems.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_selectedTable == 'media' && _mediaBox.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear media database?'),
                          content: const Text(
                            'This will remove all entries from the local media box.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      await _mediaBox.clear();
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                    child: const Text('Clear DB'),
                  ),
              ],
            ),
            AppSpacing.verticalSmResponsive(context),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await LocalSeedData.seedDemoData();
                  if (!mounted || !context.mounted) return;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo data added to local database')),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add demo data'),
              ),
            ),
            AppSpacing.verticalSmResponsive(context),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await LocalSeedData.migrateExistingAppMedia();
                  if (!mounted || !context.mounted) return;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Existing app media migrated into local database'),
                    ),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text('Migrate existing app media'),
              ),
            ),
            AppSpacing.verticalSmResponsive(context),
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
                      child: Text('No entries found'),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];

                        if (item is Media) {
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('ID: ${item.id}'),
                                  Text('Type: ${item.type}'),
                                  Text('Year: ${item.releaseYear}'),
                                  if (item.studioId != null) Text('Studio: ${item.studioId}'),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        }

                        if (item is Franchise) {
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text('ID: ${item.id}'),
                            ),
                          );
                        }

                        if (item is Studio) {
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text('ID: ${item.id}'),
                            ),
                          );
                        }

                        if (item is AppCollection) {
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text('User: ${item.userId}'),
                            ),
                          );
                        }

                        if (item is UserMedia) {
                          return Card(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text('Media: ${item.mediaId}'),
                              subtitle: Text('Status: ${item.status} • Progress: ${item.progress}'),
                            ),
                          );
                        }

                        return Card(
                          margin: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ListTile(
                            title: Text(item.toString()),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
