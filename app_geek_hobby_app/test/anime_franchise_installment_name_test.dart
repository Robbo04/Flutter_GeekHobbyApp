import 'package:flutter_test/flutter_test.dart';
import 'package:app_geek_hobby_app/widgets/anime/franchise_detail_widgets.dart';

void main() {
  group('franchise installment display names', () {
    test('strips the franchise title prefix when separated by punctuation', () {
      expect(
        stripFranchiseTitlePrefix(
          'My Hero Academia: Heroes Rising',
          'My Hero Academia',
        ),
        'Heroes Rising',
      );

      expect(
        stripFranchiseTitlePrefix(
          'Attack on Titan: Final Season',
          'Attack on Titan',
        ),
        'Final Season',
      );
    });

    test('keeps exact duplicates unchanged', () {
      expect(
        stripFranchiseTitlePrefix('My Hero Academia', 'My Hero Academia'),
        'My Hero Academia',
      );
    });
  });
}
