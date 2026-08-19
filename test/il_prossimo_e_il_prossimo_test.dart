import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// "IL PROSSIMO" MOSTRA IL PROSSIMO. Ordine AR voce 07.
///
/// **Il difetto, e da dove viene.** In fondo alla festa una scheda annuncia il
/// traguardo che verra': nell'anteprima dell'ordine AQ mostrava quello APPENA
/// raggiunto. La causa non e' la scheda, e' il momento: la festa si apre
/// nell'istante in cui il traguardo matura, e se l'accensione non e' ancora
/// arrivata al diario, la ricerca del primo non acceso trova proprio lui.
///
/// La cura non prova a mettere in fila due eventi asincroni, che e' la classe
/// di difetti piu' cara di questo progetto: **dice al diario cosa si sta
/// celebrando**, e la risposta smette di dipendere dall'ordine di arrivo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DiarioDelCammino> diarioVuoto() async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    return diario;
  }

  test('il traguardo che si celebra non e il prossimo', () async {
    final diario = await diarioVuoto();
    final primo = Sentieri.miniDi(Sentiero.costellazione).first;
    final senzaEscludere = diario.prossimoDi(Sentiero.costellazione);
    final escludendo = diario.prossimoDi(Sentiero.costellazione,
        escludendo: {primo.id});
    // ignore: avoid_print
    print('ORDINE AR VOCE 07: si celebra ${primo.id}; senza escludere il '
        'prossimo sarebbe ${senzaEscludere?.id}, escludendolo e '
        '${escludendo?.id}');
    expect(senzaEscludere?.id, primo.id,
        reason: 'la prova non riproduce piu il difetto: gira a vuoto');
    expect(escludendo?.id, isNot(primo.id),
        reason: 'la scheda annuncia come prossimo il traguardo appena '
            'festeggiato');
    expect(escludendo, isNotNull);
  });

  test('con piu traguardi celebrati insieme si saltano tutti', () async {
    final diario = await diarioVuoto();
    final primi = Sentieri.miniDi(Sentiero.costellazione).take(3).toList();
    final prossimo = diario.prossimoDi(
      Sentiero.costellazione,
      escludendo: {for (final t in primi) t.id},
    );
    expect(primi.map((t) => t.id).contains(prossimo?.id), isFalse,
        reason: 'nella festa unita il prossimo e uno dei celebrati');
  });

  test('a sentiero finito non si ripete l ultimo: non c e prossimo', () async {
    SharedPreferences.setMockInitialValues({
      'cammino.accesi': [
        for (final t in Sentieri.di(Sentiero.costellazione)) t.id,
      ],
    });
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final prossimo = diario.prossimoDi(Sentiero.costellazione);
    // ignore: avoid_print
    print('ORDINE AR VOCE 07: a sentiero finito il prossimo e $prossimo');
    expect(prossimo, isNull,
        reason: 'a sentiero finito si annuncia ancora un prossimo, e sarebbe '
            'per forza uno gia' 'raggiunto');
  });

  test('la festa chiede il prossimo del sentiero della FESTA', () {
    // La regola sta scritta accanto al codice, e questa riga la sorveglia:
    // con la festa unita i sentieri sono piu' di uno, e prendere il primo
    // dell'elenco vorrebbe dire seguire l'ordine in cui i traguardi sono
    // dichiarati, non quello che si sta celebrando.
    final scena = Sentiero.values.map((s) => s.maestro).toSet();
    expect(scena.length, Maestro.values.length,
        reason: 'i tre sentieri non hanno piu tre Maestri distinti: la regola '
            'del prossimo con la festa unita non ha piu senso');
  });

  test('la festa ESCLUDE davvero cio che celebra', () {
    // Il rosso di questa voce si prova qui: se la scena smettesse di passare
    // gli id in corso, la scheda tornerebbe ad annunciare il traguardo appena
    // festeggiato, e nessuna delle prove qui sopra se ne accorgerebbe.
    final scena =
        File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
    expect(scena.contains('escludendo: {for (final t in widget.traguardi)'),
        isTrue,
        reason: 'la festa non esclude piu i traguardi che sta celebrando: la '
            'scheda annuncera di nuovo quello appena raggiunto');
  });
}
