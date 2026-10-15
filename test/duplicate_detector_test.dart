import 'package:aviatorscope/features/history/domain/duplicate_detector.dart';
import 'package:aviatorscope/shared/models/round_result.dart';
import 'package:flutter_test/flutter_test.dart';

RoundResult r(int id, double m, {String? round, DateTime? at}) => RoundResult(
      id: id,
      multiplier: m,
      observedAt: at,
      source: ResultSources.manual,
      roundId: round,
      importedAt: DateTime(2026, 10, 14),
    );

void main() {
  const detector = DuplicateDetector();

  test('des multiplicateurs identiques sans identifiant ne sont pas des doublons', () {
    expect(detector.suspectIds([r(1, 1.0), r(2, 1.0), r(3, 1.0)]), isEmpty);
  });

  test('même numéro de manche : doublon', () {
    final suspects = detector.suspectIds([r(1, 2.0, round: 'A'), r(2, 2.0, round: 'A')]);
    expect(suspects, {2});
  });

  test('même date et même valeur : doublon', () {
    final at = DateTime(2026, 10, 1, 10);
    expect(detector.suspectIds([r(1, 3.5, at: at), r(2, 3.5, at: at)]), {2});
    expect(detector.suspectIds([r(1, 3.5, at: at), r(2, 3.6, at: at)]), isEmpty);
  });

  group('chevauchement entre imports', () {
    test('détecte le plus grand recouvrement', () {
      expect(detector.tailOverlap([1.1, 2.2, 3.3, 4.4], [3.3, 4.4, 5.5]), 2);
      expect(detector.tailOverlap([1.1, 2.2, 3.3], [1.1, 2.2, 3.3]), 3);
    });
    test('aucun recouvrement', () {
      expect(detector.tailOverlap([1.1, 2.2], [3.3, 4.4]), 0);
      expect(detector.tailOverlap(const [], [1.0]), 0);
    });
  });
}
