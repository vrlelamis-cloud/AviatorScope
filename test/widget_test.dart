import 'package:aviatorscope/app/theme.dart';
import 'package:aviatorscope/core/widgets/empty_state.dart';
import 'package:aviatorscope/core/widgets/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('l\'état vide affiche son message et ses actions', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: EmptyState(
            icon: Icons.query_stats,
            title: 'Aucune manche enregistrée',
            message: 'Ajoutez des données.',
            actions: [
              FilledButton(onPressed: () => tapped = true, child: const Text('Ajouter')),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Aucune manche enregistrée'), findsOneWidget);
    await tester.tap(find.text('Ajouter'));
    expect(tapped, isTrue);
  });

  testWidgets('la bannière d\'information affiche titre et message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: InfoBanner(
            icon: Icons.info_outline,
            color: AppColors.amber,
            title: 'Titre',
            message: 'Message',
          ),
        ),
      ),
    );
    expect(find.text('Titre'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });
}
