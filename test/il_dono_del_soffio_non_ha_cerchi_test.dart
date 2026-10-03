// ignore_for_file: avoid_print
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/forma_del_dono.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL DONO DEL SOFFIO NON HA PIU' CERCHI.** Ordine DU voce 14.
///
/// Il fondatore ha visto a video un cerchio che non tornava con la figura, e
/// ha chiesto che siano **i petali a ingrandirsi e a ridursi**. Qui non si
/// legge il codice: **si dipinge la figura e si guardano i pixel**, perche' un
/// anello si vede nei pixel e in nessun altro posto.
///
/// Come si distingue un anello da ventiquattro petali: si prendono tanti
/// raggi attorno al centro e per ognuno si conta **quanta parte della sua
/// circonferenza e' accesa**. Un anello accende quasi tutta la circonferenza a
/// un raggio solo; i petali ne accendono ventiquattro punte, cioe' una
/// frazione piccola a ogni raggio.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
  const lato = 420.0;
  const centro = Offset(lato / 2, lato / 2);

  Future<ByteData> dipinta(double respiro, {bool fermo = false}) async {
    final registratore = ui.PictureRecorder();
    final canvas = Canvas(registratore);
    // Fondo nero come la scena, cosi' cio' che si accende e' solo la figura.
    canvas.drawRect(const Rect.fromLTWH(0, 0, lato, lato),
        Paint()..color = const Color(0xFF000000));
    FormaDelDono.dipingi(canvas,
        centro: centro,
        larghezza: lato,
        soffio: 1,
        respiro: respiro,
        palette: palette,
        fermo: fermo);
    final immagine =
        await registratore.endRecording().toImage(lato.round(), lato.round());
    return (await immagine.toByteData())!;
  }

  /// La luce in un punto, da zero a 255.
  int luce(ByteData dati, int x, int y) {
    if (x < 0 || y < 0 || x >= lato || y >= lato) return 0;
    final i = (y * lato.round() + x) * 4;
    return math.max(
        dati.getUint8(i), math.max(dati.getUint8(i + 1), dati.getUint8(i + 2)));
  }

  /// Quanta parte della circonferenza di raggio [raggio] e' accesa.
  ///
  /// **Si guarda una banda di un pixel, non una riga di pixel interi.** Un
  /// anello fine disegnato con l'antialiasing si spalma su due pixel e a
  /// campionarlo esatto se ne prende poco piu' di un terzo: misurato
  /// innestando l'anello vecchio, che cosi' non faceva scattare niente.
  double quantoAcceso(ByteData dati, double raggio, {int soglia = 90}) {
    const passi = 720;
    var accesi = 0;
    for (var k = 0; k < passi; k++) {
      final a = 2 * math.pi * k / passi;
      var massimo = 0;
      for (final d in const [-1.0, -0.5, 0.0, 0.5, 1.0]) {
        final x = (centro.dx + math.cos(a) * (raggio + d)).round();
        final y = (centro.dy + math.sin(a) * (raggio + d)).round();
        massimo = math.max(massimo, luce(dati, x, y));
      }
      if (massimo > soglia) accesi++;
    }
    return accesi / passi;
  }

  /// Fin dove arriva la luce lungo un raggio solo, nella direzione [a].
  double lungoIlRaggio(ByteData dati, double a, {int soglia = 90}) {
    for (var raggio = lato / 2 - 2; raggio > 0; raggio -= 0.25) {
      final x = (centro.dx + math.cos(a) * raggio).round();
      final y = (centro.dy + math.sin(a) * raggio).round();
      if (luce(dati, x, y) > soglia) return raggio;
    }
    return 0;
  }

  test('NESSUN ANELLO: nessun raggio ha la circonferenza tutta accesa',
      () async {
    final dati = await dipinta(0.25);
    final r = FormaDelDono.raggio(lato, 1);
    var peggiore = 0.0, doveDelPeggiore = 0.0;
    var guardati = 0;
    // Si guarda da meta' raggio in fuori: piu' dentro c'e' il cuore, che e'
    // un disco pieno e deve restare.
    for (var raggio = r * 0.55; raggio <= r * 1.35; raggio += 0.5) {
      final quota = quantoAcceso(dati, raggio);
      if (quota > peggiore) {
        peggiore = quota;
        doveDelPeggiore = raggio / r;
      }
      guardati++;
    }
    print('ORDINE DU voce 14: raggi guardati $guardati, la circonferenza piu\' '
        'accesa e\' al ${(doveDelPeggiore * 100).round()} per cento del raggio '
        'con il ${(peggiore * 100).round()} per cento acceso');
    expect(guardati, greaterThan(50),
        reason: 'guardati $guardati raggi: su un insieme vuoto questa prova '
            'sarebbe verde senza aver guardato niente');
    expect(peggiore, lessThan(0.5),
        reason: 'a ${(doveDelPeggiore * 100).round()} per cento del raggio la '
            'circonferenza e\' accesa per il ${(peggiore * 100).round()} per '
            'cento: e\' un anello, ed e\' il cerchio che il fondatore ha visto');
  });

  test('I PETALI CI SONO: ventiquattro punte, non una macchia', () async {
    final dati = await dipinta(0.25);
    final r = FormaDelDono.raggio(lato, 1);
    // **I petali non finiscono tutti allo stesso raggio**, perche' respirano
    // ognuno con la sua fase: la punta si cerca in tutta la corona esterna, e
    // non su una circonferenza sola. Misurato, non dedotto: a un raggio solo
    // se ne contavano cinque.
    const passi = 720;
    final accesi = <bool>[];
    for (var k = 0; k < passi; k++) {
      final a = 2 * math.pi * k / passi;
      var massimo = 0;
      for (var raggio = r * 0.72; raggio <= r * 1.1; raggio += 0.5) {
        final x = (centro.dx + math.cos(a) * raggio).round();
        final y = (centro.dy + math.sin(a) * raggio).round();
        massimo = math.max(massimo, luce(dati, x, y));
      }
      accesi.add(massimo > 90);
    }
    var gruppi = 0;
    for (var k = 0; k < passi; k++) {
      if (accesi[k] && !accesi[(k - 1 + passi) % passi]) gruppi++;
    }
    print('ORDINE DU voce 14: punte contate $gruppi');
    expect(gruppi, inInclusiveRange(12, FormaDelDono.petali),
        reason: 'le punte contate sono $gruppi: i petali sono '
            '${FormaDelDono.petali}');
  });

  test('IL RESPIRO STA NEI PETALI: un petalo si allunga e si accorcia',
      () async {
    // **Il respiro si misura su un petalo, non sull'inviluppo.** Le fasi sono
    // sfalsate apposta, quindi in ogni istante qualche petalo e' lungo e
    // qualcuno e' corto e la figura nel suo insieme resta larga uguale: e'
    // quello che si voleva, ed e' il motivo per cui guardare il massimo su
    // tutti gli angoli non vedeva niente.
    final piena = await dipinta(0.25);
    final vuota = await dipinta(0.75);
    final cambiati = <double>[];
    for (var i = 0; i < FormaDelDono.petali; i++) {
      final a = 2 * math.pi * i / FormaDelDono.petali - math.pi / 2;
      final lunga = lungoIlRaggio(piena, a);
      final corta = lungoIlRaggio(vuota, a);
      cambiati.add((lunga - corta).abs());
    }
    cambiati.sort();
    final mediano = cambiati[cambiati.length ~/ 2];
    print('ORDINE DU voce 14: fra fiato pieno e fiato vuoto i petali cambiano '
        'da ${cambiati.first.toStringAsFixed(1)} a '
        '${cambiati.last.toStringAsFixed(1)} punti, mediana '
        '${mediano.toStringAsFixed(1)}');
    expect(cambiati.last, greaterThan(4),
        reason: 'nessun petalo cambia lunghezza col fiato');
    expect(cambiati.where((c) => c > 2).length, greaterThan(11),
        reason: 'soltanto ${cambiati.where((c) => c > 2).length} petali su '
            '${FormaDelDono.petali} respirano');
  });

  test('CON RIDUCI MOVIMENTO la figura sta ferma', () async {
    final a = await dipinta(0.25, fermo: true);
    final b = await dipinta(0.75, fermo: true);
    expect(a.buffer.asUint8List(), b.buffer.asUint8List(),
        reason: 'con Riduci Movimento la figura si muove lo stesso');
  });
}
