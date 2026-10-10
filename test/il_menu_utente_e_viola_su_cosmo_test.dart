import 'dart:io';

import 'package:esoteric_circle/features/account/vestito_del_menu_utente.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// IL MENU' UTENTE E' VIOLA SU COSMO. Ordine EA voce 17.
///
/// **Il fatto, dal fondatore**: il colore del menu' utente e' il viola per le
/// bolle, e lo sfondo e' cosmico. La 2272 mostrava *Il tuo account* su un nero
/// uniforme con bolle blu notte.
///
/// **Il censimento** sono le otto schermate che si aprono dal menu' utente.
/// Ognuna deve passare dal vestito nella sua rotta, e nessuna deve dipingere
/// il suo Scaffold di nero, che coprirebbe il cosmo.
void main() {
  const censimento = <String>[
    'lib/features/account/account_screen.dart',
    'lib/features/account/profile_screen.dart',
    'lib/features/account/privacy_policy_screen.dart',
    'lib/features/account/dati_di_nascita_screen.dart',
    'lib/features/account/notifiche_screen.dart',
    'lib/features/settings/settings_screen.dart',
    'lib/features/settings/privacy_e_permessi_screen.dart',
  ];

  test('Ogni schermata del menu\' utente veste il viola nella sua rotta', () {
    cardinaleMinimo(censimento.length, 7,
        cosa: 'file del menu\' utente censiti');
    var vestiti = 0;
    for (final percorso in censimento) {
      final testo = File(percorso).readAsStringSync();
      final n = 'VestitoDelMenuUtente('.allMatches(testo).length;
      expect(n, greaterThanOrEqualTo(1),
          reason: '$percorso apre la sua schermata senza il vestito del '
              'menu\' utente: la persona la vede fuori tinta');
      vestiti += n;
      for (final nero in const [
        // Il fondo PIENO, con la virgola: una barra a trasparenza
        // (palette.deepest.withValues) lascia vedere il cielo.
        'backgroundColor: ColorTokens.neutralDeepest,',
        'backgroundColor: palette.deepest,',
      ]) {
        expect(testo.contains(nero), isFalse,
            reason: '$percorso dipinge lo Scaffold di nero ($nero): il cosmo '
                'dietro non si vede');
      }
    }
    // Account e Privacy e dati stanno nello stesso file: due vestiti la'.
    expect(vestiti, greaterThanOrEqualTo(censimento.length + 1),
        reason: 'le rotte vestite sono $vestiti, le schermate del menu\' '
            'sono ${censimento.length + 1}');
  });

  test('La bolla e il cerchietto sono viola, non blu notte', () {
    for (final (nome, colore) in [
      ('bolla', VestitoDelMenuUtente.bolla),
      ('cerchietto', VestitoDelMenuUtente.cerchietto),
    ]) {
      final tinta = HSVColor.fromColor(colore).hue;
      // Il viola sta fra il blu (240) e il magenta (300): il blu notte di
      // prima stava sotto i 240.
      expect(tinta, inInclusiveRange(250, 295),
          reason: 'la $nome ha tinta ${tinta.toStringAsFixed(0)}: non e\' '
              'viola');
    }
  });

  testWidgets('Il vestito disegna il cosmo, e lo lascia a chi ce l\'ha gia\'',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: VestitoDelMenuUtente(
            child: Scaffold(
                backgroundColor: Colors.transparent, body: SizedBox()))));
    await tester.pump();
    expect(find.byKey(const Key('menu_utente_cosmo')), findsOneWidget,
        reason: 'il vestito non disegna il cielo dietro la schermata');
    await tester.pumpWidget(const MaterialApp(
        home: VestitoDelMenuUtente(
            soloIlColore: true, child: Scaffold(body: SizedBox()))));
    await tester.pump();
    expect(find.byKey(const Key('menu_utente_cosmo')), findsNothing,
        reason: 'chi ha gia\' il suo cosmo se ne vede disegnare un secondo');
  });
}
