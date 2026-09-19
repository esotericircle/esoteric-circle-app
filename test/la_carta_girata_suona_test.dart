import 'dart:io';

import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/features/tarot/stesa_senses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'codice_senza_testo.dart';

/// **IL SUONO DELLA CARTA ESCE DAVVERO DALLA STESA.**
/// Ordine CO voce 02, 3 settembre 2026.
///
/// Nasce dal difetto piu' silenzioso che questo progetto abbia incontrato, e
/// va scritto per esteso perche' nessuna guardia di allora poteva vederlo.
///
/// L'ordine CN aveva fatto tutto il resto giusto: il file `carta.mp3`
/// convertito e normalizzato, la sua riga nel registro delle misure, la voce
/// nel catalogo dei suoni, e la mappa che dice *la carta girata suona `carta`*.
/// Una guardia sorvegliava quella mappa ed era verde, **e aveva ragione**: la
/// mappa era giusta.
///
/// Solo che chi la interrogava buttava via la risposta. `SensiDellaStesa`
/// riceveva di suo un `LettoreSilenzioso`, una classe il cui unico metodo era
/// vuoto per contratto, e **nessuno gliene passava mai un altro**. Il suono
/// veniva scelto correttamente a ogni carta girata e consegnato al nulla.
///
/// **Percio' questa guardia non guarda la mappa: guarda la porta.** Arma la
/// spia sulla porta unica del Cerchio, gira una carta, e pretende che il
/// suono ci sia arrivato. E' la sola forma di prova che il difetto di CN
/// avrebbe fermato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<SuonoDelCerchio>> giraLaCarta(
    WidgetTester tester,
    MomentoSensoriale momento, {
    bool suonoAcceso = true,
    bool silenzioDellaStesa = false,
  }) async {
    SharedPreferences.setMockInitialValues(const {});
    final impostazioni = SettingsController(effettiSonori: suonoAcceso);

    final sentiti = <SuonoDelCerchio>[];
    PaletteSensoriale.spia = sentiti.add;
    addTearDown(() => PaletteSensoriale.spia = null);

    final sensi = SensiDellaStesa(silenzio: silenzioDellaStesa);
    late BuildContext dentro;
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsController>.value(
        value: impostazioni,
        child: Builder(builder: (c) {
          dentro = c;
          return const SizedBox();
        }),
      ),
    );
    await sensi.momento(dentro, momento);
    return sentiti;
  }

  testWidgets('la carta che si gira arriva alla porta unica del Cerchio',
      (tester) async {
    final sentiti = await giraLaCarta(tester, MomentoSensoriale.flip);
    expect(sentiti, [SuonoDelCerchio.carta],
        reason: 'la carta girata non ha fatto uscire nessun suono dalla porta '
            'del Cerchio. La mappa puo\u0027 essere giusta lo stesso: il '
            'difetto dell\u0027ordine CN era proprio questo, la risposta '
            'giusta consegnata a un lettore che per contratto non fa niente');
  });

  testWidgets('e la carta scoperta porta la rivelazione', (tester) async {
    final sentiti = await giraLaCarta(tester, MomentoSensoriale.reveal);
    expect(sentiti, [SuonoDelCerchio.rivelazione]);
  });

  testWidgets('i momenti senza suono restano affidati alla sola aptica',
      (tester) async {
    for (final m in [
      MomentoSensoriale.taglio,
      MomentoSensoriale.mescolamento,
      MomentoSensoriale.volo,
    ]) {
      expect(await giraLaCarta(tester, m), isEmpty,
          reason: 'il momento ${m.name} ha fatto uscire un suono: la stesa e\u0027 '
              'un rito e non una macchina da gioco, e il silenzio che rende '
              'importante un suono si perde se ogni gesto ne ha uno');
    }
  });

  testWidgets('l\u0027interruttore dell\u0027app zittisce anche la stesa',
      (tester) async {
    expect(await giraLaCarta(tester, MomentoSensoriale.flip, suonoAcceso: false),
        isEmpty,
        reason: 'chi spegne gli effetti dell\u0027app non si aspetta di '
            'sentirli ancora nella stesa: il suono passa dalla porta unica '
            'proprio perche\u0027 li\u0027 vive quell\u0027interruttore');
  });

  testWidgets('e il silenzio locale della stesa sta sopra il suo',
      (tester) async {
    expect(
        await giraLaCarta(tester, MomentoSensoriale.flip,
            silenzioDellaStesa: true),
        isEmpty);
  });

  test('l\u0027intercapedine vuota non e\u0027 tornata', () {
    final codice = codiceSenzaTesto(
        File('lib/features/tarot/stesa_senses.dart').readAsStringSync());
    expect(codice, isNot(contains('class LettoreSilenzioso')),
        reason: 'e\u0027 tornato un lettore che per contratto non fa niente, '
            'e con lui il modo di essere muti restando verdi');
    expect(codice, contains('PaletteSensoriale.suona'),
        reason: 'la stesa non passa piu\u0027 dalla porta unica del Cerchio: '
            'un suono che non passa di li\u0027 non rispetta gli interruttori');
  });
}
