// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **GLI ENIGMI RISPETTANO LE REGOLE DELL'ORDINE FF.** 8 ottobre 2026.
///
/// Le guardie sul codice dei giochi del Cerchio: cio' che nessuna prova a
/// video vede, perche' riguarda chi legge cosa e cosa si puo' ordinare.
void main() {
  final porte = File('functions/src/il_cerchio_sociale.ts').readAsStringSync();
  final enigmi = File('functions/src/gli_enigmi.ts').readAsStringSync();

  /// Il corpo di una porta del server, dalla sua testa alla prossima.
  String corpoDi(String porta) {
    final i = porte.indexOf('export const $porta = onCall(');
    expect(i, greaterThan(0), reason: 'la porta $porta non c\'e\'');
    // Fino alla chiusura della porta: le funzioni d'aiuto che seguono non
    // sono il suo corpo.
    final j = porte.indexOf('\n});', i);
    return porte.substring(i, j < 0 ? porte.length : j);
  }

  test('FF.06.1 nessuna classifica su una qualita\' personale', () {
    // **SI SFIDA QUELLO CHE LE PERSONE FANNO, MAI QUELLO CHE SONO.** Una
    // riga che nomina una classifica accanto a una qualita' della persona e'
    // la classifica vietata, nel telefono o sul server.
    final vietate = RegExp(
        r'(spiritual|compatib|\bpur[aoie]\b|purezza|profond|valore della persona|'
        r'bellezz|intelligen|evolut|illuminat[oaie] di pi)',
        caseSensitive: false);
    final sorgenti = [
      ...sorgentiDiLib(),
      ...Directory('functions/src')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.ts') && !f.path.endsWith('.test.ts')),
    ];
    cardinaleMinimo(sorgenti.length, quantiFileHaLib + 30,
        cosa: 'sorgenti di lib e del server',
        perche: 'lib e functions/src insieme');
    final colpe = <String>[];
    for (final f in sorgenti) {
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        // "Classifica" e "classifiche": non il classificatore dei volti.
        if (!RegExp(r'classific(a|he)\b', caseSensitive: false).hasMatch(r)) {
          continue;
        }
        if (vietate.hasMatch(r)) colpe.add('${f.path}:${i + 1} $r');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
    // E la classifica che esiste ordina solo per gesti compiuti.
    expect(
        enigmi,
        contains(
            'export const CAMPI_DELLE_CLASSIFICHE = ["indovinati", "passi"]'));
    final classifica = enigmi.substring(
        enigmi.indexOf('export function laClassifica'),
        enigmi.indexOf('// IL PELLEGRINAGGIO'));
    expect(classifica, contains('b.indovinati - a.indovinati'));
  });

  test('FF.02.6 d) i punti che leggono il Ritratto, enumerati', () {
    // Sul server il Ritratto si legge in quattro punti, e nessuno lo
    // restituisce intero a chi non lo possiede.
    final letture = RegExp(r'statoDi\((\w+), "ritratto"\)')
        .allMatches(porte)
        .map((m) => m.group(1))
        .toList();
    print('ORDINE FF VOCE 02: letture del Ritratto sul server $letture');
    // ilMioRitratto (scrive e legge il proprio), voltoDi (l'altro, per la
    // fotografia della partita), gliEnigmi e l'apertura dell'indovinello
    // (solo il proprio: e' compilato?).
    expect(letture, ['uid', 'uid', 'uid', 'uid', 'uid']);
    final volto = porte.substring(porte.indexOf('async function voltoDi'),
        porte.indexOf('async function voltoPubblico'));
    expect(volto, contains('statoDi(uid, "ritratto")'));
    // Il volto altrui entra solo nella fotografia chiusa della partita, e la
    // vista della partita che torna al telefono non porta i dati.
    final vista = porte.substring(porte.indexOf('function vistaDellaPartita'),
        porte.indexOf('export const scopriUnSegno'));
    expect(vista.contains('dati'), isFalse);
    // ilMioRitratto restituisce i tratti di chi chiama, mai di un altro.
    final mio = corpoDi('ilMioRitratto');
    expect(RegExp(r'statoDi\((?!uid\b)').hasMatch(mio), isFalse,
        reason: 'ilMioRitratto legge lo stato di un altro');
    // Sul telefono l'unica schermata che mostra un Ritratto intero e' quella
    // di chi lo possiede.
    final chi = [
      for (final f in sorgentiDiLib())
        if (f.readAsStringSync().contains('ilMioRitratto('))
          f.path.replaceAll(r'\', '/'),
    ]..sort();
    expect(chi, [
      'lib/core/cerchio/il_cerchio_sociale.dart',
      'lib/features/cerchio/enigmi/il_ritratto_screen.dart',
    ]);
  });

  test('FF.02.5 e) il gioco in corso usa il Ritratto di quando e\' cominciato',
      () {
    // Gli indizi si pescano dalla fotografia salvata nella partita
    // all'apertura, mai dal Ritratto di adesso.
    final indovinello = corpoDi('unIndovinello');
    expect(indovinello, contains('dati: {ritratto: persona.ritratto'));
    expect(indovinello,
        contains('indizioDellaPartita(p?.dati as DatiDellaPersona, id, n,'));
  });

  test('FF.03.4 a) i giochi chiedono gli indizi a una porta sola, enumerata',
      () {
    // Fra i giochi del Cerchio gli indizi li usa Chi del Cerchio: la Prova
    // e le Sfide si giocano sul punteggio e non hanno indizi.
    final chiamate = RegExp(r'indizioDellaPartita\(').allMatches(porte).length;
    final chi = [
      for (final p in [
        'unIndovinello',
        'gliEnigmi',
        'laProva',
        'scopriUnSegno',
        'unPassoDelPellegrinaggio',
        'ilMioRitratto'
      ])
        if (corpoDi(p).contains('indizioDellaPartita(')) p,
    ];
    print('ORDINE FF VOCE 03: porte che chiedono un indizio $chi');
    expect(chi, ['unIndovinello']);
    expect(chiamate, 1);
  });

  test('FF.06.5 b) il Pellegrinaggio e\' aperto a ogni piano', () {
    final passo = corpoDi('unPassoDelPellegrinaggio');
    expect(passo.contains('pianoDi('), isFalse,
        reason: 'il Pellegrinaggio guarda il piano: escluderebbe qualcuno');
    expect(corpoDi('gliEnigmi'), contains('metaDelPellegrinaggio('));
  });

  test('FF.07.3 b) un gioco scaduto si chiude da solo col risultato che c\'e\'',
      () {
    // La sfida scaduta si chiude alla prima lettura di chiunque dei due, e
    // il punto va a chi ha giocato.
    expect(corpoDi('gliEnigmi'), contains('chiudiLeSfideScadute(uid, adesso)'));
    expect(
        enigmi, contains('if (adesso >= s.scade) return {vincitori: [s.da]'));
  });
}
