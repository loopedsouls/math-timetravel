import 'package:test/test.dart';
import 'package:math_timetravel/core/constants/math_eras.dart';

void main() {
  group('MathEra', () {
    test('all() returns 6 eras in chronological order', () {
      final eras = MathEra.all;
      expect(eras.length, 6);
      expect(eras.first.id, 'babylonian');
      expect(eras.last.id, 'digital');
    });

    test('every era has non-empty BR/EN names', () {
      for (final era in MathEra.all) {
        expect(era.namePt, isNotEmpty, reason: 'namePt empty for ${era.id}');
        expect(era.nameEn, isNotEmpty, reason: 'nameEn empty for ${era.id}');
      }
    });

    test('every era has at least one BNCC theme and at least one grade', () {
      for (final era in MathEra.all) {
        expect(era.bnccThemes, isNotEmpty,
            reason: 'no bnccThemes for ${era.id}');
        expect(era.bnccGrades, isNotEmpty,
            reason: 'no bnccGrades for ${era.id}');
      }
    });

    test('grades are within EF2 range (6-9)', () {
      for (final era in MathEra.all) {
        for (final g in era.bnccGrades) {
          expect(g, inInclusiveRange(6, 9),
              reason: '$g out of EF2 range for ${era.id}');
        }
      }
    });

    test('byId returns the matching era', () {
      expect(MathEra.byId('greek'), MathEra.greek);
      expect(MathEra.byId('digital'), MathEra.digital);
    });

    test('byId returns null for unknown id', () {
      expect(MathEra.byId('atlantis'), isNull);
      expect(MathEra.byId(''), isNull);
    });

    test('all era ids are unique', () {
      final ids = MathEra.all.map((e) => e.id).toSet();
      expect(ids.length, MathEra.all.length);
    });

    test('toString includes id and English name', () {
      expect(MathEra.greek.toString(), contains('greek'));
      expect(MathEra.greek.toString(), contains('Ancient Greek'));
    });
  });
}
