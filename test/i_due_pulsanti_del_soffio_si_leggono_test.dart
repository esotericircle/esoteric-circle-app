import 'dart:math' as math;

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/design_system/theme/abito_del_responso.dart';
import 'package:esoteric_circle/design_system/tokens/regime_chiaro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// I DUE PULSANTI DEL SOFFIO SI LEGGONO. Ordine CW, voce 08.
///
/// **Il fatto.** Parole del fondatore: nel Soffio del Destino i due pulsanti in
/// basso non si leggono per il colore del testo.
///
/// **MISURATO, e non era il colore scelto male: era il REGIME sbagliato.**
/// `AbitoDelResponso.di(dono)` da' il vestito chiaro **al solo `dawn`**; a
/// tutti gli altri Doni, Soffio compreso, da' quello notturno. Ma il Soffio
/// passava `suChiaro: true` ad `AzioniDelResponso`, copiato dall'Alba, col
/// commento *"il fondo qui e' chiaro"*: **vero per l'Alba, falso per lui.**
///
/// I due pulsanti dipingevano quindi `RegimeChiaro.testoSuChiaro`, #2A2213, sul
/// vetro notturno #1C1338: **1,11 a uno**.
///
/// **LA SOGLIA, e da dove viene.** Nelle linee guida UX del progetto non
/// esiste una regola di contrasto dichiarata per i pulsanti; esiste pero' la
/// pratica del censimento dei grigi, che pretende 4,5 per il corpo del testo e
/// 7,0 per le etichette piccole. Qui si applica **4,5**, che e' il minimo AA
/// per il testo normale, e lo si dichiara: e' la soglia che l'ordine indica
/// quando una regola dichiarata non c'e'.
void main() {
  /// Il rapporto di contrasto fra due colori, sulla formula WCAG.
  double contrasto(Color a, Color b) {
    double canale(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    double luce(Color c) =>
        0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
    final la = luce(a);
    final lb = luce(b);
    final alta = math.max(la, lb);
    final bassa = math.min(la, lb);
    return (alta + 0.05) / (bassa + 0.05);
  }

  /// Cosa si vede davvero sotto un colore con trasparenza, posato su un fondo.
  Color composto(Color sopra, Color sotto) =>
      Color.alphaBlend(sopra, Color.fromARGB(255, (sotto.r * 255).round(),
          (sotto.g * 255).round(), (sotto.b * 255).round()));

  /// La soglia dichiarata da questa prova.
  const soglia = 4.5;

  test('Il Soffio NON ha il vestito chiaro, e nessuno deve crederlo', () {
    // E' la premessa dell'intera voce: se un giorno il Soffio passasse al
    // regime chiaro, questa prova va riletta invece di aggiustata.
    expect(AbitoDelResponso.di(DailyElement.dawn).diGiorno, isTrue,
        reason: 'l\'Alba non ha piu\' il vestito chiaro');
    expect(AbitoDelResponso.di(DailyElement.breath).diGiorno, isFalse,
        reason: 'il Soffio ha il vestito chiaro: allora `suChiaro: true` era '
            'giusto e questa voce misurava la cosa sbagliata');
  });

  test('L\'inchiostro chiaro sul vetro notturno era illeggibile', () {
    // La misura del difetto, tenuta nella prova perche' il numero e' la
    // ragione della correzione e non un ricordo.
    final abito = AbitoDelResponso.di(DailyElement.breath);
    final fondo = composto(abito.velatura, abito.superficiePeggiore);
    final quantoEra = contrasto(RegimeChiaro.testoSuChiaro, fondo);
    expect(quantoEra, lessThan(soglia),
        reason: 'l\'inchiostro del regime chiaro sul vestito notturno misura '
            '${quantoEra.toStringAsFixed(2)}: se avesse superato la soglia, '
            'la causa del difetto sarebbe un\'altra e la correzione '
            'sbagliata');
  });

  test('I due pulsanti si leggono sul vestito del Soffio', () {
    final abito = AbitoDelResponso.di(DailyElement.breath);
    // **IL FONDO VERO, non quello dichiarato.** La velatura del vestito e'
    // semitrasparente: cio' che l'occhio vede e' lei composta sopra la
    // superficie peggiore, che e' il caso da misurare.
    final fondo = composto(abito.velatura, abito.superficiePeggiore);

    // I due pulsanti contornati prendono l'inchiostro del regime, che sul
    // vestito notturno e' quello del tema scuro.
    final inchiostro = abito.inchiostro;
    final quanto = contrasto(inchiostro, fondo);
    // ignore: avoid_print
    print('ORDINE CW VOCE 08: i due pulsanti misurano '
        '${quanto.toStringAsFixed(2)} contro la soglia di $soglia');
    expect(quanto, greaterThanOrEqualTo(soglia),
        reason: 'i due pulsanti del Soffio misurano '
            '${quanto.toStringAsFixed(2)} contro $soglia: non si leggono, ed '
            'e\' esattamente cio\' che il fondatore ha visto');
  });

  test('E si leggono anche premuti e disabilitati', () {
    // **I DUE STATI CHE L'ORDINE CHIEDE PER NOME.** Material scurisce
    // l'etichetta di un pulsante disabilitato al trentotto per cento
    // dell'opacita', e la sovrappone al fondo: e' li' che un colore appena
    // sufficiente scende sotto la soglia.
    final abito = AbitoDelResponso.di(DailyElement.breath);
    final fondo = composto(abito.velatura, abito.superficiePeggiore);

    // Premuto: Material posa un velo dell'inchiostro sul fondo, circa il
    // dodici per cento.
    final fondoPremuto =
        Color.alphaBlend(abito.inchiostro.withValues(alpha: 0.12), fondo);
    final premuto = contrasto(abito.inchiostro, fondoPremuto);
    expect(premuto, greaterThanOrEqualTo(soglia),
        reason: 'premuto il pulsante misura ${premuto.toStringAsFixed(2)} '
            'contro $soglia');

    // Disabilitato: l'etichetta scende al trentotto per cento.
    final spento =
        contrasto(Color.alphaBlend(abito.inchiostro.withValues(alpha: 0.38),
            fondo), fondo);
    // ignore: avoid_print
    print('ORDINE CW VOCE 08: premuto ${premuto.toStringAsFixed(2)}, '
        'disabilitato ${spento.toStringAsFixed(2)}');
    expect(spento, greaterThanOrEqualTo(3.0),
        reason: 'disabilitato il pulsante misura ${spento.toStringAsFixed(2)}: '
            'sotto tre a uno non si distingue piu\' dal fondo, e un comando '
            'che non si vede affatto non si capisce nemmeno che e\' spento');
  });
}
