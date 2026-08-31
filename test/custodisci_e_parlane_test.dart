/// CUSTODISCI, LA CUSTODIA AUTOMATICA E PARLANE COL MAESTRO.
/// Ordine CG voci 06 e 08.
///
/// **Le tre pretese che questo file sorveglia.** Ogni arte che produce un
/// responso deve offrire Custodisci accanto a Condividi; una condivisione che
/// NON avviene non deve custodire niente; e ogni arte deve portare il pulsante
/// che apre la chat col responso gia' dentro, non una chat vuota.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/ricordi/arti_con_responso.dart';
import 'package:esoteric_circle/core/ricordi/conti_delle_arti.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/ricordi/scrigno_dei_custoditi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/ricordi/azioni_del_responso.dart';

/// Monta le azioni con lo scrigno e il registro veri, senza rete.
Widget _scena({
  required Future<bool> Function() condividi,
  required ScrignoDeiCustoditi scrigno,
  required RegistroDeiRicordi registro,
  String arte = 'gettata',
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ScrignoDeiCustoditi>.value(value: scrigno),
      ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: AzioniDelResponso(
          palette: MaestroPalette.caligo,
          maestro: Maestro.caligo,
          orologio: () => DateTime(2026, 8, 31, 15, 20),
          responso: ResponsoDaCustodire(
            arte: arte,
            titolo: 'La tua gettata',
            testo: 'Uruz ti chiede di non trattenere la forza che hai.',
            dati: const {'rune': 'Uruz,Ansuz,Laguz'},
          ),
          condividi: condividi,
          aperturaDellaChat: 'La mia gettata dice Uruz. Cosa vuol dire?',
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('CG.06 e CG.08: ogni arte col responso e\' censita e ha la sua apertura',
      () {
    // ignore: avoid_print
    print('ORDINE CG VOCI 06 e 08: arti con un responso '
        '${ArtiConResponso.tutte.length}, punti che condividono altro '
        '${ArtiConResponso.condividonoAltro.length}, arti vive senza responso '
        '${ArtiConResponso.senzaResponso.length}');

    final senzaFile = <String>[];
    final senzaApertura = <String>[];
    for (final arte in ArtiConResponso.tutte) {
      if (!File(arte.doveViveIlResponso).existsSync()) {
        senzaFile.add('${arte.arte} -> ${arte.doveViveIlResponso}');
      }
      if (arte.apertura.trim().isEmpty) senzaApertura.add(arte.arte);
    }
    expect(senzaFile, isEmpty,
        reason: 'queste arti dichiarano un file che non esiste piu\': '
            '$senzaFile. Un censimento che punta al vuoto non sorveglia '
            'niente');
    expect(senzaApertura, isEmpty,
        reason: 'queste arti non dicono come il responso entra nella chat: '
            '$senzaApertura. Senza, il pulsante aprirebbe una conversazione '
            'vuota e la persona dovrebbe raccontare al Maestro cosa ha appena '
            'letto');
  });

  test('CG.06: ogni arte censita col responso ha anche il suo conto', () {
    // **Due elenchi che divergono sarebbero due verita'.** Un\'arte che
    // producesse un responso senza tenere il conto comparirebbe nelle Carte e
    // sparirebbe dai riassunti della timeline.
    final scollegate = <String>[];
    for (final arte in ArtiConResponso.tutte) {
      final eUnDono = ContiDelleArti.gestiDeiDoni.values.contains(arte.arte);
      final eUnArte = ContiDelleArti.contate.any((c) => c.gesto == arte.arte);
      if (!eUnDono && !eUnArte) scollegate.add(arte.arte);
    }
    expect(scollegate, isEmpty,
        reason: 'queste arti producono un responso e non tengono un conto: '
            '$scollegate');
  });

  testWidgets('CG.06: il gesto Custodisci tiene il responso per sempre',
      (tester) async {
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();

    await tester.pumpWidget(_scena(
        condividi: () async => false, scrigno: scrigno, registro: registro));
    await tester.tap(find.byKey(const Key('responso_custodisci')));
    await tester.pumpAndSettle();

    expect(scrigno.quanti, 1,
        reason: 'il gesto non ha custodito niente');
    expect(scrigno.tutti.first.comeENato, ComeENato.gesto);
    expect(scrigno.tutti.first.testo,
        'Uruz ti chiede di non trattenere la forza che hai.');
    expect(scrigno.tutti.first.dati['rune'], 'Uruz,Ansuz,Laguz',
        reason: 'i dati per ridisegnare la scena devono restare');
    expect(registro.tutte.length, 1,
        reason: 'un responso custodito che non comparisse nella timeline '
            'sarebbe una carta senza il giorno in cui e\' nata');
  });

  testWidgets(
      'CG.06: un foglio aperto e poi chiuso NON custodisce niente',
      (tester) async {
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();

    // La porta risponde di NO, cioe' il foglio si e' aperto e poi la persona
    // lo ha chiuso senza scegliere niente.
    await tester.pumpWidget(_scena(
        condividi: () async => false, scrigno: scrigno, registro: registro));
    await tester.tap(find.byKey(const Key('responso_condividi')));
    await tester.pumpAndSettle();

    expect(scrigno.quanti, 0,
        reason: 'il magazzino deve restare vuoto. IL ROSSO SI DIMOSTRA '
            'custodendo sull\'APERTURA del foglio invece che sul suo esito, '
            'e allora questo conto diventa uno');
    expect(registro.tutte, isEmpty);
  });

  testWidgets('CG.06: una condivisione AVVENUTA custodisce da sola',
      (tester) async {
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();

    await tester.pumpWidget(_scena(
        condividi: () async => true, scrigno: scrigno, registro: registro));
    await tester.tap(find.byKey(const Key('responso_condividi')));
    await tester.pumpAndSettle();

    expect(scrigno.quanti, 1,
        reason: 'condividere e\' gia\' la dichiarazione piu\' forte che una '
            'persona possa fare su un contenuto');
    expect(scrigno.tutti.first.comeENato, ComeENato.condivisione,
        reason: 'il magazzino deve ricordare da quale delle due strade '
            'e\' arrivato');
  });

  testWidgets(
      'CG.06: custodire col gesto e poi condividere non fa due carte uguali',
      (tester) async {
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();

    await tester.pumpWidget(_scena(
        condividi: () async => true, scrigno: scrigno, registro: registro));
    await tester.tap(find.byKey(const Key('responso_custodisci')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('responso_condividi')));
    await tester.pumpAndSettle();

    expect(scrigno.quanti, 1,
        reason: 'due strade verso lo stesso magazzino non devono produrre due '
            'carte identiche nella griglia. IL ROSSO SI DIMOSTRA facendo '
            'nascere la chiave del responso a ogni tocco invece che una volta '
            'sola: allora i due tocchi cadono in due minuti diversi e le '
            'carte diventano due');
  });

  testWidgets('CG.08: il pulsante che porta in chat c\'e\' ed e\' del Maestro',
      (tester) async {
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();

    await tester.pumpWidget(_scena(
        condividi: () async => false, scrigno: scrigno, registro: registro));

    expect(find.byKey(const Key('responso_parlane')), findsOneWidget);
    expect(find.text('Parlane con Caligo'), findsOneWidget,
        reason: 'il pulsante deve nominare il Maestro proprietario dell\'arte');
  });

  test('CG.06: nessuna scadenza tocca i custoditi', () {
    // **I custoditi non scadono, ed e' una decisione dell'ordine.** Sono
    // decine e non migliaia, quindi non pesano, e sono esattamente cio' che la
    // persona ha dichiarato di voler tenere.
    final scadenze = File('functions/src/scadenze.ts').readAsStringSync();
    expect(scadenze.contains('custoditi'), isFalse,
        reason: 'una scadenza nomina i custoditi: l\'ordine CG voce 06 dice '
            'che non scadono mai. IL ROSSO SI DIMOSTRA aggiungendo una voce '
            'custoditi al listino delle scadenze');

    final telefono =
        File('lib/core/identity/scadenze_del_telefono.dart').readAsStringSync();
    expect(telefono.contains('ricordi.custoditi'), isFalse,
        reason: 'la dimenticanza del telefono porta via i custoditi a tempo: '
            'devono restare finche\' la persona non se ne va del tutto');
  });

  test('CG.06: un custodito sta sotto i mille byte, misurato sul dato vero',
      () {
    // Il caso peggiore vero: un responso lungo come quelli della Sinastria,
    // pieno di accenti, coi dati per ridisegnare la scena.
    const testoLungo =
        'Fra il tuo Sole in Bilancia e la sua Luna in Ariete c\'è una '
        'tensione che non è un difetto: è il motore di ciò che vi tiene '
        'insieme. Lei accende, tu misuri, e nessuno dei due impara niente '
        'stando dalla parte comoda. La cosa che ti conviene fare oggi è '
        'dirle la frase che stai rimandando da tre settimane, perché il '
        'silenzio qui non protegge nessuno.';
    final peggiore = RicordoCustodito(
      quando: DateTime(2026, 8, 31, 15, 20),
      arte: 'sinastria',
      maestro: 'medora',
      titolo: 'La tua sinastria con Ariana Grande',
      testo: testoLungo,
      comeENato: ComeENato.condivisione,
      dati: const {
        'punteggio': '87',
        'elementi': 'Aria,Fuoco',
        'vip': 'ariana_grande',
      },
    );
    expect(peggiore.peso, lessThan(RicordoCustodito.pesoMassimo),
        reason: 'il custodito pesa ${peggiore.peso} byte contro i '
            '${RicordoCustodito.pesoMassimo} del tetto. IL ROSSO SI DIMOSTRA '
            'custodendo l\'immagine invece del testo: un PNG pesa mille volte '
            'tanto');
  });
}
