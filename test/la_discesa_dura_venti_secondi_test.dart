import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LA DISCESA DURA VENTI SECONDI, MISURATI COL CRONOMETRO.**
/// Ordine DG voce 06, 12 settembre 2026.
///
/// **Parole del fondatore, 11 settembre 2026:** *"il viaggio in discesa fa
/// veramente cagare ed e' lunghissimo"*, e prima ancora *"dura ancora troppo,
/// devi ridurre la discesa a 20 secondi"*.
///
/// **PERCHE' NON SI LEGGE LA COSTANTE.** Perche' `primaDiscesa` diceva venti
/// secondi **anche quando la discesa ne durava quarantasei**: il numero
/// governava il passo di un `Timer`, e il tempo vero e' il passo moltiplicato
/// per quanti battiti servono ad arrivare in fondo. Leggere
/// `primaDiscesa.inSeconds == 20` proverebbe che una costante vale venti, che
/// e' la stessa cosa che il fondatore aveva letto nel codice mentre teneva il
/// dito premuto per tre quarti di minuto.
///
/// **COSA MISURA QUESTA GUARDIA.** Tiene il dito premuto e **conta il tempo
/// che fa avanzare all'orologio della prova** finche' la fase non cambia. Il
/// numero che esce e' il tempo che una persona passa a tenere premuto.
///
/// **E LE MISURA TUTTE E DUE**, la prima discesa e quella conosciuta: l'ordine
/// DG voce 06 le ha portate tutte e due a venti, perche' *"nove non e' venti,
/// e la discesa conosciuta era diventata una scorciatoia"*.
///
/// **VISTA ROSSA** riportando `discesaConosciuta` a nove secondi: la prova ha
/// detto che la seconda discesa finiva dopo 9,06 secondi invece di 20.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// **QUANTO SI CONCEDE DI SCARTO, in secondi.** Un battito e mezzo del
  /// `Timer` che muove la discesa, cioe' un decimo di secondo: la discesa
  /// avanza a scatti da sessanta millisecondi, e l'ultimo scatto puo' sforare.
  const scarto = 0.2;

  /// **IL TEMPO CHE L'ORDINE CHIEDE.**
  const quantoDeveDurare = 20.0;

  /// **OLTRE QUANTO SI SMETTE DI ASPETTARE.** Il doppio abbondante: se la
  /// discesa non e' finita dopo quarantacinque secondi di dito premuto, questa
  /// prova deve **dirlo**, non girare per sempre.
  const oltreNonSiAspetta = 45.0;

  Future<double> quantoDuraLaDiscesa(WidgetTester tester, int discese) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: ViaggioDelloSciamanoScreen(
              // Una chiave diversa per ogni numero di discese, o Flutter riusa
              // lo stesso State e il diario resta quello del primo giro.
              key: ValueKey(discese),
              userSign: Zodiac.gemini,
              now: DateTime(2026, 9, 12, 12),
              diario: DiarioDelloSciamanoDiProva(discese),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // La via piu' corta per arrivare alla discesa: si scende soltanto per
    // incontrarlo, cosi' non serve scegliere ne' scrivere una domanda.
    await tester.tap(find.text('Solo incontro'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // **IL PULSANTE STA SOTTO LA PIEGA**, e un tocco a vuoto e' un tocco che
    // non fa niente: si porta in vista prima di toccarlo.
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    expect(find.byKey(const Key('viaggio_dito')), findsOneWidget,
        reason: 'NON SI E ENTRATI NELLA DISCESA, e questa prova starebbe per '
            'misurare il tempo di un altra schermata');

    // **IL DITO SI POSA E NON SI ALZA PIU'.**
    final dito = find.byKey(const Key('viaggio_dito'));
    final gesto = await tester.startGesture(tester.getCenter(dito));

    // **IL CRONOMETRO.** Si conta il tempo che si fa avanzare, non i battiti:
    // sono i secondi che una persona passa a tenere premuto.
    var passati = 0.0;
    const passo = Duration(milliseconds: 60);
    while (find.byKey(const Key('viaggio_dito')).evaluate().isNotEmpty &&
        passati < oltreNonSiAspetta) {
      await tester.pump(passo);
      passati += passo.inMilliseconds / 1000;
    }
    await gesto.up();
    return passati;
  }

  testWidgets('la prima discesa dura venti secondi col dito premuto',
      (tester) async {
    final durata = await quantoDuraLaDiscesa(tester, 0);
    // ignore: avoid_print
    print('ORDINE DG VOCE 06: la PRIMA discesa e finita dopo '
        '${durata.toStringAsFixed(2)} secondi di dito premuto');
    expect(durata, lessThan(quantoDeveDurare + scarto),
        reason: 'LA PRIMA DISCESA DURA ${durata.toStringAsFixed(2)} SECONDI, '
            'e l ordine ne concede $quantoDeveDurare. Il fondatore l ha '
            'misurata col dito: "il viaggio in discesa fa veramente cagare ed '
            'e lunghissimo".');
    expect(durata, greaterThan(quantoDeveDurare - 1),
        reason: 'LA PRIMA DISCESA DURA SOLO ${durata.toStringAsFixed(2)} '
            'SECONDI. Sotto i venti la galleria non fa in tempo a dire cio '
            'che ha da dire, e la discesa si legge come una dissolvenza.');
  });

  testWidgets('anche la discesa conosciuta dura venti secondi', (tester) async {
    final durata = await quantoDuraLaDiscesa(tester, 1);
    // ignore: avoid_print
    print('ORDINE DG VOCE 06: la discesa CONOSCIUTA e finita dopo '
        '${durata.toStringAsFixed(2)} secondi di dito premuto');
    expect(durata, lessThan(quantoDeveDurare + scarto),
        reason: 'LA DISCESA CONOSCIUTA DURA ${durata.toStringAsFixed(2)} '
            'SECONDI invece di $quantoDeveDurare.');
    expect(durata, greaterThan(quantoDeveDurare - 1),
        reason: 'LA DISCESA CONOSCIUTA DURA SOLO '
            '${durata.toStringAsFixed(2)} SECONDI. L ordine DE voce 06 aveva '
            'gia fissato venti, e nove era diventata una scorciatoia: '
            '"meno della meta della prima" non e cio che il fondatore ha '
            'chiesto.');
  });

  /// **LA DISSOLVENZA CHE INTRODUCE LA NEBBIA.** Ordine DG voce 09,
  /// 12 settembre 2026.
  ///
  /// **Parole del fondatore:** *"quando si scende, dovrebbe esserci una
  /// dissolvenza che introduce la nebbia"*.
  ///
  /// **Com'era.** Al colpo di gong dei venti secondi la fase passava da
  /// `discesa` a `nebbia` **in un fotogramma**: il tunnel spariva e al suo
  /// posto compariva la nebbia gia' fatta. L'unico posto del Viaggio dove si
  /// vedeva la macchina.
  ///
  /// **COSA MISURA.** L'opacita' **vera** della galleria che svanisce, letta
  /// dall'albero montato fotogramma per fotogramma. Tre cose insieme:
  ///
  /// - al primo fotogramma della nebbia la galleria c'e' ancora **quasi
  ///   intera**, o non e' una dissolvenza, e' un taglio;
  /// - l'opacita' **scende**, e a meta' strada sta in mezzo;
  /// - alla fine del tempo dichiarato la galleria **non c'e' piu'**.
  ///
  /// **E l'istruzione arriva a dissolvenza finita**, non prima: dire *"passa
  /// la mano"* mentre si vede ancora la galleria sarebbe dire una cosa falsa.
  ///
  /// **PERCHE' NON BASTA CHE ESISTA UN `Opacity`.** Perche' un `Opacity` che
  /// vale zero dal primo fotogramma e' il taglio secco di prima con un nome
  /// nuovo: e' il guasto che il velo della lente ha gia' pagato due volte sul
  /// 767f596c, dove le scale di animazione valgono zero.
  ///
  /// **VISTA ROSSA** facendo saltare la dissolvenza a uno subito, cioe'
  /// `_entraLaNebbia = 1` al posto della chiamata al battito: la prova ha
  /// detto che al primo fotogramma la galleria era gia' sparita.
  testWidgets('la nebbia entra in dissolvenza, e la galleria svanisce',
      (tester) async {
    await quantoDuraLaDiscesa(tester, 0);

    const chiave = Key('viaggio_dissolvenza_della_nebbia');
    double? opacitaAdesso() {
      final trovati = find.byKey(chiave).evaluate();
      if (trovati.isEmpty) return null;
      return tester.widget<Opacity>(find.byKey(chiave)).opacity;
    }

    // **UNO: al primo fotogramma la galleria c'e' ancora quasi intera.**
    final allInizio = opacitaAdesso();
    expect(allInizio, isNotNull,
        reason: 'LA GALLERIA E SPARITA NELLO STESSO FOTOGRAMMA in cui e '
            'arrivata la nebbia: non c e nessuna dissolvenza, c e il taglio '
            'secco che il fondatore ha chiesto di togliere.');
    expect(allInizio!, greaterThan(0.9),
        reason: 'AL PRIMO FOTOGRAMMA DELLA NEBBIA la galleria e gia opaca al '
            '${(allInizio * 100).toStringAsFixed(0)} per cento. Una '
            'dissolvenza che comincia a meta non e una dissolvenza.');

    // **DUE: scende.** A meta del tempo dichiarato sta in mezzo.
    final meta = ViaggioDelloSciamanoScreen.quantoDuraLaDissolvenza ~/ 2;
    await tester.pump(meta);
    final aMeta = opacitaAdesso();
    expect(aMeta, isNotNull,
        reason: 'A META DISSOLVENZA la galleria e gia sparita del tutto.');
    expect(aMeta!, lessThan(allInizio),
        reason: 'LA GALLERIA NON SVANISCE: a meta strada e opaca quanto '
            'all inizio (${aMeta.toStringAsFixed(2)} contro '
            '${allInizio.toStringAsFixed(2)}).');

    // **L INSTRUZIONE NON C E ANCORA**, perche la galleria si vede ancora.
    expect(find.byKey(const Key('viaggio_istruzione_nebbia')), findsNothing,
        reason: 'L ISTRUZIONE "Passa la mano" E GIA A SCHERMO mentre si vede '
            'ancora la galleria, e sta dicendo una cosa falsa.');

    // **TRE: alla fine non c e piu.**
    await tester.pump(ViaggioDelloSciamanoScreen.quantoDuraLaDissolvenza);
    expect(opacitaAdesso(), isNull,
        reason: 'LA GALLERIA C E ANCORA dopo il tempo dichiarato della '
            'dissolvenza: la nebbia non e mai entrata del tutto.');
    expect(find.byKey(const Key('viaggio_istruzione_nebbia')), findsOneWidget,
        reason: 'A DISSOLVENZA FINITA l istruzione non c e: chi guarda la '
            'nebbia non sa che si apre passando la mano.');

    // ignore: avoid_print
    print('ORDINE DG VOCE 09: la galleria parte da '
        '${allInizio.toStringAsFixed(2)}, a meta dei '
        '${ViaggioDelloSciamanoScreen.quantoDuraLaDissolvenza.inMilliseconds} '
        'millisecondi vale ${aMeta.toStringAsFixed(2)}, e alla fine non c e '
        'piu');
  });
}
