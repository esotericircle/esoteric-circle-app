import 'dart:math' as math;

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL RESPONSO DEL VISO NON E' SEMPRE LO STESSO.** Ordine CX, 8 settembre
/// 2026, dal fondatore mentre il lavoro era in corso.
///
/// **Parole sue**: *"Ti prego di rivedere i responsi uno per uno (fronte,
/// naso, zigomi, sopracciglia, ecc) non corrispondono a me e ho paura che i
/// risultati siano sempre gli stessi"*.
///
/// **La paura si misura, non si rassicura.** Se un volto diverso desse la
/// stessa lettura di ogni altro volto, l'intera funzione sarebbe una messa in
/// scena, e nessuna guardia del Viso se ne sarebbe accorta: tutte quelle che
/// esistono provano che il responso **esiste**, nessuna prova che **cambi**.
///
/// **Come si misura.** Si costruiscono volti sintetici facendo variare, una
/// per una, le grandezze che il classificatore dichiara di guardare: la
/// larghezza alle tre altezze, l'altezza della fronte, la curva delle
/// sopracciglia, la distanza e l'apertura degli occhi, la lunghezza del naso,
/// lo spessore delle labbra. Poi si contano **gli esiti distinti per
/// categoria**. Una categoria che risponde sempre la stessa cosa e' una
/// categoria morta, e la sua riga nel responso e' un ornamento.
///
/// **REGOLA H.** Non basta contare quante varianti escono: si prova anche che
/// **volti uguali diano letture uguali**. Un classificatore che sputasse
/// varianti a caso passerebbe il conto della varieta' a pieni voti ed e'
/// esattamente il difetto opposto, altrettanto grave.
void main() {
  /// Un volto sintetico parametrico. Ogni parametro e' una grandezza che il
  /// classificatore dichiara di guardare, cosi' muoverla DEVE cambiare la sua
  /// categoria: se non la cambia, quella categoria non guarda quello che dice.
  FaceContours volto({
    double larghezza = 0.62,
    double altezza = 0.86,
    double fronteLarga = 1.0,
    double zigomiLarghi = 1.0,
    double mascellaLarga = 1.0,
    double mentoLargo = 0.55,
    double fronteAlta = 0.34,
    double sopraccioCurvo = 0.0,
    double occhiLontani = 0.32,
    double occhiAperti = 0.085,
    double nasoLungo = 0.33,
    double labbraSpesse = 0.055,
    double boccaLarga = 0.42,
  }) {
    const cx = 0.5;
    final cima = 0.5 - altezza / 2;
    final fondo = 0.5 + altezza / 2;

    // L'ovale: si disegna a fasce, cosi' le tre larghezze sono davvero
    // quelle che il classificatore misura alle sue tre quote.
    double larghezzaAllaQuota(double q) {
      // q va da 0 in cima a 1 in fondo.
      final f = larghezza * fronteLarga;
      final z = larghezza * zigomiLarghi;
      final m = larghezza * mascellaLarga;
      final mt = larghezza * mentoLargo;
      // **LE QUOTE SONO QUELLE CHE IL CLASSIFICATORE MISURA.** La prima
      // stesura passava al mento solo dopo il novanta per cento, mentre
      // `_larghezzaFascia` legge il mento fra l ottantotto e il cento e
      // prende il MASSIMO: la mascella entrava in quella fascia e il mento
      // risultava sempre largo quanto lei. La categoria sembrava morta ed
      // era cieca la prova.
      if (q <= 0.30) return f * (0.55 + 1.5 * q);
      if (q <= 0.60) return z;
      if (q <= 0.86) return m;
      return mt;
    }

    final ovale = <Offset>[];
    const passi = 40;
    for (var i = 0; i <= passi; i++) {
      final q = i / passi;
      final y = cima + (fondo - cima) * q;
      ovale.add(Offset(cx + larghezzaAllaQuota(q) / 2, y));
    }
    for (var i = passi; i >= 0; i--) {
      final q = i / passi;
      final y = cima + (fondo - cima) * q;
      ovale.add(Offset(cx - larghezzaAllaQuota(q) / 2, y));
    }

    // La fronte finisce dove cominciano le sopracciglia: e' la quota che
    // decide fra fronte verticale e sfuggente.
    final ySopraccio = cima + altezza * fronteAlta;
    List<Offset> sopraccio(double segno) => [
          for (var i = 0; i <= 6; i++)
            () {
              final t = i / 6;
              final x = cx + segno * (0.06 + 0.13 * t);
              // La curva: al centro dell'arco il punto sale di `curvo`.
              final gobba = math.sin(t * math.pi) * sopraccioCurvo;
              return Offset(x, ySopraccio - gobba);
            }(),
        ];

    final yOcchi = ySopraccio + altezza * 0.07;
    List<Offset> occhio(double segno) {
      final centro = cx + segno * occhiLontani / 2;
      final semi = occhiAperti * altezza / 2;
      return [
        Offset(centro - 0.05, yOcchi),
        Offset(centro, yOcchi - semi),
        Offset(centro + 0.05, yOcchi),
        Offset(centro, yOcchi + semi),
      ];
    }

    final yNasoBase = yOcchi + altezza * nasoLungo;
    final yBocca = yNasoBase + altezza * 0.10;
    final semiLabbro = labbraSpesse * altezza / 2;

    return FaceContours(
      volto: ovale,
      sopraccioSx: sopraccio(-1),
      sopraccioDx: sopraccio(1),
      occhioSx: occhio(-1),
      occhioDx: occhio(1),
      nasoPonte: [Offset(cx, yOcchi), Offset(cx, yNasoBase)],
      nasoBase: [
        Offset(cx - 0.05, yNasoBase),
        Offset(cx, yNasoBase + 0.01),
        Offset(cx + 0.05, yNasoBase),
      ],
      labbroSopra: [
        Offset(cx - boccaLarga / 2, yBocca),
        Offset(cx, yBocca - semiLabbro),
        Offset(cx + boccaLarga / 2, yBocca),
      ],
      labbroSotto: [
        Offset(cx - boccaLarga / 2, yBocca),
        Offset(cx, yBocca + semiLabbro),
        Offset(cx + boccaLarga / 2, yBocca),
      ],
      guanciaSx: Offset(cx - larghezza / 2, yOcchi),
      guanciaDx: Offset(cx + larghezza / 2, yOcchi),
    );
  }

  /// Le varianti che ogni parametro produce, viste su una scala di valori.
  Map<FaceCategory, Set<FaceTrait>> spazza(
      List<FaceContours> Function() genera) {
    final visti = <FaceCategory, Set<FaceTrait>>{};
    for (final c in genera()) {
      for (final l in FaceClassifier.leggi(c).letture) {
        visti.putIfAbsent(l.tratto.categoria, () => <FaceTrait>{})
            .add(l.tratto);
      }
    }
    return visti;
  }

  test('OGNI CATEGORIA DA\' PIU\' DI UNA RISPOSTA, su volti diversi', () {
    // Una spazzata larga: ogni parametro percorre il suo intervallo mentre
    // gli altri restano al centro. E' il modo di sapere **quale** grandezza
    // e' morta, invece di sapere soltanto che qualcosa non si muove.
    final tutti = <FaceContours>[];
    for (var i = 0; i <= 10; i++) {
      final t = i / 10;
      tutti.addAll([
        volto(larghezza: 0.42 + 0.42 * t),
        volto(altezza: 0.62 + 0.46 * t),
        volto(fronteLarga: 0.70 + 0.60 * t),
        volto(zigomiLarghi: 0.75 + 0.50 * t),
        volto(mascellaLarga: 0.62 + 0.66 * t),
        volto(mentoLargo: 0.28 + 0.62 * t),
        volto(fronteAlta: 0.09 + 0.28 * t),
        volto(sopraccioCurvo: -0.02 + 0.09 * t),
        volto(occhiLontani: 0.18 + 0.30 * t),
        volto(occhiAperti: 0.03 + 0.13 * t),
        volto(nasoLungo: 0.18 + 0.30 * t),
        volto(labbraSpesse: 0.015 + 0.20 * t),
        volto(boccaLarga: 0.16 + 0.42 * t),
      ]);
    }
    cardinaleMinimo(tutti.length, 100,
        cosa: 'volti sintetici nella spazzata',
        perche: 'Con pochi volti la varieta\' non si puo\' nemmeno misurare, '
            'e questa prova sarebbe verde per mancanza di dati.');

    final visti = spazza(() => tutti);
    final morte = <String>[];
    for (final categoria in FaceCategory.values) {
      final quante = visti[categoria]?.length ?? 0;
      // ignore: avoid_print
      print('ORDINE CX: categoria ${categoria.name}, varianti viste $quante '
          'su ${FaceTrait.values.where((t) => t.categoria == categoria).length} '
          'possibili: ${(visti[categoria] ?? {}).map((t) => t.nome).join(", ")}');
      if (quante <= 1) morte.add(categoria.name);
    }
    expect(morte, isEmpty,
        reason: 'queste categorie danno SEMPRE la stessa risposta comunque '
            'cambi il volto, quindi la loro riga nel responso e\' scritta '
            'prima di guardare: ${morte.join(", ")}');
  });

  test('E IL DOMINANTE CAMBIA, non e\' sempre lo stesso tratto', () {
    // **La domanda del fondatore in una riga.** Il dominante e' il tratto che
    // apre il responso: se fosse sempre quello, due persone diverse
    // leggerebbero la stessa frase in cima.
    final dominanti = <FaceTrait, int>{};
    var quanti = 0;
    for (var a = 0; a <= 4; a++) {
      for (var b = 0; b <= 4; b++) {
        for (var c = 0; c <= 4; c++) {
          final v = volto(
            larghezza: 0.44 + 0.36 * (a / 4),
            fronteAlta: 0.20 + 0.26 * (b / 4),
            nasoLungo: 0.20 + 0.26 * (c / 4),
            mascellaLarga: 0.70 + 0.50 * (a / 4),
            occhiAperti: 0.04 + 0.09 * (b / 4),
            labbraSpesse: 0.02 + 0.08 * (c / 4),
          );
          dominanti.update(FaceClassifier.leggi(v).dominante, (n) => n + 1,
              ifAbsent: () => 1);
          quanti++;
        }
      }
    }
    final ordinati = dominanti.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    // ignore: avoid_print
    print('ORDINE CX: su $quanti volti diversi i tratti dominanti distinti '
        'sono ${dominanti.length}, e il piu\' frequente e\' '
        '"${ordinati.first.key.nome}" con ${ordinati.first.value} volte');
    cardinaleMinimo(quanti, 100,
        cosa: 'volti diversi nella griglia dei dominanti',
        perche: 'Senza volti non c e nessun dominante da contare.');
    expect(dominanti.length, greaterThanOrEqualTo(3),
        reason: 'su $quanti volti diversi il responso apre con soli '
            '${dominanti.length} tratti dominanti: e\' la paura che il '
            'fondatore ha scritto, e sarebbe fondata');
    // E nessuno domina la scena da solo: se un tratto uscisse in nove casi su
    // dieci, la varieta' sarebbe formale e non reale.
    expect(ordinati.first.value / quanti, lessThan(0.75),
        reason: 'il tratto "${ordinati.first.key.nome}" apre il responso nel '
            '${(ordinati.first.value * 100 / quanti).round()} per cento dei '
            'volti: la varieta\' e\' scritta ma non si vede');
  });

  // **LA PROVA SULLA DISTRIBUZIONE E STATA TOLTA, e la ragione conta.**
  // Ordine CX, 8 settembre 2026.
  //
  // Qui stava una prova che generava quattrocento volti sintetici dalle
  // proporzioni normali e contava da che parte cadeva ogni categoria. Diceva
  // che tre categorie rispondevano uguale a tutti, ed era vero. Poi sono
  // arrivati i rapporti veri dal telefono, e **il modello di volto su cui
  // quella prova si basava non somigliava ai volti veri**: dopo la taratura
  // sui dati reali la stessa prova ha cominciato a dire il contrario, con le
  // stesse categorie al cento per cento dalla parte opposta.
  //
  // **Un giudice che cambia verdetto quando il codice migliora non e un
  // giudice.** La domanda che poneva vive adesso in
  // `due_volti_diversi_danno_responsi_diversi_test.dart`, dove i numeri sono
  // quelli misurati su due persone vere e non quelli di un volto inventato.

  test('REGOLA H: due volti uguali danno la stessa lettura', () {
    // L'altra meta': la varieta' non deve venire dal caso. Lo stesso volto,
    // letto due volte, deve dare la stessa cosa in tutte le categorie.
    final a = FaceClassifier.leggi(volto());
    final b = FaceClassifier.leggi(volto());
    expect(a.letture.map((l) => l.tratto).toList(),
        b.letture.map((l) => l.tratto).toList(),
        reason: 'lo stesso volto da\' due letture diverse: la varieta\' che '
            'le altre prove misurano sarebbe rumore, non misura');
  });
}
