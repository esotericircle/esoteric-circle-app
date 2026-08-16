import 'package:esoteric_circle/core/sigilli/forme_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE FORME DEL LOTO SONO I DISCHI DELLE PERLE. Ordine AE voce 03.
///
/// **La legge delle luci del Loto e' cambiata**: si illuminano le perle e i
/// centri d'oro, non piu' i petali. La forma di ogni elemento e' un CERCHIO
/// centrato sull'ancoraggio col raggio del suo pallino, e la distinzione fra
/// forma vera e ripiego per il Loto non esiste piu': cinquantacinque forme,
/// tutte della stessa natura. Gli altri due sentieri non c'entrano e questa
/// prova non li guarda.
///
/// **Come si riconosce un cerchio dalle strisce.** Un disco di raggio r ha il
/// riquadro quasi quadrato e riempie del riquadro circa pi greco su quattro,
/// 0,785: un petalo allungato, una colata o un bagliore quadrato non ci
/// riescono. La tolleranza copre la discretizzazione dei raggi piccoli,
/// misurata: un disco disegnato per strisce a raggio 16 riempie 0,796, a
/// raggio 54 riempie 0,787.
void main() {
  test('le cinquantacinque forme del Loto sono cerchi, nessun ripiego', () {
    final forme = FormeDeiSentieri.di(Sentiero.loto);
    expect(forme, isNotNull);
    expect(forme, hasLength(55),
        reason: 'le forme del Loto sono ${forme!.length} invece di 55');

    var osservate = 0;
    final storte = <String>[];
    final ripieghi = <int>[];
    for (var i = 0; i < forme.length; i++) {
      final f = forme[i];
      osservate++;
      if (f.eRipiego) {
        ripieghi.add(i);
        continue;
      }
      final s = f.strisce;
      var minX = s[1], maxX = s[2], minY = s[0], maxY = s[0];
      for (var k = 0; k + 2 < s.length; k += 3) {
        if (s[k] < minY) minY = s[k];
        if (s[k] > maxY) maxY = s[k];
        if (s[k + 1] < minX) minX = s[k + 1];
        if (s[k + 2] > maxX) maxX = s[k + 2];
      }
      final bw = maxX - minX + 1;
      final bh = maxY - minY + 1;
      final riempimento = f.area / (bw * bh);
      final aspetto = bw > bh ? bw / bh : bh / bw;
      if (aspetto > 1.1 || (riempimento - 0.785).abs() > 0.06) {
        storte.add('la forma $i ha riquadro $bw per $bh e riempimento '
            '${riempimento.toStringAsFixed(2)}: non e\' un cerchio');
      }
      expect(f.colore, isNotNull,
          reason: 'la forma $i non ha colore: una perla accesa della luce '
              'dorata generica non e\' la legge di questo sentiero');
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE AE VOCE 03: forme osservate $osservate, non cerchi '
        '${storte.length}, ripieghi ${ripieghi.length}');
    expect(osservate, 55);
    expect(ripieghi, isEmpty,
        reason: 'il Loto delle perle non ha ripieghi per costruzione, e questi '
            'indici lo sono ancora: $ripieghi');
    expect(storte, isEmpty,
        reason: '${storte.length} forme non sono cerchi: '
            '${storte.take(5).join(" | ")}');
  });
}
