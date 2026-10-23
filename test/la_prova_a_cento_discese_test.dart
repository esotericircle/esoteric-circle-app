// ignore_for_file: avoid_print
import 'dart:io';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;
import 'la_prova_a_cento_discese_comune.dart';

/// **LA PROVA A CENTO DISCESE.** Ordine DI voce 16, 13 settembre 2026.
///
/// *"Si applicano le quattro misure gia' definite nell'ordine DF, su cento
/// discese consecutive con la stessa domanda e lo stesso profilo, ripetute per
/// ciascuno dei sei temi e per cinque domande libere diverse [...] Si aggiunge
/// una quinta misura [...] E, pertinenza: su cento discese per ciascuno dei sei
/// temi, il responso contiene un riferimento riconoscibile al tema in almeno 95
/// casi su 100. Con la domanda libera, il riferimento e' al tema classificato.
/// La prova gira senza rete e con rete, e il rapporto riporta le due colonne
/// separate, perche' senza rete lavorano le vie di riserva."*
///
/// **LA STRADA E' QUELLA DELL'APP, non una sua copia.** Un Diario vero, a cui
/// cento giorni consecutivi aggiungono una discesa ciascuno: la memoria per il
/// modello e le ultime cinque scene crescono come crescono nell'app. Il tema
/// della domanda libera lo decide `LaDomandaCapita.tema`, la scena
/// `LaScenaDalModello.chiedi` e, quando non arriva, `ScenaSenzaModello.componi`,
/// con gli stessi argomenti che passa la risalita della schermata; il responso
/// e' il titolo, i tre paragrafi e il richiamo, cioe' cio' che la schermata
/// mette a schermo.
///
/// **SENZA RETE** le due chiamate al modello falliscono come fallisce una
/// chiamata senza rete, e lavorano le vie di riserva: la tabella delle parole e
/// la composizione deterministica. Gira sempre, ed e' una guardia.
///
/// **CON RETE** le due chiamate sono quelle vere, a Vertex AI, con lo stesso
/// modello, la stessa regione, la stessa istruzione e la stessa configurazione
/// della chiamata dell'app: cambia soltanto il trasporto, REST invece della
/// libreria di Firebase, che in una prova non c'e'. Gira solo quando riceve un
/// token nella variabile d'ambiente `VERTEX_TOKEN`:
///
///     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test test/la_prova_a_cento_discese_test.dart
///
/// Il token non si scrive in nessun file.
///
/// **I CASI CON RETE**, dall'ordine FC voce 11.2, stanno fra gli strumenti:
/// `tool/banchi_col_modello/la_prova_a_cento_discese_col_modello_test.dart`.
/// Il cancello non puo' eseguire un caso che vuole un token, e uno
/// strumento che spende per misurare il modello non e' una prova del ramo.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  TokenDiDiscesa.valore = token;

  test(
      'SENZA RETE: le cinque misure su cento discese, per i sei temi e per '
      'cinque domande libere', () async {
    final esiti = <EsitoDiDiscesa>[];
    for (final caso in casiDiDiscesa) {
      esiti.add(await centoDiscese(caso, conRete: false));
    }
    stampaDiDiscesa('SENZA RETE', esiti);
    // **LA GUARDIA**: sui sei temi scritti le cinque misure dell'ordine
    // devono passare tutte, senza rete, sempre. Sulle domande libere la
    // pertinenza dipende da cosa capisce la tabella, e la tabella senza rete
    // capisce una domanda su tre per dichiarazione della voce DI.02: le misure
    // si riportano, e cadono soltanto A, B, C e D.
    final cadute = [
      for (final e in esiti)
        for (final m in e.cedute(conPertinenza: e.caso.temaScritto != null))
          '${e.caso.nome}: $m',
    ];
    expect(cadute, isEmpty,
        reason: 'SENZA RETE hanno ceduto:\n${cadute.join('\n')}');
  }, timeout: const Timeout(Duration(minutes: 10)));

  /// **IL RICHIAMO NELLA SCHERMATA VERA**, alla prima discesa della storia di
  /// una persona: il Diario non ha niente, quindi non c'e' niente da
  /// richiamare. Prima dell'ordine DI voce 16 il richiamo si calcolava dopo
  /// aver segnato la discesa di oggi, e compariva sempre.
  testWidgets(
      'ALLA PRIMA DISCESA NON C E NESSUN RICHIAMO, nella schermata vera',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Il Diario finto dice una discesa gia' fatta, perche' la lente e il
    // salto del filmato arrivano dalla seconda: ma di scene non ne ha
    // nessuna, ed e' questo che il richiamo guarda.
    final diario = DiarioDelloSciamanoDiProva(1);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 13, 12),
            diario: diario,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_ombra_Lupo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_risali')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    // **IL CARDINALE**: la risalita c'e', col suo titolo.
    expect(
        find.byKey(const Key('viaggio_titolo_della_risposta')), findsOneWidget);
    expect(diario.viaggi, hasLength(1));
    expect(find.byKey(const Key('viaggio_richiamo')), findsNothing,
        reason: 'alla prima scena della sua storia la persona legge che una '
            'cosa era gia comparsa: il richiamo guarda anche la scena di '
            'oggi');
  });

  /// **LA MISURA G SENZA RETE**, ordine DQ voce 13: venti cammini di quattro
  /// discese, con la voce di casa. E' una guardia.
  test('SENZA RETE: G, venti cammini, nessuno strato ripete uno di prima',
      () async {
    final g = await misuraG(conRete: false);
    print('DQ.13 G SENZA RETE: ${g.cammini} cammini, ${g.ripetizioni.length} '
        'strati che ripetono, somiglianza peggiore '
        '${(g.peggiore * 100).toStringAsFixed(1)} per cento');
    expect(g.cammini, 20);
    expect(g.ripetizioni, isEmpty, reason: g.ripetizioni.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 5)));

  /// **IL SEGNO COL MODELLO VERO**, ordini DJ voce 08 e voce 03: dodici
  /// domande, una per animale, con l'istruzione e lo schema della chiamata
  /// dell'app. Misura quanti segni la lettura accetta, quali gesti sceglie il
  /// modello, e i token di una chiamata, che entrano nel costo.
}
