// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **IL CERCHIO SOCIALE SI APRE A QUATTORDICI ANNI, ordine EZ voce 04.**
///
/// Il fondatore il 4 ottobre 2026, "Per ogni domanda approvo tuoi
/// suggerimenti": sotto i quattordici anni le funzioni sociali non si aprono,
/// nessun consenso genitoriale si costruisce, e tutto il resto dell'app resta
/// intero. La prova ENUMERA, non guarda un caso solo:
/// - sul server, ogni porta sociale passa dal tetto, e il tetto rifiuta chi
///   non ha dichiarato quattordici anni prima di ogni altra cosa;
/// - sul telefono, ogni gesto sociale con una data di nascita di tredici anni
///   non arriva alla porta: arriva solo la porta che riceve l'eta'.
/// La sola fonte dell'eta' e' la data di nascita.
void main() {
  test(
      'EZ.04: sul server ogni porta sociale passa dalla soglia dei '
      'quattordici anni', () {
    final sorgente =
        File('functions/src/il_cerchio_sociale.ts').readAsStringSync();
    final porte = RegExp(r'export const (\w+) = onCall\(')
        .allMatches(sorgente)
        .map((m) => m.group(1)!)
        .toList();
    cardinaleMinimo(porte.length, 16,
        cosa: 'porte sociali del server',
        perche: 'Il 4 ottobre 2026 le porte sociali sono sedici.');
    final senza = <String>[];
    for (final p in porte) {
      final inizio = sorgente.indexOf('export const $p = onCall(');
      final corpo = sorgente.substring(inizio, inizio + 400);
      if (!corpo.contains('await tettoDellaPorta(uid, "$p")')) senza.add(p);
    }
    final tetto = sorgente.substring(
        sorgente.indexOf('async function tettoDellaPorta('),
        sorgente.indexOf('async function pianoDi('));
    final soglia =
        tetto.indexOf('sogliaDellEtaPassata(porta, snap.data()?.quattordici)');
    final conto = tetto.indexOf('decidiIlTetto(');
    final presenza = File('functions/src/cerchio.ts').readAsStringSync();
    print('EZ.04 LE PORTE DEL SERVER: ${porte.length}, senza la soglia '
        '${senza.length} $senza; la soglia nel tetto ${soglia >= 0}, prima '
        'del conto ${soglia >= 0 && soglia < conto}');
    expect(senza, isEmpty,
        reason: 'queste porte non passano dal tetto, e dalla soglia: $senza');
    expect(soglia, greaterThanOrEqualTo(0),
        reason: 'il tetto della porta non guarda piu\' i quattordici anni');
    expect(soglia, lessThan(conto),
        reason: 'la soglia deve venire prima del conto del tetto');
    expect(presenza.contains('if (scheda === null)'), isTrue,
        reason: 'la presenza si scrive anche sotto i quattordici anni');
  });

  test('EZ.04: l\'eta\' viene solo dalla data di nascita', () {
    final oggi = DateTime(2026, 10, 4);
    BirthIdentity nato(DateTime d) => BirthIdentity(birthMoment: d);
    expect(IlCerchioSociale.quattordiciAnni(nato(DateTime(2012, 10, 4)), oggi),
        isTrue,
        reason: 'il giorno del compleanno il Cerchio si apre');
    expect(IlCerchioSociale.quattordiciAnni(nato(DateTime(2012, 10, 5)), oggi),
        isFalse);
    expect(IlCerchioSociale.quattordiciAnni(nato(DateTime(1980, 1, 1)), oggi),
        isTrue);
    expect(IlCerchioSociale.quattordiciAnni(null, oggi), isFalse,
        reason: 'senza una data il Cerchio sociale non si apre');
    expect(
        IlCerchioSociale.quattordiciAnni(
            BirthIdentity(birthMoment: DateTime(1990), isExample: true), oggi),
        isFalse);
  });

  test(
      'EZ.04: sul telefono, a tredici anni nessun gesto sociale arriva '
      'alla porta', () async {
    SharedPreferences.setMockInitialValues({});
    final porta = PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: porta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(2013, 3, 2)),
        oggi: DateTime(2026, 10, 4));
    expect(sociale.chiusoPerEta, isTrue);
    final gesti = <String, Future<Object?> Function()>{
      'scegliIlNome': () => sociale.scegliIlNome('Lunaria'),
      'aggiornaIlProfiloNelCerchio': () => sociale.aggiorna(icona: 'segno:1'),
      'ilCodiceDellInvito': () => sociale.codice(),
      'leggiIlCodice': () => sociale.leggiIlCodice('AB12CD34'),
      'chiediIlLegame': () => sociale.chiediIlLegame(sigillo: 'K7Q2'),
      'rispondiAlLegame': () => sociale.rispondiAlLegame('u-1', 'accetta'),
      'bloccaUnaPersona': () => sociale.blocca('u-1'),
      'ilMioCerchio': () => sociale.caricaIlCerchio(),
      'compraUnPostoNelCerchio': () => sociale.compraUnPosto(),
      'laTendinaDelCerchio': () => sociale.caricaLaTendina(),
      'mandaUnSegno': () => sociale.mandaUnSegno('u-1', 'tiPenso'),
      'rispondiAlSegno': () => sociale.rispondiAlSegno('s1', risposta: 0),
      'mandaUnDono': () => sociale.mandaUnDono('u-1', 'cenno'),
      'regalaGliEos': () => sociale.regalaGliEos('u-1', 100),
      'scriviIlTokenDelCerchio': () => sociale.scriviIlToken('t'),
    };
    // Le quindici porte che un gesto apre, piu' quella del profilo che
    // riceve l'eta': le sedici del server.
    cardinaleMinimo(gesti.length, 15,
        cosa: 'gesti sociali del telefono',
        perche: 'Le porte sociali sono sedici, una delle quali riceve '
            'l\'eta\'.');
    for (final g in gesti.values) {
      await g();
    }
    final arrivate = porta.chieste.map((c) => c.$1).toList();
    final profilo = porta.chieste
        .where((c) => c.$1 == 'ilMioProfiloNelCerchio')
        .map((c) => c.$2)
        .toList();
    print('EZ.04 A TREDICI ANNI: gesti ${gesti.length}, porte arrivate al '
        'server $arrivate; il profilo ha ricevuto $profilo');
    expect(arrivate, ['ilMioProfiloNelCerchio'],
        reason: 'questi gesti arrivano al server sotto i quattordici anni');
    expect(profilo.single['quattordici'], isFalse);
    expect(profilo.single.containsKey('segno'), isFalse,
        reason: 'sotto i quattordici anni il segno non viaggia');
    final esito = await sociale.mandaUnSegno('u-1', 'tiPenso');
    expect(esito.riga, IlCerchioSociale.rigaDeiQuattordici);
  });

  test('EZ.04: a quattordici anni compiuti il Cerchio si apre da solo',
      () async {
    SharedPreferences.setMockInitialValues({});
    final porta = PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: porta);
    final nascita = BirthIdentity(birthMoment: DateTime(2012, 10, 5));
    await sociale.sincronizza(identita: nascita, oggi: DateTime(2026, 10, 4));
    expect(sociale.chiusoPerEta, isTrue);
    await sociale.sincronizza(identita: nascita, oggi: DateTime(2026, 10, 5));
    expect(sociale.chiusoPerEta, isFalse,
        reason: 'il compleanno non apre il Cerchio al primo ingresso utile');
    await sociale.caricaIlCerchio();
    expect(porta.chieste.map((c) => c.$1), contains('ilMioCerchio'));
  });
}
