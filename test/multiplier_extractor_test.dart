import 'package:aviatorscope/core/utils/multiplier_parser.dart';
import 'package:aviatorscope/features/screenshot_import/domain/multiplier_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extractor = MultiplierExtractor();

  test('extrait les exemples du cahier des charges', () {
    final result = extractor.extract('1.25x\n1.82x\n291.70x\n1.13x\n9.90x');
    expect(result.items.map((i) => i.value), [1.25, 1.82, 291.7, 1.13, 9.9]);
    expect(result.ignoredNumbers, 0);
    expect(result.items.every((i) => i.flag != ExtractionFlag.invalid), isTrue);
  });

  test('ignore les nombres sans x (heure, solde, etc.)', () {
    final result = extractor.extract('12:45  Solde 1500\n2.35x  3.10X');
    expect(result.items.map((i) => i.value), [2.35, 3.1]);
    expect(result.ignoredNumbers, greaterThan(0));
  });

  test('virgule décimale, espace avant x et symbole ×', () {
    final result = extractor.extract('1,25 x 4.00×');
    expect(result.items.map((i) => i.value), [1.25, 4.0]);
  });

  test('séparateur décimal absent : lecture ambiguë', () {
    final result = extractor.extract('125x');
    expect(result.items.single.flag, ExtractionFlag.ambiguous);
  });

  test('valeur inférieure à 1,00 : invalide', () {
    final result = extractor.extract('0.85x');
    expect(result.items.single.flag, ExtractionFlag.invalid);
  });

  test('valeur très élevée : suspecte', () {
    final result = extractor.extract('5000.00x');
    expect(result.items.single.flag, ExtractionFlag.suspicious);
  });

  test('texte absent ou vide', () {
    final result = extractor.extract('');
    expect(result.items, isEmpty);
    expect(result.textTooShort, isTrue);
  });

  group('parseMultiplier', () {
    test('formats acceptés', () {
      expect(parseMultiplier('1,25'), 1.25);
      expect(parseMultiplier(' 2.5x '), 2.5);
      expect(parseMultiplier('3X'), 3.0);
    });
    test('formats refusés', () {
      expect(parseMultiplier(''), isNull);
      expect(parseMultiplier('abc'), isNull);
      expect(parseMultiplier('1.000,50'), isNull);
      expect(parseMultiplier('-2'), isNull);
    });
  });
}
