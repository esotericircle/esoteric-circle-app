import 'dart:math' as math;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI PERLA RISPONDE AL SUO CENTRO. Ordine AU voce 09.
///
/// **Il fatto, segnalato due volte dal fondatore**: nel sentiero di Aura le
/// sfere al centro del fiore non rispondono al tocco e non portano al
/// traguardo.
///
/// **L'ordine AS voce 04 aveva curato la vicinanza fra i punti** (84 coppie
/// piu' vicine di mezzo raggio) ma il difetto resta sui CENTRI, che sono i
/// cinque grandi. Per questo qui si ENUMERA: tutti e cinquantacinque i
/// bersagli, su tutti e tre i sentieri, con un tocco esattamente sul proprio
/// centro. Un difetto che vive su un sentiero vive spesso su tre.
void main() {
  /// La tela su cui si misura: la stessa proporzione del disegno a schermo.
  const misura = Size(360, 360);

  Offset centroDi(PuntoDelSentiero p) =>
      Offset(p.dove.dx * misura.width, p.dove.dy * misura.height);

  /// I punti di un sentiero, come li riceve il disegno.
  List<PuntoDelSentiero> puntiDi(Sentiero sentiero) =>
      GeometriaDelSentiero.punti(sentiero);

  test('il censimento dei bersagli: centro, raggio e chi risponde', () {
    for (final sentiero in Sentiero.values) {
      final punti = puntiDi(sentiero);
      expect(punti, hasLength(55),
          reason: 'il sentiero ${sentiero.name} non ha 55 bersagli ma '
              '${punti.length}: la prova non sta guardando cio che dice');
      final corto = math.min(misura.width, misura.height);
      var rispondono = 0;
      final muti = <String>[];
      final grandi = <String>[];
      for (final punto in punti) {
        final vinto = quiHaToccato(punti, centroDi(punto), misura);
        if (vinto?.traguardo.id == punto.traguardo.id) {
          rispondono++;
        } else {
          muti.add('${punto.traguardo.id} (raggio '
              '${(punto.raggio * corto).toStringAsFixed(1)}) risponde '
              '${vinto?.traguardo.id ?? "nessuno"}');
        }
        if (punto.grandezza == GrandezzaDelPunto.principale) {
          grandi.add(punto.traguardo.id);
        }
      }
      // ignore: avoid_print
      print('ORDINE AU VOCE 09: ${sentiero.name}, dei 55 bersagli ne '
          'rispondono $rispondono al proprio centro; i grandi sono '
          '${grandi.length}: ${grandi.join(", ")}');
      if (muti.isNotEmpty) {
        // ignore: avoid_print
        print('  muti: ${muti.join("; ")}');
      }
    }
  });

  for (final sentiero in Sentiero.values) {
    test('su ${sentiero.name} tutti e 55 rispondono al proprio centro', () {
      final punti = puntiDi(sentiero);
      final muti = <String>[];
      for (final punto in punti) {
        final vinto = quiHaToccato(punti, centroDi(punto), misura);
        if (vinto?.traguardo.id != punto.traguardo.id) {
          muti.add('${punto.traguardo.id} risponde ${vinto?.traguardo.id ?? "nessuno"}');
        }
      }
      expect(muti, isEmpty,
          reason: 'su ${sentiero.name} questi bersagli non rispondono al tocco '
              'sul proprio centro, e sono ${muti.length}: $muti');
    });

    test('su ${sentiero.name} i grandi rispondono anche a meta del raggio',
        () {
      // **NON BASTA IL CENTRO ESATTO**, ed e' proprio il difetto che il
      // fondatore descrive: una perla che risponde solo se il dito cade sul
      // punto esatto, a occhio, non risponde mai. Qui si tocca a meta' del
      // raggio disegnato, in quattro direzioni.
      final punti = puntiDi(sentiero);
      final corto = math.min(misura.width, misura.height);
      final guai = <String>[];
      for (final punto in punti) {
        if (punto.grandezza != GrandezzaDelPunto.principale) continue;
        final r = punto.raggio * corto / 2;
        for (final verso in const [
          Offset(1, 0),
          Offset(-1, 0),
          Offset(0, 1),
          Offset(0, -1),
        ]) {
          final dove = centroDi(punto) + verso * r;
          final vinto = quiHaToccato(punti, dove, misura);
          if (vinto?.traguardo.id != punto.traguardo.id) {
            guai.add('${punto.traguardo.id} a meta raggio verso $verso risponde '
                '${vinto?.traguardo.id ?? "nessuno"}');
          }
        }
      }
      expect(guai, isEmpty,
          reason: 'su ${sentiero.name} una perla grande risponde solo al '
              'centro esatto, e a occhio non risponde mai: $guai');
    });
  }
}
