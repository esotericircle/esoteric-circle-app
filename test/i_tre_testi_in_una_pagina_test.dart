// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/legal/condizioni_uso.dart';
import 'package:esoteric_circle/core/legal/pagina_legale.dart';
import 'package:esoteric_circle/core/legal/privacy_policy.dart';
import 'package:esoteric_circle/features/account/consensi_della_registrazione.dart';
import 'package:esoteric_circle/features/account/privacy_policy_screen.dart';
import 'package:esoteric_circle/features/account/vestito_del_menu_utente.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// I TRE TESTI IN UNA PAGINA. Ordine EA voce 18, 20 settembre 2026.
///
/// **La decisione del fondatore**: *"ok per l'unione delle tre pagine"*.
/// Privacy policy, condizioni d'uso e disclaimer stavano in tre posti
/// diversi, e le condizioni non stavano da nessuna parte, perche' non
/// esistevano: il codice dichiarava per iscritto che il Cerchio non aveva
/// termini di servizio.
///
/// **Cosa pretende questa guardia.** Che le tre parti siano nella stessa
/// pagina, ognuna col suo titolo e la sua ancora; che nessun contenuto si sia
/// perso; che la privacy policy resti raggiungibile com'era, perche' e' la
/// porta che l'app chiama da tre punti; e che **il disclaimer si dica
/// all'ingresso**, come vuole CLAUDE.md, cioe' alla fine del Risveglio e nel
/// foglio della registrazione, e non su ogni carta.
void main() {
  test('le tre parti stanno in una pagina sola, ognuna con la sua ancora', () {
    cardinaleMinimo(paginaLegale.length, 3,
        cosa: 'parti della pagina legale',
        perche: 'Senza le tre parti questa prova guarderebbe una pagina '
            'vuota.');
    final ancore = paginaLegale.map((p) => p.parte.ancora).toSet();
    expect(ancore, {'privacy', 'condizioni', 'disclaimer'});
    for (final parte in paginaLegale) {
      expect(parte.sezioni, isNotEmpty,
          reason: '${parte.parte.titolo} non ha nessuna sezione');
      expect(parte.apertura.trim(), isNotEmpty,
          reason: '${parte.parte.titolo} non ha la riga che apre');
    }
  });

  test('nessun contenuto dei tre testi e\' andato perso', () {
    // **LA POLICY PER INTERO**, sezione per sezione, dentro la pagina unica.
    final dentroLaPagina =
        paginaLegale.expand((p) => p.sezioni).map((s) => s.titolo).toSet();
    for (final s in sezioniDellaPolicy) {
      expect(dentroLaPagina.contains(s.titolo), isTrue,
          reason: 'la sezione "${s.titolo}" della privacy policy non e\' '
              'nella pagina unica');
    }
    for (final s in sezioniDelleCondizioni) {
      expect(dentroLaPagina.contains(s.titolo), isTrue,
          reason: 'la sezione "${s.titolo}" delle condizioni non c\'e\'');
    }
    // **E IL DISCLAIMER E' LO STESSO TESTO DELLE ARTI**, non una seconda
    // copia che un giorno direbbe un'altra cosa.
    final corpi =
        paginaLegale.expand((p) => p.sezioni).map((s) => s.corpo).toList();
    expect(corpi.any((c) => c.contains(ArtCatalog.disclaimerCornice)), isTrue,
        reason: 'la cornice delle arti non e\' nella pagina legale');
    print('ORDINE EA VOCE 18: sezioni nella pagina unica ${corpi.length}');
  });

  test('la privacy policy resta raggiungibile, e le altre due con lei', () {
    // La rotta e' quella di prima, che l'app chiama da tre punti.
    final rotta = PrivacyPolicyScreen.route();
    expect(rotta, isNotNull);
    for (final parte in ParteLegale.values) {
      expect(PrivacyPolicyScreen.route(parte: parte), isNotNull,
          reason: 'la pagina non si apre su ${parte.titolo}');
    }
    // E chi cerca un'ancora che non esiste trova la privacy, non il vuoto.
    expect(parteDallAncora('quello-che-non-c-e'), ParteLegale.privacy);
    expect(parteDallAncora('disclaimer'), ParteLegale.disclaimer);
  });

  testWidgets('la pagina mostra le tre parti, una sotto l\'altra',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Col vestito del menu' utente, che e' quello che monta la rotta vera.
    await tester.pumpWidget(const MaterialApp(
        home: VestitoDelMenuUtente(
            soloIlColore: true, child: PrivacyPolicyScreen())));
    await tester.pump();
    for (final parte in ParteLegale.values) {
      expect(find.text(parte.titolo), findsWidgets,
          reason: 'la pagina non porta il titolo ${parte.titolo}');
      expect(
          find.byKey(Key('pagina_legale_vai_${parte.ancora}')), findsOneWidget,
          reason: 'manca la porta verso ${parte.titolo}');
    }
  });

  testWidgets('il disclaimer si dice alla registrazione, con la sua porta',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: VestitoDelMenuUtente(
            soloIlColore: true,
            child: Scaffold(body: ConsensiDellaRegistrazione()))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('consenso_disclaimer')), findsOneWidget,
        reason: 'la registrazione non dice piu\' la cornice delle arti, che '
            'CLAUDE.md vuole detta una volta all\'ingresso');
    final testo = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .join(' ');
    expect(testo.contains(ArtCatalog.disclaimerCornice), isTrue,
        reason: 'il disclaimer a video non e\' quello delle arti');
    expect(testo.contains('condizioni d\'uso'), isTrue,
        reason: 'la riga non nomina le condizioni d\'uso');
    expect(testo.contains('privacy policy'), isTrue);
  });

  test('e si dice anche alla fine del Risveglio, una volta sola', () {
    // **L'ULTIMO PASSO DEL RITO**, non una schermata in piu': il Sigillo
    // chiude il Risveglio, e li' la cornice si dice.
    // **SI GUARDA IL CODICE, NON I COMMENTI**: la riga che spiega da dove
    // viene il testo nomina la costante, e una guardia che pescasse il
    // proprio commento sarebbe verde su una schermata muta. Colto qui:
    // togliendo la cornice dal Risveglio la prova restava verde.
    final sigillo = senzaCommenti(
        File('lib/features/onboarding/sigillo_step.dart').readAsStringSync());
    expect(sigillo.contains('ArtCatalog.disclaimerCornice'), isTrue,
        reason: 'il Risveglio non dice piu\' la cornice delle arti');
    expect(sigillo.contains("Key('risveglio_disclaimer')"), isTrue);
    // E NON si dice su ogni carta: le arti lo mostrano solo dove la cornice
    // vive gia' (Privacy e permessi e la pagina legale).
    var quanti = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (senzaCommenti(f.readAsStringSync())
          .contains('ArtCatalog.disclaimerCornice')) {
        quanti++;
      }
    }
    print('ORDINE EA VOCE 18: file che dicono la cornice $quanti');
    expect(quanti, lessThanOrEqualTo(5),
        reason: 'la cornice e\' detta in $quanti file: si dice una volta '
            'all\'ingresso, una alla registrazione, e vive nella pagina '
            'legale e in Privacy e permessi');
  });
}
