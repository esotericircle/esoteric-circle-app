import 'dart:io';

import 'package:esoteric_circle/core/sensi/lo_schermo_acceso.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL LIVE CHIUDE LA SESSIONE E TIENE ACCESO LO SCHERMO.** Due guasti
/// trovati nell'ordine EK il 24 settembre 2026, fuori dal perimetro, e curati
/// col permesso del fondatore. Padre di tutti e due: l'ordine EG, la schermata
/// del LIVE.
///
/// 1. **La sessione di Protoface non si chiudeva uscendo.** Il telefono
///    lasciava la stanza e Protoface la teneva accesa fino al silenzio
///    tollerato: 13 secondi a video fatturati 70, due crediti.
/// 2. **Lo schermo si spegneva da solo durante il LIVE.** Alle 13:24:05, cinque
///    minuti dopo l'ultimo tocco, mentre Medora rispondeva: il microfono e'
///    andato a -100 decibel e il LIVE si e' chiuso dopo trenta secondi.
void main() {
  final schermata =
      File('lib/features/maestri/live/schermata_live.dart').readAsStringSync();

  String corpoDi(String firma) {
    final inizio = schermata.indexOf(firma);
    expect(inizio, greaterThanOrEqualTo(0), reason: '$firma non c\'e\' piu\'');
    // Fino al primo metodo che comincia dopo, alla stessa rientranza.
    final dopo = schermata.indexOf(
        RegExp(r'\n  (?:@override|Future<|void |String\?|bool |int )'),
        inizio + firma.length);
    return schermata.substring(inizio, dopo < 0 ? null : dopo);
  }

  test('LA CHIUSURA LA CHIEDE IL SERVER, PER LA SESSIONE GIUSTA', () async {
    final chiamate = <(String, Map<String, Object?>)>[];
    final prima = PortaDelLive.chiama;
    PortaDelLive.chiama = (porta, dati) async {
      chiamate.add((porta, dati));
      return const {};
    };
    addTearDown(() => PortaDelLive.chiama = prima);
    await PortaDelLive.chiudi('sess_01ABC');
    expect(chiamate, hasLength(1));
    expect(chiamate.single.$1, 'chiudiLaSessioneLive');
    expect(chiamate.single.$2, {'sessione': 'sess_01ABC'});
  });

  test('OGNI STRADA CHE ESCE DAL LIVE CHIUDE LA SESSIONE', () {
    // La sessione si ricorda appena il server la apre, prima della stanza:
    // se la stanza non si apre, la sessione esiste lo stesso e va chiusa.
    expect(schermata.contains('_sessioneAperta = s.sessione;'), isTrue,
        reason: 'la schermata non si ricorda quale sessione chiudere');
    for (final firma in ['void dispose()', 'Future<void> _chiudi(']) {
      expect(corpoDi(firma).contains('_chiudiLaSessione();'), isTrue,
          reason: '$firma esce dal LIVE senza chiudere la sessione');
    }
    expect(RegExp(r'_chiudiLaSessione\(\);').allMatches(schermata).length,
        greaterThanOrEqualTo(4),
        reason: 'le strade che escono sono quattro: la croce e i tempi, il '
            'tasto indietro, la stanza aperta a schermata chiusa, il volto che '
            'non arriva');
  });

  test('LO SCHERMO SI TIENE ACCESO ALL\'APERTURA E SI LIBERA ALL\'USCITA',
      () async {
    expect(corpoDi('void initState()').contains('LoSchermoAcceso.tieni(true)'),
        isTrue,
        reason: 'il LIVE si apre senza tenere acceso lo schermo');
    expect(corpoDi('void dispose()').contains('LoSchermoAcceso.tieni(false)'),
        isTrue,
        reason: 'uscendo dal LIVE lo schermo resterebbe acceso per sempre');

    // La porta chiede davvero, e sul banco senza canale non e' un guasto.
    final chieste = <bool>[];
    final prima = LoSchermoAcceso.chiedi;
    LoSchermoAcceso.chiedi = (acceso) async => chieste.add(acceso);
    addTearDown(() => LoSchermoAcceso.chiedi = prima);
    await LoSchermoAcceso.tieni(true);
    await LoSchermoAcceso.tieni(false);
    expect(chieste, [true, false]);
    LoSchermoAcceso.chiedi = (_) async => throw MissingPluginException();
    await LoSchermoAcceso.tieni(true);
  });

  test('ANDROID E IOS RISPONDONO SUL CANALE DELLO SCHERMO', () {
    final android = File(
            'android/app/src/main/kotlin/com/esotericircle/esoteric_circle/MainActivity.kt')
        .readAsStringSync();
    final ios = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(android.contains('"esoteric_circle/schermo"'), isTrue);
    expect(
        android.contains(
            'addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)'),
        isTrue);
    expect(
        android.contains(
            'clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)'),
        isTrue);
    expect(ios.contains('"esoteric_circle/schermo"'), isTrue);
    expect(ios.contains('UIApplication.shared.isIdleTimerDisabled = acceso'),
        isTrue);
  });
}
