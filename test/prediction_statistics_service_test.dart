import 'package:aviatorscope/features/statistics/domain/multiplier_category.dart';
import 'package:aviatorscope/features/statistics/domain/prediction_statistics_service.dart';
import 'package:aviatorscope/features/statistics/domain/statistics_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = PredictionStatisticsService();

  group('liste vide', () {
    test('moyenne, médiane et fréquences sont indéfinies', () {
      expect(service.mean(const []), isNull);
      expect(service.median(const []), isNull);
      expect(service.standardDeviation(const []), isNull);
      expect(service.shareBelow(const [], 2), isNull);
      final stats = service.categoryFrequencies(const []);
      expect(stats.every((s) => s.fraction == null && s.interval == null), isTrue);
      final summary = service.summarize(const []);
      expect(summary.count, 0);
      expect(summary.last, isNull);
    });

    test('aucune série', () {
      final runs = service.analyzeRuns(const []);
      expect(runs.series.every((s) => s.longest == 0 && s.current == 0), isTrue);
      expect(runs.series.every((s) => s.roundsSinceLast == null), isTrue);
    });
  });

  group('un seul résultat', () {
    test('statistiques de base', () {
      expect(service.mean([2.5]), 2.5);
      expect(service.median([2.5]), 2.5);
      expect(service.standardDeviation([2.5]), isNull);
      final below2 = service.categoryStat(MultiplierCategory.below200, [2.5]);
      expect(below2.count, 0);
      expect(below2.fraction, 0);
    });
  });

  group('résultats identiques', () {
    test('écart-type nul et fréquence de 100 %', () {
      final values = List<double>.filled(10, 1.5);
      expect(service.mean(values), 1.5);
      expect(service.median(values), 1.5);
      expect(service.standardDeviation(values), 0);
      expect(service.categoryStat(MultiplierCategory.below200, values).fraction, 1);
    });
  });

  group('multiplicateurs décimaux', () {
    test('médiane paire et moyenne', () {
      final values = [1.25, 1.82, 291.70, 1.13, 9.90];
      expect(service.mean(values), closeTo(61.16, 0.001));
      expect(service.median(values), 1.82);
      expect(service.median([1.0, 2.0, 3.0, 4.0]), 2.5);
    });

    test('bornes des catégories semi-ouvertes', () {
      expect(MultiplierCategory.below200.contains(1.99), isTrue);
      expect(MultiplierCategory.below200.contains(2.0), isFalse);
      expect(MultiplierCategory.band2to5.contains(2.0), isTrue);
      expect(MultiplierCategory.band2to5.contains(5.0), isFalse);
      expect(MultiplierCategory.band5to10.contains(5.0), isTrue);
      expect(MultiplierCategory.atLeast10.contains(10.0), isTrue);
    });
  });

  group('valeurs invalides', () {
    test('validation', () {
      expect(service.validate(0.99), ValueStatus.invalid);
      expect(service.validate(double.nan), ValueStatus.invalid);
      expect(service.validate(double.infinity), ValueStatus.invalid);
      expect(service.validate(1.0), ValueStatus.valid);
      expect(service.validate(5000), ValueStatus.suspicious);
      expect(service.validate(2000000), ValueStatus.invalid);
    });

    test('validValues retire les valeurs invalides', () {
      expect(service.validValues([0.5, 1.2, double.nan, 3.0]), [1.2, 3.0]);
      final summary = service.summarize([0.5, 1.2, 3.0]);
      expect(summary.count, 2);
      expect(summary.invalidCount, 1);
    });
  });

  group('données dupliquées', () {
    test('les valeurs répétées sont comptées normalement', () {
      final values = [1.0, 1.0, 1.0, 3.0];
      expect(service.categoryStat(MultiplierCategory.below120, values).count, 3);
    });
  });

  group('échantillon plus petit que la fenêtre', () {
    test('lastN retourne tout ce qui existe', () {
      expect(service.lastN([1, 2, 3], 50), [1, 2, 3]);
      expect(service.lastN([1, 2, 3, 4], 2), [3, 4]);
      expect(service.lastN([1, 2, 3], null), [1, 2, 3]);
      expect(service.lastN([1, 2, 3], 0), [1, 2, 3]);
    });

    test('compareWindows indique la taille réelle', () {
      final snapshots =
          service.compareWindows(List<double>.filled(30, 2.0), [50, 100, 500]);
      expect(snapshots.map((s) => s.actual), [30, 30, 30]);
      expect(snapshots.map((s) => s.requested), [50, 100, 500]);
      final diff = service.windowDifference(snapshots, 'lt200');
      expect(diff?.spread, 0);
    });
  });

  group('intervalle de Wilson', () {
    test('63 sur 100', () {
      final ci = service.wilsonInterval(63, 100)!;
      expect(ci.low, closeTo(0.532, 0.003));
      expect(ci.high, closeTo(0.718, 0.003));
    });

    test('0 sur 10 : borne basse nulle', () {
      final ci = service.wilsonInterval(0, 10)!;
      expect(ci.low, closeTo(0, 1e-9));
      expect(ci.high, closeTo(0.2775, 0.002));
    });

    test('cas invalides', () {
      expect(service.wilsonInterval(0, 0), isNull);
      expect(service.wilsonInterval(5, 4), isNull);
      expect(service.wilsonInterval(-1, 4), isNull);
    });
  });

  group('séries', () {
    test('plus longue série, série en cours, manches écoulées', () {
      final values = [1.1, 1.2, 3.0, 1.3, 1.4, 1.2, 6.0, 1.1];
      final runs = service.analyzeRuns(values);
      final below15 = runs.series[0];
      expect(below15.longest, 3);
      expect(below15.current, 1);
      final atLeast5 = runs.series[2];
      expect(atLeast5.longest, 1);
      expect(atLeast5.current, 0);
      expect(atLeast5.roundsSinceLast, 1);
    });
  });

  test('déterminisme : mêmes entrées, mêmes sorties', () {
    final values = [1.5, 2.5, 10.0, 1.1];
    final a = service.categoryFrequencies(values).map((s) => s.count).toList();
    final b = service.categoryFrequencies(values).map((s) => s.count).toList();
    expect(a, b);
  });
}
