import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA FIGURA SOLA, E SI COMPONE MENTRE CAMMINI. Ordine S voce 02.
///
/// **Cosa c'era prima, e va scritto perche' e' la ragione di tutto.** I
/// cinquanta mini erano cinque gruppi da dieci, ognuno con una forma chiusa, e
/// i cinque grandi erano il centro di ognuno: a schermo si leggevano come cinque
/// figurine slegate. E il reticolo era tutto disegnato da subito, anche a zero
/// traguardi, quindi la forma finale si vedeva prima di meritarla e non restava
/// niente da scoprire. Le stelle spente erano ANELLI col centro vuoto, cioe'
/// cinquantacinque caselle da spuntare su un cielo.
///
/// **La misura vera e' sui pixel, non sulla geometria.** Chiedere alla geometria
/// se un segmento tocca una stella spenta non prova niente: la geometria elenca
/// l'ossatura, e chi decide se disegnarla e' il pittore. Quindi il pittore
/// dipinge davvero, su una tela vera, e si guarda il punto di mezzo di ogni
/// segmento.
Offset _mezzo(PuntoDelSentiero a, PuntoDelSentiero b) => Offset(
    (a.dove.dx + b.dove.dx) / 2 * 360, (a.dove.dy + b.dove.dy) / 2 * 520);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La tela su cui il pittore dipinge davvero, e i suoi byte.
  Future<({ByteData dati, int larghezza, int altezza})> dipingi(
    Sentiero sentiero,
    Set<String> accesi, {
    Size misura = const Size(360, 520),
  }) async {
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    final punti = GeometriaDelSentiero.punti(sentiero);
    final pittore = switch (sentiero) {
      Sentiero.costellazione => PittoreDellaCostellazione(
          punti: punti,
          accesi: accesi,
          evidenziato: null,
          oro: const Color(0xFFD9B866),
          oroTenue: const Color(0xFF8A7130)),
      Sentiero.albero => PittoreDellAlbero(
          punti: punti,
          accesi: accesi,
          evidenziato: null,
          oro: const Color(0xFFD9B866),
          oroTenue: const Color(0xFF8A7130)),
      Sentiero.loto => PittoreDelLoto(
          punti: punti,
          accesi: accesi,
          evidenziato: null,
          oro: const Color(0xFFD9B866),
          oroTenue: const Color(0xFF8A7130)),
    };
    pittore.paint(tela, misura);
    final ui.Image immagine = await registratore.endRecording().toImage(
        misura.width.round(), misura.height.round());
    final ByteData dati =
        (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final int larghezza = immagine.width;
    final int altezza = immagine.height;
    immagine.dispose();
    return (dati: dati, larghezza: larghezza, altezza: altezza);
  }

  /// Quanto e' acceso il pixel piu' luminoso in un intorno di [dove].
  ///
  /// Si guarda un intorno e non il singolo pixel: una linea larga tre millesimi
  /// di tela puo' passare accanto al centro esatto per un arrotondamento, e una
  /// prova che cade per mezzo pixel non misura la regola, misura il caso.
  int luceAttorno(
      ({ByteData dati, int larghezza, int altezza}) tela, Offset dove,
      {int raggio = 3}) {
    var massimo = 0;
    for (var dy = -raggio; dy <= raggio; dy++) {
      for (var dx = -raggio; dx <= raggio; dx++) {
        final x = dove.dx.round() + dx;
        final y = dove.dy.round() + dy;
        if (x < 0 || y < 0 || x >= tela.larghezza || y >= tela.altezza) continue;
        final i = (y * tela.larghezza + x) * 4;
        for (var canale = 0; canale < 3; canale++) {
          final v = tela.dati.getUint8(i + canale);
          if (v > massimo) massimo = v;
        }
      }
    }
    return massimo;
  }

  /// LA SOGLIA DEL SEGMENTO APPARSO, e si misura per DIFFERENZA.
  ///
  /// **La prima stesura misurava la luce assoluta e accusava il tronco.** Nel
  /// disegno dell'Albero le cinque Sefirot stanno sul tronco, che e' struttura e
  /// si vede sempre: il punto di mezzo di un segmento della spina cade quindi
  /// dentro il tronco, e la misura lo leggeva come un segmento disegnato. Nel
  /// Loto la stessa cosa con lo stelo e coi petali chiusi, che sono forme piene.
  /// La regola non e' "in quel punto non c'e' niente", e' "quel segmento non e'
  /// stato disegnato": si misura percio' quanta luce COMPARE rispetto alla tela a
  /// zero traguardi.
  ///
  /// Quaranta livelli su 255: la linea viva dell'oro sta sopra 200, e il rumore
  /// del velo attorno a una stella accesa vicina resta molto sotto.
  const int sogliaDellaComparsa = 40;

  for (final sentiero in Sentiero.values) {
    group('${sentiero.name}: una figura sola', () {
      test('la figura si compone: ogni segmento COMPARE quando i suoi capi si '
          'accendono', () async {
        final buio = await dipingi(sentiero, const {});
        final tutti = {for (final t in Sentieri.di(sentiero)) t.id};
        final piena = await dipingi(sentiero, tutti);
        final punti = GeometriaDelSentiero.punti(sentiero);
        final ossa = GeometriaDelSentiero.ossatura(sentiero);
        // **IL LOTO NON HA OSSATURA, e la prova lo sa.** Legare i petali con
        // segmenti dritti disegnava poligoni sopra il fiore: la sua figura sola
        // sono i giri concentrici attorno allo stesso cuore, e la crescita si
        // vede nei petali che si aprono. Dove non ci sono segmenti, non c'e'
        // niente da misurare qui, e la voce si misura sui petali.
        if (sentiero == Sentiero.loto) {
          expect(ossa, isEmpty,
              reason: 'il Loto ha di nuovo dei segmenti: sopra un fiore '
                  'diventano spigoli');
          return;
        }
        expect(ossa, isNotEmpty,
            reason: 'la figura non ha ossatura: non ci sarebbe niente da unire');
        final mai = <String>[];
        for (final osso in ossa) {
          final mezzo = _mezzo(punti[osso.da], punti[osso.a]);
          final comparsa = luceAttorno(piena, mezzo) - luceAttorno(buio, mezzo);
          if (comparsa < sogliaDellaComparsa) {
            mai.add('${osso.da}-${osso.a} a $comparsa');
          }
        }
        expect(mai, isEmpty,
            reason: 'questi segmenti non compaiono nemmeno a figura intera, '
                'quindi la prova di sotto non misurerebbe niente:\n'
                '${mai.take(8).join("\n")}');
      });

      test('a zero traguardi nessun segmento e\' disegnato', () async {
        // La tela a zero e' il riferimento di se stessa: quello che si misura e'
        // che i segmenti non ci sono, e la struttura non conta perche' entra in
        // tutte e due le tele.
        final buio = await dipingi(sentiero, const {});
        final punti = GeometriaDelSentiero.punti(sentiero);
        final tutti = {for (final t in Sentieri.di(sentiero)) t.id};
        final piena = await dipingi(sentiero, tutti);
        final disegnati = <String>[];
        for (final osso in GeometriaDelSentiero.ossatura(sentiero)) {
          final mezzo = _mezzo(punti[osso.da], punti[osso.a]);
          // Se in quel punto, a zero, ci fosse gia' la luce che ci sara' a
          // figura intera, il segmento sarebbe gia' li'.
          final aZero = luceAttorno(buio, mezzo);
          final aPiena = luceAttorno(piena, mezzo);
          if (aZero >= aPiena - sogliaDellaComparsa) {
            disegnati.add('${osso.da}-${osso.a}: $aZero contro $aPiena');
          }
        }
        expect(disegnati, isEmpty,
            reason: 'con zero traguardi accesi questi segmenti sono gia\' '
                'disegnati, quindi la forma finale si vede prima di '
                'meritarla:\n${disegnati.take(8).join("\n")}');
      });

      test('un petalo chiuso e\' tenue, uno aperto si vede', () async {
        // La crescita del Loto sta nei petali e non nelle linee: si misura sul
        // petalo, dove il petalo sta.
        if (sentiero != Sentiero.loto) return;
        final buio = await dipingi(sentiero, const {});
        final tutti = {for (final t in Sentieri.di(sentiero)) t.id};
        final piena = await dipingi(sentiero, tutti);
        final punti = GeometriaDelSentiero.punti(sentiero);
        final fermi = <String>[];
        // **SI GUARDA DOVE IL PETALO APERTO ARRIVA, e non dove sta chiuso.**
        // Un petalo chiuso e' corto, stretto ed eretto: il posto dove finira'
        // quando si apre e' vuoto adesso, e pieno dopo. E' la traduzione esatta
        // di "i petali si aprono".
        const c = 360.0;
        final cuore = Offset(GeometriaDelSentiero.cuoreDelLoto.dx * 360,
            GeometriaDelSentiero.cuoreDelLoto.dy * 520);
        for (final punto in punti) {
          final lungo =
              GeometriaDelSentiero.lunghezzaDelGiro[punto.gruppo] * c * 0.72;
          final dove = Offset(
            cuore.dx + lungo * math.cos(punto.angolo),
            cuore.dy + lungo * math.sin(punto.angolo),
          );
          final comparsa = luceAttorno(piena, dove) - luceAttorno(buio, dove);
          if (comparsa < 25) fermi.add('${punto.traguardo.id} a $comparsa');
        }
        expect(fermi, isEmpty,
            reason: 'questi petali non cambiano aprendosi, quindi il cammino '
                'non si vede:\n${fermi.take(8).join("\n")}');
      });

      test('un segmento con un capo spento non compare', () async {
        // Si accende UNA sola parte, la prima: tutto cio' che tocca una stella
        // ancora spenta deve restare come era al buio.
        final buio = await dipingi(sentiero, const {});
        final prima = Sentieri.miniDi(sentiero).take(10).map((t) => t.id).toSet()
          ..add(Sentieri.grandiDi(sentiero).first.id);
        final parziale = await dipingi(sentiero, prima);
        final punti = GeometriaDelSentiero.punti(sentiero);
        final colpevoli = <String>[];
        for (final osso in GeometriaDelSentiero.ossatura(sentiero)) {
          final a = punti[osso.da];
          final b = punti[osso.a];
          final aAcceso = prima.contains(a.traguardo.id);
          final bAcceso = prima.contains(b.traguardo.id);
          if (aAcceso && bAcceso) continue;
          // **SI GUARDA DAL LATO SPENTO.** Se un capo e' acceso, il suo alone
          // arriva oltre il punto di mezzo su un segmento corto, e la prova
          // accuserebbe una luce che non e' il segmento. Al 30 per cento dal
          // capo spento non arriva.
          final dalloSpento = aAcceso ? b : a;
          final altro = aAcceso ? a : b;
          final punto = Offset(
            (dalloSpento.dove.dx * 0.70 + altro.dove.dx * 0.30) * 360,
            (dalloSpento.dove.dy * 0.70 + altro.dove.dy * 0.30) * 520,
          );
          final comparsa = luceAttorno(parziale, punto, raggio: 2) -
              luceAttorno(buio, punto, raggio: 2);
          if (comparsa >= sogliaDellaComparsa) {
            colpevoli.add('${osso.da}-${osso.a} a $comparsa');
          }
        }
        expect(colpevoli, isEmpty,
            reason: 'questi segmenti toccano una stella spenta e compaiono lo '
                'stesso:\n${colpevoli.take(8).join("\n")}');
      });

      test(
          'la gerarchia esiste: tre grandezze, e i cinque grandi sono le '
          'principali', () {
        final punti = GeometriaDelSentiero.punti(sentiero);
        expect(punti, hasLength(55));
        final usate = punti.map((p) => p.grandezza).toSet();
        expect(usate, hasLength(3),
            reason: 'la figura usa ${usate.length} grandezze invece di tre: '
                'senza gerarchia cinquantacinque punti sono un groviglio, e '
                'Orione si riconosce da sette');
        for (final p in punti) {
          if (p.eGrande) {
            expect(p.grandezza, GrandezzaDelPunto.principale,
                reason: 'un grande non e\' una stella principale: ogni grande '
                    'deve cambiare visibilmente la figura');
          } else {
            expect(p.grandezza, isNot(GrandezzaDelPunto.principale),
                reason: 'un mini e\' grande come un principale: la gerarchia '
                    'non si legge piu\'');
          }
        }
        expect(GrandezzaDelPunto.principale.raggio,
            greaterThan(GrandezzaDelPunto.media.raggio * 1.4));
        expect(GrandezzaDelPunto.media.raggio,
            greaterThan(GrandezzaDelPunto.piccola.raggio * 1.4));
      });
    });
  }

  group('Dentro il disegno non entra niente di serie', () {
    test('il file del disegno non usa nessuna icona del framework', () {
      final s = File('lib/features/sigilli/disegno_del_sentiero.dart')
          .readAsStringSync();
      expect(s.contains('Icons.'), isFalse,
          reason: 'dentro il disegno c\'e\' un\'icona di serie: tutto quello '
              'che si vede nel disegno lo disegniamo noi');
      expect(s.contains('Icon('), isFalse);
    });

    test('la fascia dei cinque grandi non c\'e\' piu\'', () {
      // Punto 7 della precisazione: era una tessera punti di sistema appoggiata
      // sopra un cielo, e diceva una cosa che il disegno dice meglio, perche' le
      // cinque stelle principali si vedono spente in anticipo.
      final s =
          File('lib/features/sigilli/sentiero_screen.dart').readAsStringSync();
      expect(s.contains('_FasciaDeiGrandi'), isFalse,
          reason: 'la fascia dei cinque grandi e\' tornata: sono due tessere '
              'punti per lo stesso conto, e una delle due con le icone di serie');
    });
  });
}
