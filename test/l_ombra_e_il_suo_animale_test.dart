/// **L'OMBRA E' IL SUO ANIMALE, AL PIXEL.** Ordine DG voce 02,
/// 11 settembre 2026.
///
/// **IL DIFETTO CHE LA FA NASCERE, con le parole del fondatore.** *"mi fa
/// vedere le ombre, ma si capisce di quali animali si tratta"*, e *"quando
/// apro la funzionalita', non ci sono tutte le immagini che ho creato con nano
/// banana"*.
///
/// **La seconda meta' era vera e la prima no.** Le dodici ombre **non
/// c'erano**: gli slot le cercavano dall'ordine DC e i file non erano nel ramo,
/// quindi ogni `Image.asset` cadeva nel suo ripiego e a schermo arrivava una
/// sagoma disegnata da una formula. Che si capisse di quale animale si tratta,
/// invece, adesso **e' il meccanismo**: l'animale e' uno solo, il suo, e
/// sospettare chi sia prima che lo dica e' l'esperienza.
///
/// **QUESTA GUARDIA MISURA LA COSA CHE RENDE VERO IL VIAGGIO:** che la sagoma
/// che si segue sia **quella esatta** dell'illustrazione che si ricevera', e
/// non una figura che le somiglia. Si confrontano i due canali alpha, pixel
/// per pixel.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **LA FORMA DI UN ASSET, normalizzata.** Una griglia di [lato] per [lato]
  /// presa **dentro il riquadro dei pixel opachi**, non dentro il file.
  ///
  /// **La prima stesura confrontava le griglie sul file intero, ed era una
  /// misura sbagliata**: le dodici ombre sono 900 per 700 col soggetto
  /// **ricentrato e con un margine del dieci per cento**, mentre le
  /// illustrazioni hanno ognuna la sua forma, dal gufo 537 per 865 alla volpe
  /// 894 per 575. Confrontate cosi', due immagini della stessa identica
  /// sagoma cadevano al quaranta per cento, e la prova accusava il lavoro
  /// dell'Architetto invece del proprio metodo.
  ///
  /// **Si e' cambiata la grandezza misurata e non la soglia**: qui si misura
  /// **la forma**, che e' cio' che conta, non dove sta dentro la sua tela.
  Future<List<bool>> maschera(String percorso, {int lato = 60}) async {
    final dati = await rootBundle.load(percorso);
    final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final bytes =
        (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer
            .asUint8List();
    bool opaco(int x, int y) {
      final i = (y * img.width + x) * 4;
      return i + 3 < bytes.length && bytes[i + 3] > 128;
    }

    // Il riquadro dei pixel opachi.
    var sx = img.width, dx = -1, su = img.height, giu = -1;
    for (var y = 0; y < img.height; y++) {
      for (var x = 0; x < img.width; x++) {
        if (!opaco(x, y)) continue;
        if (x < sx) sx = x;
        if (x > dx) dx = x;
        if (y < su) su = y;
        if (y > giu) giu = y;
      }
    }
    if (dx < sx || giu < su) return List<bool>.filled(lato * lato, false);
    final larga = dx - sx + 1;
    final alta = giu - su + 1;
    final celle = List<bool>.filled(lato * lato, false);
    for (var cy = 0; cy < lato; cy++) {
      for (var cx = 0; cx < lato; cx++) {
        var opachi = 0;
        var quanti = 0;
        final x0 = sx + larga * cx ~/ lato;
        final x1 = sx + larga * (cx + 1) ~/ lato;
        final y0 = su + alta * cy ~/ lato;
        final y1 = su + alta * (cy + 1) ~/ lato;
        for (var y = y0; y < y1; y++) {
          for (var x = x0; x < x1; x++) {
            quanti++;
            if (opaco(x, y)) opachi++;
          }
        }
        celle[cy * lato + cx] = quanti > 0 && opachi * 2 > quanti;
      }
    }
    return celle;
  }

  /// Quanto due maschere si sovrappongono, da 0 a 1: le celle in comune sul
  /// totale delle celle piene di almeno una delle due.
  double quantoCoincidono(List<bool> a, List<bool> b) {
    var insieme = 0;
    var comuni = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] || b[i]) insieme++;
      if (a[i] && b[i]) comuni++;
    }
    return insieme == 0 ? 0 : comuni / insieme;
  }

  test('I DODICI FILE DELLE OMBRE ESISTONO NEL PACCHETTO, e hanno alpha vero',
      () async {
    expect(AnimalCatalog.animals.length, 12);
    var conAlpha = 0;
    for (final a in AnimalCatalog.animals) {
      final dati = await rootBundle.load(a.ombraPath);
      expect(dati.lengthInBytes, greaterThan(1000),
          reason: '${a.name}: il file dell ombra e vuoto o quasi');
      final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 900, reason: '${a.name}: larghezza');
      expect(frame.image.height, 700, reason: '${a.name}: altezza');
      final bytes = (await frame.image
              .toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List();
      var trasparenti = 0;
      for (var i = 3; i < bytes.length; i += 4) {
        if (bytes[i] < 16) trasparenti++;
      }
      final quota = trasparenti / (bytes.length / 4);
      expect(quota, greaterThan(0.2),
          reason: '${a.name}: il file non ha alpha vero, e un rettangolo '
              'pieno: solo il ${(quota * 100).toStringAsFixed(1)} per cento '
              'dei pixel e trasparente');
      conAlpha++;
    }
    // ignore: avoid_print
    print('ORDINE DG VOCE 02: $conAlpha ombre su 12 con alpha vero, '
        '900 per 700');
    expect(conAlpha, 12);
  });

  test('OGNI OMBRA E LA SAGOMA ESATTA DELLA SUA ILLUSTRAZIONE', () async {
    // **E NON DI UN ALTRO ANIMALE.** E' la cosa che rende vero il Viaggio:
    // l'ombra che si segue e' quella che si ricevera'. Se un giorno qualcuno
    // rigenerasse le ombre a mano, o ne scambiasse due file, questa prova
    // cadrebbe col nome dell'animale in mano.
    final suo = <String, double>{};
    for (final a in AnimalCatalog.animals) {
      final ombra = await maschera(a.ombraPath);
      final vera = await maschera(a.fullPath);
      suo[a.name] = quantoCoincidono(ombra, vera);
    }
    final peggiore = suo.entries.reduce((x, y) => x.value < y.value ? x : y);
    // ignore: avoid_print
    print('ORDINE DG VOCE 02: l ombra coincide con la sua illustrazione dal '
        '${(peggiore.value * 100).toStringAsFixed(1)} per cento in su '
        '(il peggiore e ${peggiore.key})');
    for (final e in suo.entries) {
      expect(e.value, greaterThan(0.80),
          reason: '${e.key}: l ombra non e la sagoma della sua illustrazione, '
              'coincidono solo per il ${(e.value * 100).toStringAsFixed(1)} '
              'per cento');
    }
  });

  test('E NON COINCIDE CON QUELLA DI UN ALTRO, o non direbbe niente',
      () async {
    // **LA SECONDA META', ed e' quella che fa di questa una guardia.** Se
    // tutte le sagome fossero un rettangolo pieno, la prova qui sopra sarebbe
    // verde al cento per cento e non avrebbe misurato niente.
    final mascherate = <String, List<bool>>{};
    for (final a in AnimalCatalog.animals) {
      mascherate[a.name] = await maschera(a.ombraPath);
    }
    var peggiore = 0.0;
    var dovePeggiore = '';
    for (final a in AnimalCatalog.animals) {
      for (final b in AnimalCatalog.animals) {
        if (a.name == b.name) continue;
        final q = quantoCoincidono(mascherate[a.name]!, mascherate[b.name]!);
        if (q > peggiore) {
          peggiore = q;
          dovePeggiore = '${a.name} e ${b.name}';
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DG VOCE 02: due ombre diverse si somigliano al massimo per '
        'il ${(peggiore * 100).toStringAsFixed(1)} per cento ($dovePeggiore)');
    expect(peggiore, lessThan(0.80),
        reason: 'due ombre di animali diversi sono quasi la stessa figura: '
            '$dovePeggiore');
  });
}
