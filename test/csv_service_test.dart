import 'package:aviatorscope/shared/models/round_result.dart';
import 'package:aviatorscope/shared/services/csv_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CsvService();
  final now = DateTime(2026, 10, 14, 12);

  test('fichier vide', () {
    final report = service.parse('   ');
    expect(report.rows, isEmpty);
    expect(report.issues, isNotEmpty);
  });

  test('colonne multiplier obligatoire', () {
    final report = service.parse('a,b\n1,2');
    expect(report.rows, isEmpty);
    expect(report.issues.single.message, contains('multiplier'));
  });

  test('séparateur point-virgule et virgule décimale', () {
    final report = service.parse('multiplier;round_id\n1,25x;A1\n2,50;A2', now: now);
    expect(report.rows.map((r) => r.multiplier), [1.25, 2.5]);
    expect(report.rows.first.roundId, 'A1');
    expect(report.issues, isEmpty);
  });

  test('lignes incorrectes signalées avec leur numéro', () {
    final report = service.parse(
      'multiplier,observed_at\n1.5,2026-10-01T10:00:00\nabc,\n0.5,\n2.0,pasunedate',
      now: now,
    );
    expect(report.rows.length, 1);
    expect(report.issues.map((i) => i.line), [3, 4, 5]);
  });

  test('colonnes inconnues ignorées', () {
    final report = service.parse('multiplier,foo\n1.5,x', now: now);
    expect(report.ignoredColumns, ['foo']);
    expect(report.rows.length, 1);
  });

  test('aller-retour export puis import', () {
    final source = [
      RoundResult(
        id: 1,
        multiplier: 1.25,
        observedAt: DateTime(2026, 10, 1, 9, 30),
        source: ResultSources.manual,
        roundId: 'R-1',
        importedAt: now,
        manuallyCorrected: true,
      ),
      RoundResult(
        id: 2,
        multiplier: 291.7,
        source: ResultSources.ocr,
        importedAt: now,
        validated: false,
      ),
    ];
    final csv = service.export(source);
    expect(csv.split('\r\n').first, CsvService.header.join(','));
    final report = service.parse(csv, now: now);
    expect(report.issues, isEmpty);
    expect(report.rows.length, 2);
    expect(report.rows[0].multiplier, 1.25);
    expect(report.rows[0].roundId, 'R-1');
    expect(report.rows[0].manuallyCorrected, isTrue);
    expect(report.rows[1].multiplier, 291.7);
    expect(report.rows[1].validated, isFalse);
    expect(report.rows[1].observedAt, isNull);
  });

  test('tri par date quand toutes les lignes sont datées', () {
    final report = service.parse(
      'multiplier,observed_at\n2.0,2026-10-02T10:00:00\n3.0,2026-10-01T10:00:00',
      now: now,
    );
    expect(report.rows.map((r) => r.multiplier), [3.0, 2.0]);
  });
}
