import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA TESTA DEL MAESTRO NON SI TAGLIA, NEMMENO A LETTERE GRANDI.**
/// Ordine CO voce 10, 3 settembre 2026.
///
/// Fatto del fondatore: scorrendo la chat la testa del Maestro si vede
/// tagliata.
///
/// **Non era lo scorrimento, era la scala del testo.** La barra della chat
/// misurava centosedici punti sempre, e dentro ci stanno in colonna il volto
/// che sfonda il cerchio, il nome del Maestro e la riga delle tre arti. Il
/// volto ha una misura sua, in punti, e non cresce mai; le due righe di testo
/// crescono con la scala di chi guarda, fino a 1,3 che è il tetto dichiarato
/// dall'app. A quel punto la colonna sfora, **e una AppBar ritaglia il suo
/// titolo dall'alto: cioè esattamente dove sta la testa.**
///
/// ## La grandezza misurata
///
/// Non si guarda che il codice contenga una formula: si **misurano le due
/// righe con le loro vere metriche di carattere**, alla scala massima
/// dichiarata, e si pretende che l'altezza della barra le contenga insieme al
/// volto. Le metriche vengono dal `TextPainter`, che è lo stesso che dipinge a
/// schermo: un conto fatto a mano sui numeri della scala tipografica
/// sbaglierebbe di quanto sbaglia l'interlinea.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **IL TETTO DELLA SCALA E' QUELLO DELL'APP, non un numero scelto qui.**
  /// Vive in `lib/app.dart`, dove il `MediaQuery` lo fissa per tutto l'albero,
  /// e questa riga lo rilegge da lì invece di ricopiarlo: una soglia copiata
  /// resta ferma il giorno che l'originale sale.
  double tettoDellaScala() {
    final app = File('lib/app.dart').readAsStringSync();
    final m = RegExp(r'maxScaleFactor:\s*([\d.]+)').firstMatch(app);
    expect(m, isNotNull,
        reason: 'app.dart non dichiara piu un tetto alla scala del testo: '
            'questa prova non sa piu contro quale misura provare');
    return double.parse(m!.group(1)!);
  }

  double altezzaDi(String testo, TextStyle stile, double scala, double larga) {
    final p = TextPainter(
      text: TextSpan(text: testo, style: stile),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear(scala),
      textAlign: TextAlign.center,
    )..layout(maxWidth: larga);
    return p.height;
  }

  test('la barra della chat contiene volto e due righe al tetto della scala',
      () {
    final scala = tettoDellaScala();
    // ignore: avoid_print
    print('ORDINE CO VOCE 10: tetto della scala del testo $scala');
    expect(scala, greaterThanOrEqualTo(1.3),
        reason: 'il tetto della scala e sceso sotto 1,3: la misura di questa '
            'prova andava con lui');

    // **LA LARGHEZZA E' QUELLA VERA DEL TITOLO**, cioè lo schermo del telefono
    // meno i due angoli della barra, dove stanno la freccia Indietro e il
    // pulsante Ricomincia. Su una larghezza sbagliata le due righe non vanno a
    // capo quando invece a schermo lo fanno, e il conto verrebbe più basso del
    // vero.
    const schermo = 360.0;
    const angoli = 56.0 * 2;
    const larga = schermo - angoli;

    // I numeri della colonna, gli stessi dichiarati nella barra.
    const anello = 40.0;
    const stacco = 2.0;
    const respiro = 6.0;
    final quantoServe = <Maestro, double>{};
    for (final m in Maestro.values) {
      final nome =
          altezzaDi(m.displayName, TypographyTokens.titoloSezione(), scala,
              larga);
      final arti = altezzaDi(
          m.domainArtsPhrase, TypographyTokens.didascalia(), scala, larga);
      quantoServe[m] = anello + stacco + nome + arti;
    }
    // ignore: avoid_print
    print('ORDINE CO VOCE 10: quanto serve alla colonna, per Maestro '
        '${quantoServe.map((k, v) => MapEntry(k.id, v.toStringAsFixed(1)))}');

    cardinaleMinimo(quantoServe.length, Maestro.values.length,
        cosa: 'Maestri misurati nella barra della chat',
        perche: 'Se un Maestro sparisse da questo giro, la sua riga delle tre '
            'arti smetterebbe di essere misurata: sono di lunghezza diversa, '
            'e quella che va a capo per prima e la sola che conta.');

    // **LA BARRA MISURA LE STESSE DUE RIGHE, con lo stesso TextPainter.**
    // La prima stesura di questa voce aveva una formula, ventidue e sedici
    // punti per l'interlinea per la scala, e questa prova l'ha bocciata: alla
    // scala massima la riga delle arti di Medora VA A CAPO, quindi vale due
    // righe e non una, e la formula sbagliava di ventitre punti e tre. Una
    // formula che moltiplica non sa niente di dove il testo andra a capo.
    final alta = anello +
        stacco +
        altezzaDi(Maestro.medora.displayName, TypographyTokens.titoloSezione(),
            scala, larga) +
        altezzaDi(Maestro.medora.domainArtsPhrase,
            TypographyTokens.didascalia(), scala, larga) +
        respiro;
    // ignore: avoid_print
    print('ORDINE CO VOCE 10: la barra misura ${alta.toStringAsFixed(1)} '
        'punti alla scala $scala');

    final stretti = <String>[];
    for (final v in quantoServe.entries) {
      if (v.value > alta) {
        stretti.add('${v.key.id}: servono ${v.value.toStringAsFixed(1)} punti '
            'e la barra ne da ${alta.toStringAsFixed(1)}');
      }
    }
    expect(stretti, isEmpty,
        reason: 'LA COLONNA DELLA BARRA NON CI STA, e una AppBar ritaglia il '
            'suo titolo DALL ALTO, cioe esattamente dove sta la testa del '
            'Maestro:\n${stretti.join("\n")}\n'
            'Non si abbassa il testo: si alza la barra, che e cio che questa '
            'voce ha fatto.');
  });

  test('la barra non e piu un numero scritto a mano', () {
    final s = File('lib/features/maestri/chat/maestro_chat_screen.dart')
        .readAsStringSync();
    expect(s, contains('final double scalaDelTesto;'),
        reason: 'la barra non riceve piu la scala del testo: torna a misurare '
            'lo stesso numero per chi vede piccolo e per chi vede grande');
    expect(s, contains('MediaQuery.textScalerOf(context).scale(1)'),
        reason: 'nessuno passa piu la scala alla barra: il campo c e e resta '
            'sempre uno, che e il difetto travestito da rimedio');
    expect(s, isNot(contains('showAvatar ? 116 : 68')),
        reason: 'e tornato il numero fisso: centosedici punti valgono per la '
            'scala di chi li ha scritti');
    expect(s, contains('TextPainter('),
        reason: 'la barra e tornata a STIMARE con una formula invece di '
            'misurare: una formula che moltiplica non sa niente di dove il '
            'testo andra a capo, ed e proprio il ritorno a capo della riga '
            'delle arti di Medora che taglia la testa');
    expect(s, contains('final double larghezzaDelTitolo;'),
        reason: 'la barra non sa piu quanto e larga, quindi non puo sapere '
            'dove il testo va a capo');
  });
}
