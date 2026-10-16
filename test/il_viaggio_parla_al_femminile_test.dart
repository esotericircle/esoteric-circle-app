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
    var silenzi = 0;
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
      // **DENTRO IL CAMMINO LA DOMANDA NON SI SCEGLIE**, ordine DQ voce 01:
      // dalla seconda discesa si legge, e si tocca Scendi. La prima e' una
      // domanda scritta, perche' l'oggetto arrivi a tutti e quattro gli
      // strati; dopo il riconoscimento si alternano le due vie, come prima.
      final nelCammino = find
          .byKey(const Key('viaggio_la_domanda_del_cammino'))
          .evaluate()
          .isNotEmpty;
      // **DUE CAMMINI, E SONO I DUE MONDI CHE LA VOCE 07 HA SEPARATO.**
      // Ordine DR voce 07, misurato il 16 settembre 2026.
      //
      // **Il fatto che ha costretto a riscrivere questa riga**: il cammino
      // prende la domanda dal PRIMO giro e se la tiene per tutti gli altri.
      // Da questa voce, una domanda scritta a mano a cui il modello risponde
      // male non cade piu' sulla voce di casa: l'app tace. Con la vecchia
      // alternanza il primo giro scriveva la domanda a cui il modello
      // sbaglia apposta, quindi **tutte e otto** le discese finivano in
      // silenzio e questa prova non misurava piu' niente.
      //
      // **I primi quattro giri scelgono un tema**: li' il modello sbaglia il
      // genere, il suo testo viene scartato e parla la voce di casa, che e'
      // la frase che questa prova deve leggere. Dopo il riconoscimento
      // comincia un cammino nuovo, e **gli ultimi quattro scrivono una
      // domanda a cui il modello risponde bene**, cosi' a schermo arriva
      // anche il testo del modello. Nessuno dei due mondi finisce in
      // silenzio, ed e' cio' che la voce 07 promette: si tace solo quando
      // chi ha scritto la sua domanda riceve una risposta che non regge.
      final scritta = i >= 4;
      if (nelCammino) {
        leggi();
      } else if (scritta) {
        await tester.scrollUntilVisible(find.text('Scrivila tu'), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(find.text('Scrivila tu'));
        await tester.pump();
        // **LA DOMANDA A CUI IL MODELLO RISPONDE BENE**: contiene "sorella"
        // e non contiene ne' "delusa" ne' "cercarla", che sono le due parole
        // su cui il modello finto sbaglia il genere apposta.
        await tester.enterText(
            find.byKey(const Key('viaggio_domanda')), scritte[1]);
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
      // **IL SILENZIO SI CONTA QUI, dove si vede davvero.** Ordine DR voce
      // 07: e' una schermata che una persona legge, quindi vale la stessa
      // regola sul genere di tutte le altre, e i suoi testi sono gia' dentro
      // `letti`.
      if (find.byKey(const Key('viaggio_silenzio')).evaluate().isNotEmpty) {
        silenzi++;
      }
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
    //
    // **E IL NUMERO DELLE DISCESE E' CAMBIATO, ordine DR voce 07.** Questa
    // prova fa otto giri: cinque con la domanda scritta a mano e tre con un
    // tema scelto dalla tavola. Il modello finto sbaglia il genere apposta,
    // ed e' il cuore della prova. Dalla voce 07 una risposta del modello
    // scartata **con la domanda scritta a mano** non cade piu' sulla voce di
    // casa: l'app tace e la discesa non si consuma. Quindi i cinque giri
    // scritti non producono nessun responso **per costruzione**, e pretendere
    // quattro discese qui vorrebbe dire pretendere che la voce 07 non esista.
    //
    // **La domanda della guardia non cambia**: nessun testo al maschile, in
    // nessuna delle due strade. Il cardinale si sposta su cio' che oggi si
    // puo' contare, e **il silenzio entra nel conto** invece di restare fuori:
    // anche la sua schermata e' testo che qualcuno legge.
    expect(diario.viaggi.length, greaterThanOrEqualTo(4));
    expect(chiamateDellaScena, greaterThanOrEqualTo(4));
    // **E NESSUN SILENZIO SI INTRUFOLA.** Ordine DR voce 07: il silenzio e'
    // solo per chi ha scritto la sua domanda. Questo cammino nasce da un
    // tema, quindi la voce di casa deve parlare tutte le volte, e un silenzio
    // qui vorrebbe dire che la voce 07 ha invaso la strada che non e' sua.
    expect(silenzi, 0,
        reason: 'il silenzio e arrivato $silenzi volte, e qui non deve mai '
            'arrivare: il primo cammino nasce da un tema, e nel secondo il '
            'modello risponde bene. Se compare, la voce 07 sta invadendo una '
            'strada che non e la sua');
    cardinaleMinimo(letti.length, 60,
        cosa: 'testi letti sulla schermata del Viaggio',
        perche: 'La prova deve aver attraversato le discese.');
    // **LA GRANDEZZA MISURATA E' LA FORMA ACCORDATA, NON UNA FRASE.**
    // Ordine DR voce 07: la ripresa adesso la sceglie un seme e ruota finche'
    // ne trova una che non ripeta le prime parole di uno strato gia' scritto,
    // quindi **una frase precisa puo' non uscire mai** in otto discese.
    // Legare la guardia a *"Sei scesa con la domanda"* voleva dire legarla a
    // un gettone invece che al fatto: cio' che conta e' che a schermo sia
    // arrivata almeno una forma accordata col genere, e che sia quella
    // giusta. La seconda meta' la misura `maschili`, qui sotto.
    final colGenere = letti.where((t) => formeDelGenere(t).isNotEmpty).toList();
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
        'silenzi $silenzi, testi letti ${letti.length}, col genere di casa '
        '${colGenere.length}, del modello ${colModello.length}, al maschile '
        '${maschili.length}');
    expect(colGenere, isNotEmpty,
        reason: 'la frase di casa col genere non e mai arrivata a schermo, '
            'e la prova non guarda la porta del genere');
    expect(colModello, isNotEmpty,
        reason: 'la risposta del modello non e mai arrivata a schermo');
    expect(maschili, isEmpty, reason: maschili.join('\n'));
  });
}
