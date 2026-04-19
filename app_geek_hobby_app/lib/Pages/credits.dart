import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Constants/app_spacing.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
      ),
      body: ListView(
        padding: AppSpacing.paddingAll16,
        children: const [
          Text(
            'Developer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text('Sam Robertson'),
          SizedBox(height: AppSpacing.xl),
          
          Text(
            'APIs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text('Games: RAWG Video Games Database API (https://rawg.io/apidocs)\nAnime: AniList API (https://anilist.gitbook.io/anilist-apiv2-docs/)'),
          SizedBox(height: AppSpacing.xl),

          Text(
            'Developed With',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text('Flutter (https://flutter.dev/)\nDart (https://dart.dev/)\nVisual Studio Code (https://code.visualstudio.com/)\nHive (https://hivedb.dev/)\nHTTP package (https://pub.dev/packages/http)\nFlutter Dotenv (https://pub.dev/packages/flutter_dotenv)\nGraphQL Flutter (https://pub.dev/packages/graphql_flutter)'),

        ],
      ),
    );
  }
}