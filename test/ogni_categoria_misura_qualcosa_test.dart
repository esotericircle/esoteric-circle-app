import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **OGNI CATEGORIA MISURA QUALCOSA, E IL NUMERO SI PUO' LEGGERE.**
/// Ordine CX, 8 settembre 2026.
///
/// **Come e' stato trovato.** Il fondatore ha detto che il responso non gli
/// somiglia e che sospettava fosse sempre lo stesso. La prima scansione vera
/// col telefono collegato ha stampato gli undici rapporti misurati, e uno di
/// essi era **`zigomi=nullo`**: quella categoria dava un giudizio senza
/// esporre nessun numero, quindi nessuno poteva sapere su cosa lo desse.
///
/// **La grandezza misurata e' la presenza del rapporto**, non la variante. Una
/// categoria che sceglie un tratto ma non dichiara la misura da cui l'ha
/// scelto e' una categoria che **non si puo' tarare**: si vede il giudizio e
/// non il fatto, e le undici soglie di questo file aspettano proprio di essere
/// tarate su volti veri.
///
/// **REGOLA H.** Non basta che il rapporto ci sia: si prova anche che sia un
/// numero **usabile**, cioe' finito e non negativo. Un `NaN` passerebbe un
/// controllo di presenza a pieni voti e renderebbe la taratura impossibile
/// esattamente come un nullo, ma in silenzio.
void main() {
  /// Un volto qualunque, purche' completo: qui non conta la sua forma, conta
  /// che tutte e undici le categorie abbiano di che misurare.
  FaceContours volto() {
    const cx = 0.5;
    const cima = 0.07;
    const fondo = 0.93;
    final ovale = <Offset>[];
    for (var i = 0; i <= 40; i++) {
      final q = i / 40;
      final y = cima + (fondo - cima) * q;
      final w = q <= 0.30 ? 0.34 + 0.5 * q : (q <= 0.86 ? 0.62 : 0.40);
      ovale.add(Offset(cx + w / 2, y));
    }
    for (var i = 40; i >= 0; i--) {
      final q = i / 40;
      final y = cima + (fondo - cima) * q;
      final w = q <= 0.30 ? 0.34 + 0.5 * q : (q <= 0.86 ? 0.62 : 0.40);
      ovale.add(Offset(cx - w / 2, y));
    }
    const ySop = 0.36;
    const yOcchi = 0.42;
    const yNaso = 0.63;
    const yBocca = 0.75;
    List<Offset> sopraccio(double s) => [
          for (var i = 0; i <= 6; i++)
            Offset(cx + s * (0.06 + 0.13 * i / 6), ySop - 0.02 * (i % 3)),
        ];
    List<Offset> occhio(double s) => [
          Offset(cx + s * 0.16 - 0.05, yOcchi),
          Offset(cx + s * 0.16, yOcchi - 0.02),
          Offset(cx + s * 0.16 + 0.05, yOcchi),
          Offset(cx + s * 0.16, yOcchi + 0.02),
        ];
    return FaceContours(
      volto: ovale,
      sopraccioSx: sopraccio(-1),
      sopraccioDx: sopraccio(1),
      occhioSx: occhio(-1),
      occhioDx: occhio(1),
      nasoPonte: const [Offset(cx, yOcchi), Offset(cx, yNaso)],
      nasoBase: const [
        Offset(cx - 0.05, yNaso),
        Offset(cx, yNaso + 0.01),
        Offset(cx + 0.05, yNaso),
      ],
      labbroSopra: const [
        Offset(cx - 0.10, yBocca),
        Offset(cx, yBocca - 0.02),
        Offset(cx + 0.10, yBocca),
      ],
      labbroSotto: const [
        Offset(cx - 0.10, yBocca),
        Offset(cx, yBocca + 0.02),
        Offset(cx + 0.10, yBocca),
      ],
      guanciaSx: const Offset(cx - 0.31, yOcchi),
      guanciaDx: const Offset(cx + 0.31, yOcchi),
    );
  }

  test('TUTTE E UNDICI dichiarano il rapporto da cui hanno scelto', () {
    final lettura = FaceClassifier.leggi(volto());
    cardinaleMinimo(lettura.letture.length, FaceCategory.values.length,
        cosa: 'letture restituite dal classificatore',
        perche: 'Se il classificatore ne restituisse meno, questa prova '
            'guarderebbe solo quelle che ci sono e direbbe che stanno tutte '
            'bene.');
    final mute = <String>[];
    for (final l in lettura.letture) {
      // ignore: avoid_print
      print('ORDINE CX: ${l.tratto.categoria.name} rapporto '
          '${l.rapporto?.toStringAsFixed(4) ?? "NULLO"}');
      if (l.rapporto == null) mute.add(l.tratto.categoria.name);
    }
    expect(mute, isEmpty,
        reason: 'queste categorie danno un giudizio senza dichiarare la '
            'misura da cui viene, quindi non si possono tarare su nessun '
            'volto vero: ${mute.join(", ")}');
  });

  test('REGOLA H: e sono numeri usabili, non NaN e non negativi', () {
    // Un `NaN` passerebbe il controllo di presenza e renderebbe la taratura
    // impossibile in silenzio, che e' peggio di un nullo dichiarato.
    for (final l in FaceClassifier.leggi(volto()).letture) {
      final r = l.rapporto;
      expect(r, isNotNull);
      expect(r!.isFinite, isTrue,
          reason: 'il rapporto di ${l.tratto.categoria.name} non e\' un '
              'numero finito: vale $r');
      expect(r, greaterThanOrEqualTo(0.0),
          reason: 'il rapporto di ${l.tratto.categoria.name} e\' negativo, '
              'e sono tutti rapporti fra lunghezze: vale $r');
    }
  });
}
