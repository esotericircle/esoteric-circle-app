// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL VIAGGIO PARLA AL FEMMINILE A CHI HA SCELTO IL FEMMINILE.** Ordine DN
/// voce 08, punto 8.
///
/// *"Con un profilo femminile, nessun testo del Viaggio da' del maschile."*
/// Sul telefono di collaudo il profilo e' neutro, e la forma si sceglie solo
/// nell'onboarding: cambiarla vorrebbe dire cancellare i dati dell'app, che
/// non si fa. **La prova e' qui, sulla schermata vera**: otto discese dalla
/// soglia alla risalita, quattro con una domanda scritta, e ogni testo che la
/// schermata mostra letto col criterio del genere.
///
/// **Le due strade da cui il genere puo' entrare, e tutte e due passano.**
/// La voce di casa del Viaggio parla al neutro, tranne una frase, la ripresa
/// *"[Sei sceso|Sei scesa|Sei qui] con la domanda su tua sorella"*, che
/// arriva solo quando il modello ha capito l'oggetto della domanda: qui lo
/// capisce una finta. E i testi del modello, che qui scrive una finta che
/// sbaglia il genere apposta: la guardia deve lasciarli fuori.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown);

  testWidgets('OTTO DISCESE AL FEMMINILE, nessun testo al maschile',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    LaMarcaDelGenere.formaCorrente = CourtesyForm.feminine;
    final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 14, 12));
    var chiamateDellaScena = 0;
    Future<void> apri(int giorno) async {
      await tester.pumpWidget(MultiProvider(
        key: UniqueKey(),
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: ViaggioDelloSciamanoScreen(
              userSign: Zodiac.cancer,
              now: DateTime(2026, 9, 14 + giorno, 12),
              diario: diario,
              chiamataDellaDomanda: (_, domanda) async => jsonEncode({
                'tema': 'persona',
                'oggetto': domanda.contains('sorella') ? 'tua sorella' : 'lui',
              }),
              // **IL MODELLO CHE SBAGLIA IL GENERE**, in sei discese su otto:
              // la risposta dice *"Sei stato"* a chi ha scelto il femminile.
              chiamataDellaScena: (_, richiesta, ___) async {
                chiamateDellaScena++;
                final sbaglia = !richiesta.contains('sorella') ||
                    richiesta.contains('delusa') ||
                    richiesta.contains('cercarla');
                return jsonEncode({
                  'luogo': 'grotta',
                  'cosa': 'chiave',
                  'gesto': 'aspetta',
                  'momento': 'alba',
                  'titolo': 'Il primo passo è tuo',
                  'risposta': sbaglia
                      ? 'Sei stato tu a lasciare aperta la cosa con tua '
                          'sorella.'
                      : 'Con tua sorella il primo passo lo scegli tu.',
                  'azione': 'Stasera scrivi due righe su un foglio e mettilo '
                      'nel cassetto.',
                });
              },
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    final letti = <String>{};
    void leggi() {
      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        final s = t.data ?? t.textSpan?.toPlainText();
        if (s != null && s.trim().isNotEmpty) letti.add(s);
      }
      for (final t in tester.widgetList<RichText>(find.byType(RichText))) {
        final s = t.text.toPlainText();
        if (s.trim().isNotEmpty) letti.add(s);
      }
    }

    const temi = [
      'Una scelta da fare',
      'Una persona',
      'Un tempo che non arriva',
      'Qualcosa che è finito',
    ];
    const scritte = [
      'Mia sorella non mi parla da due anni e non so se cercarla',
      'Non so cosa pensare di mia sorella',
      'Mia sorella mi ha delusa e non so cosa fare',
      'Come mi comporto con mia sorella',
    ];
    for (var i = 0; i < 8; i++) {
      // Sul telefono si esce e si rientra: qui la schermata si rimonta.
      // Un giorno ogni tre: e' il passo con cui la ripresa col genere esce.
      await apri(i * 3);
      leggi();
      // Dopo il riconoscimento la soglia offre le tre azioni: si sceglie di
      // scendere con una domanda.
      final azione = find.byKey(const Key('viaggio_azione_scendi'));
      if (azione.evaluate().isNotEmpty) {
        await tester.ensureVisible(azione);
        await tester.tap(azione);
        await tester.pump(const Duration(milliseconds: 300));
        leggi();
      }
      final scritta = i.isOdd;
      if (scritta) {
        await tester.scrollUntilVisible(find.text('Scrivila tu'), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(find.text('Scrivila tu'));
        await tester.pump();
        await tester.enterText(
            find.byKey(const Key('viaggio_domanda')), scritte[i ~/ 2]);
        await tester.pump();
      } else {
        final tema = temi[i ~/ 2];
        await tester.scrollUntilVisible(find.text(tema), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(find.text(tema));
        await tester.pump();
      }
      await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
      await tester.tap(find.byKey(const Key('viaggio_scendi')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      final salta = find.byKey(const Key('viaggio_salta_la_discesa'));
      if (salta.evaluate().isNotEmpty) {
        await tester.tap(salta);
      } else {
        final g = await tester
            .startGesture(tester.getCenter(find.byType(Scaffold).first));
        await tester.pump(const Duration(seconds: 20));
        await g.up();
      }
      await tester.pump(const Duration(seconds: 1));
      leggi();
      final nebbia = find.byKey(const Key('viaggio_nebbia'));
      for (var k = 0; k < 80 && nebbia.evaluate().isNotEmpty; k++) {
        await tester.drag(nebbia, const Offset(120, 40));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pump(const Duration(milliseconds: 300));
      leggi();
      final ombra = find.byKey(const Key('viaggio_ombra_Lupo'));
      if (ombra.evaluate().isNotEmpty) await tester.tap(ombra);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      leggi();
      // Dopo il riconoscimento seguire l'animale porta dritto alla risposta.
      final risali = find.byKey(const Key('viaggio_risali'));
      if (risali.evaluate().isNotEmpty) await tester.tap(risali);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      leggi();
      // Il resto della risalita, sotto la piega.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pump(const Duration(milliseconds: 300));
      leggi();
    }

    // **IL CARDINALE**: le discese sono avvenute, i testi letti sono tanti,
    // il modello e' stato chiamato, e la frase di casa col genere si e' vista
    // almeno una volta. Senza quest'ultima la prova non guarda niente: la
    // prima stesura scendeva coi temi scelti, la ripresa con l'oggetto non
    // arrivava mai, e con la porta del genere forzata al maschile restava
    // verde.
    expect(diario.viaggi.length, greaterThanOrEqualTo(4));
    expect(chiamateDellaScena, greaterThanOrEqualTo(4));
    cardinaleMinimo(letti.length, 60,
        cosa: 'testi letti sulla schermata del Viaggio',
        perche: 'La prova deve aver attraversato le discese.');
    final colGenere =
        letti.where((t) => t.contains('Sei scesa con la domanda')).toList();
    final colModello =
        letti.where((t) => t.contains('il primo passo lo scegli tu')).toList();
    // **DUE CRITERI, e il secondo non passa dalla porta.** La funzione di
    // `lib` chiede alla porta del genere quale desinenza e' vietata: con la
    // porta rotta al maschile, *"Sei stato"* a chi ha scelto il femminile
    // non le risultava contrario. Il secondo criterio prende ogni forma
    // accordata e guarda se finisce al maschile.
    final maschili = [
      for (final t in letti)
        if (formeContrarieAllaForma(t, CourtesyForm.feminine).isNotEmpty)
          '${formeContrarieAllaForma(t, CourtesyForm.feminine)}: $t'
        else if (formeDelGenere(t)
            .any((f) => RegExp(r'o$').hasMatch(f.trim().split(' ').last)))
          '${formeDelGenere(t)}: $t',
    ];
    print('ORDINE DN VOCE 08, punto 8: discese ${diario.viaggi.length}, '
        'testi letti ${letti.length}, col genere di casa ${colGenere.length}, '
        'del modello ${colModello.length}, al maschile ${maschili.length}');
    expect(colGenere, isNotEmpty,
        reason: 'la frase di casa col genere non e mai arrivata a schermo, '
            'e la prova non guarda la porta del genere');
    expect(colModello, isNotEmpty,
        reason: 'la risposta del modello non e mai arrivata a schermo');
    expect(maschili, isEmpty, reason: maschili.join('\n'));
  });
}
