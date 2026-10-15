import 'package:aviatorscope/features/fairness/domain/provably_fair_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

// Vecteur de test public : SHA-256("abc").
const abcSha256 =
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';

void main() {
  const verifier = ProvablyFairVerifier();

  FairnessRequest request({
    String seed = 'abc',
    String hash = abcSha256,
    FairnessMode mode = FairnessMode.seedCommitment,
    HashAlgorithm algorithm = HashAlgorithm.sha256,
    List<String> parts = const [],
    String separator = '',
    String? multiplier,
  }) =>
      FairnessRequest(
        mode: mode,
        algorithm: algorithm,
        serverSeed: seed,
        displayedHash: hash,
        parts: parts,
        separator: separator,
        displayedMultiplier: multiplier,
      );

  test('hash concordant', () {
    final result = verifier.verify(request());
    expect(result.outcome, FairnessOutcome.hashMatch);
    expect(result.computedHash, abcSha256);
    expect(result.multiplierVerified, isFalse);
  });

  test('la casse du hash affiché est ignorée', () {
    final result = verifier.verify(request(hash: abcSha256.toUpperCase()));
    expect(result.outcome, FairnessOutcome.hashMatch);
  });

  test('hash différent : vérification échouée avec détail', () {
    final altered = 'a${abcSha256.substring(1)}';
    final result = verifier.verify(request(hash: altered));
    expect(result.outcome, FairnessOutcome.hashMismatch);
    expect(result.firstMismatchIndex, 0);
    expect(result.mismatchCount, 1);
  });

  test('erreurs de saisie distinguées d\'une vérification échouée', () {
    expect(verifier.verify(request(seed: '')).outcome, FairnessOutcome.inputError);
    expect(verifier.verify(request(hash: '')).outcome, FairnessOutcome.inputError);
    expect(verifier.verify(request(hash: 'zzzz')).outcome, FairnessOutcome.inputError);
    final short = verifier.verify(request(hash: 'abcd'));
    expect(short.outcome, FairnessOutcome.inputError);
    expect(short.errors.single, contains('Longueur'));
  });

  test('multiplicateur affiché illisible : erreur de saisie', () {
    final result = verifier.verify(request(multiplier: 'abc'));
    expect(result.outcome, FairnessOutcome.inputError);
  });

  test('concaténation : "a" + "bc" avec séparateur vide', () {
    final result = verifier.verify(request(
      seed: 'a',
      mode: FairnessMode.concatenation,
      parts: const ['bc'],
    ));
    expect(result.outcome, FairnessOutcome.hashMatch);
  });

  test('concaténation sans élément : erreur de saisie', () {
    final result = verifier.verify(request(mode: FairnessMode.concatenation));
    expect(result.outcome, FairnessOutcome.inputError);
  });

  test('SHA-512 : longueur attendue de 128 caractères', () {
    final result = verifier.verify(request(algorithm: HashAlgorithm.sha512));
    expect(result.outcome, FairnessOutcome.inputError);
    final mismatch = verifier.verify(request(
      algorithm: HashAlgorithm.sha512,
      hash: '0' * 128,
    ));
    expect(mismatch.outcome, FairnessOutcome.hashMismatch);
    expect(mismatch.computedHash!.length, 128);
  });

  test('le message d\'incomplétude est constant', () {
    expect(
      ProvablyFairVerifier.incompleteNote,
      'Vérification incomplète : formule exacte non confirmée.',
    );
  });
}
