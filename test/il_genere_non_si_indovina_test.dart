import 'dart:io';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/scena_del_ritrovamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'le_parole_di_chi_legge.dart';
import 'sorgenti_di_lib.dart';

/// IL GENERE NON SI INDOVINA. Ordine CF voce 05.
///
/// **Il fatto del fondatore, verbatim**: "ho reinserito l'email gia'
/// registrata e dopo avermi dato il benvenuto (anzi, mi ha detto BENTORNATA
/// Mauro al femminile)".
///
/// **La causa, misurata e non dedotta.** `ProfileController` nasceva con un
/// profilo d'esempio che dichiarava `CourtesyForm.feminine`, e quel profilo
/// non e' solo quello della Demo: e' lo stato INIZIALE del controller in
/// tutta l'app, perche' `app.dart` lo costruisce senza argomenti e poi chiama
/// `load()`. Su un telefono appena reinstallato non c'e' niente da caricare,
/// quindi la forma restava femminile, e il riconoscimento rimetteva il nome
/// vero senza toccarla.
///
/// **Le due prove guardano due cose diverse, di proposito.** La prima e' il
/// caso vero del fondatore; la seconda ENUMERA le stringhe che dichiarano un
/// genere rivolgendosi alla persona e pretende che vivano solo dentro le
/// porte del genere, cosi' vale anche per quelle che nasceranno domani.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'a chi rientra senza profilo il Cerchio non attribuisce un '
      'genere', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    // **IL PROFILO E' QUELLO VERO, appena costruito e mai caricato**, cioe'
    // esattamente lo stato di un telefono appena reinstallato. Passarne uno
    // finto qui vorrebbe dire provare un'altra cosa.
    final profilo = ProfileController();
    final ritrovamento = Ritrovamento.da(
      CamminoDaCustodire(
        identita: IdentitaDaCustodire(
          nome: 'Mauro',
          giorno: DateTime(1972, 5, 20),
          ora: '09:00',
          luogo: 'Roma',
        ),
        sigilli: const {},
      ),
      saldoEos: 250,
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<ProfileController>.value(value: profilo),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: ScenaDelRitrovamento(
          ritrovamento: ritrovamento,
          onProsegui: () {},
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));

    final scritte = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final saluto = scritte.firstWhere(
        (s) => s.contains('Cerchio') && s.contains('Mauro'),
        orElse: () => scritte.isEmpty ? '' : scritte.first);
    // ignore: avoid_print
    print('ORDINE CF VOCE 05: a chi rientra senza profilo il saluto dice '
        '"$saluto"');
    for (final forma in const ['Bentornata', 'Bentornato']) {
      expect(saluto.contains(forma), isFalse,
          reason: 'il saluto dice "$saluto": il Cerchio ha attribuito un '
              'genere a una persona di cui non sa niente, e sul telefono del '
              'fondatore quel genere era sbagliato');
    }
    expect(saluto.contains('Mauro'), isTrue,
        reason: 'il nome custodito non arriva nel saluto: la prova sopra '
            'passerebbe anche con la scena vuota');
  });

  /// **LE PORTE DEL GENERE, dichiarate per nome.** Ordine DL voci 01 e 06:
  /// il file che decide e il file dell'enum, che porta il benvenuto
  /// concordato. Qui c'erano anche `identity_controller.dart`, col suo
  /// secondo enum tolto, e i due `switch` dell'onboarding, che adesso passano
  /// dalla marca.
  const porte = <String>{
    'lib/core/chat/la_marca_del_genere.dart',
    'lib/core/chat/user_profile.dart',
  };

  /// **LA GUARDIA DIVENTA UN DIZIONARIO.** Ordine DL voce 06.
  ///
  /// Qui c'erano due coppie, *Benvenuto* e *Bentornato*, e fuori da quelle due
  /// parole l'app diceva a chi legge di essere un uomo o una donna in
  /// centodieci stringhe senza che nessuna prova se ne accorgesse: *"Sei
  /// scesa con questa domanda"* nei Tarocchi, *"Chiedi a te stesso"* nel
  /// Viaggio, *"Sei nato"* in sei file. Il dizionario e il criterio stanno in
  /// `le_parole_di_chi_legge.dart`, e li usa anche il censimento dell'ordine.
  ///
  /// **La regola**: nessuna stringa di `lib` rivolta alla persona contiene
  /// una forma del dizionario fuori da una marca `[m|f|n]`. Le sole eccezioni
  /// sono le porte qui sopra.
  test('nessuna stringa dice il genere di chi legge fuori da una marca', () {
    final colpe = <String>[];
    var letterali = 0;
    var marcate = 0;
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      for (final l in letteraliDi(f.readAsStringSync())) {
        letterali++;
        if (marcaDelGenere.hasMatch(l.testo)) marcate++;
        final forme = formeDelGenere(l.testo);
        if (forme.isEmpty || porte.contains(percorso)) continue;
        colpe.add('$percorso:${l.riga} $forme');
      }
    }
    // ignore: avoid_print
    print('ORDINE DL VOCE 06: letterali guardati $letterali, con una marca '
        '$marcate, con il genere fuori da una marca ${colpe.length}');
    cardinaleMinimo(letterali, 18000,
        cosa: 'letterali di stringa in lib',
        perche: 'il 14 settembre 2026 erano 20.544: sotto diciottomila il '
            'lettore dei sorgenti ha smesso di leggere');
    expect(colpe, isEmpty,
        reason: 'queste stringhe dicono a chi legge di essere un uomo o una '
            'donna, a chiunque: marcale con [maschile|femminile|neutro], '
            'oppure scrivile senza genere. ${colpe.join('\n')}');
  });

  test('il dizionario prende le forme che deve prendere', () {
    // **LA GUARDIA DELLA GUARDIA**: se il criterio si stringesse troppo, la
    // prova sopra diventerebbe verde senza guardare niente.
    for (final frase in const [
      'Sei scesa con questa domanda',
      'Chiedi a te stesso quale racconterai meglio',
      'Il giorno in cui sei nato',
      'Restare solo',
      'Non ti serve essere sicuro',
      'Se sei da solo, un incontro leggero',
      'fatti trovare pronto',
      'Ti senti poco riconosciuto',
      'Bentornata, Sofia',
      'aspettare di sentirti più pronta',
      'è non accorgersi di essere arrivata',
    ]) {
      expect(formeDelGenere(frase), isNotEmpty,
          reason: '"$frase" dice il genere di chi legge e il criterio non lo '
              'vede');
    }
    for (final frase in const [
      'Te lo sei portato dietro',
      'Oggi il velo cade da solo',
      'Sei socievole, con uno sguardo che va in profondità',
      'la foto, senza mai essere caricata',
      'Un seme che sia pronto a fruttare',
      '[Sei arrivato|Sei arrivata|Sei qui] fin qui',
      'sei adesso nel tuo giorno',
    ]) {
      expect(formeDelGenere(frase), isEmpty,
          reason: '"$frase" non dice il genere di chi legge, e il criterio '
              'lo prende');
    }
  });

  test('ogni marca del genere in lib ha tre campi', () {
    // Una marca rotta a schermo esce con le sue quadre: meglio fermarla qui.
    final rotte = <String>[];
    var quante = 0;
    final aperta = RegExp(r'\[[^\[\]]*\|[^\[\]]*\]');
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      for (final l in letteraliDi(f.readAsStringSync())) {
        for (final m in aperta.allMatches(l.testo)) {
          quante++;
          if ('|'.allMatches(m.group(0)!).length != 2) {
            rotte.add('$percorso:${l.riga} ${m.group(0)}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DL VOCE 02: marche del genere in lib $quante, rotte '
        '${rotte.length}');
    expect(rotte, isEmpty, reason: 'marche senza tre campi: $rotte');
  });

  test('la porta del genere porta ancora le due declinazioni', () {
    // **SENZA QUESTA PROVA** la prima si potrebbe far passare togliendo il
    // maschile o il femminile dalla porta, e allora il Cerchio smetterebbe di
    // parlare a chi ha scelto quella forma invece di indovinare.
    final testo = File('lib/core/chat/user_profile.dart').readAsStringSync();
    for (final forma in const ['Benvenuto', 'Benvenuta']) {
      expect(testo.contains(forma), isTrue,
          reason: 'la porta del genere ha perso "$forma"');
    }
  });
}
