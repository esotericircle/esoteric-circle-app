import 'dart:io';

import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA GIUNTURA DELL'OROSCOPO NON RIPETE SE STESSA. Ordine P voce 24, meta'
/// meccanica.
///
/// **Il difetto era doppio, e le due meta' si nascondevano a vicenda.**
///
/// UNO. La giuntura variava sul GIORNO e non sul dominio: l'indice era
/// `giornoOrdinale + indiceDelSegno`, uguale per tutte e quattro le schede dello
/// stesso oroscopo. Amore, Lavoro, Fortuna e Salute aprivano la loro riga del
/// cielo con la stessa frase, una sotto l'altra.
///
/// DUE. Le due famiglie di giunture, quella coi due punti e quella col punto,
/// erano lo stesso testo con la punteggiatura cambiata: a tre indici su cinque
/// identiche parola per parola. Quindi anche variando l'indice, due schede che
/// cadevano su famiglie diverse allo stesso indice leggevano uguale.
///
/// **CIO' CHE RESTA FUORI DA QUESTA VOCE, dichiarato.** La riscrittura delle
/// quarantotto ancore del corpus e' materiale di Mauro e diventa una voce sua a
/// parte: si guardano frase per frase e non si fanno di corsa. Qui si chiude la
/// sola meta' meccanica, cioe' il modo in cui la giuntura viene SCELTA.
void main() {
  group('La giuntura varia sul dominio', () {
    test('le quattro schede dello stesso giorno prendono quattro giunture', () {
      // **QUATTRO RESTI DISTINTI, SEMPRE, e non e' una probabilita'.** Le
      // giunture sono cinque e i domini quattro: base, base+1, base+2 e base+3
      // modulo cinque non possono coincidere, perche' quattro e' minore di
      // cinque. Si verifica su tutto l'anno e su tutti i segni, non su un
      // giorno scelto bene.
      for (var giorno = 1; giorno <= 366; giorno++) {
        for (var segno = 0; segno < 12; segno++) {
          final viste = <String>{};
          for (final dominio in HoroscopeDomain.values) {
            final int indice = giorno + segno + dominio.index;
            viste.add(CorrenteDelCielo
                .giunturaCoiDuePunti[indice % CorrenteDelCielo.giunturaCoiDuePunti.length]);
          }
          expect(viste, hasLength(HoroscopeDomain.values.length),
              reason: 'giorno $giorno segno $segno: le quattro schede '
                  'condividono una giuntura, e chi le scorre legge due volte '
                  'lo stesso attacco');
        }
      }
    });

    test('il dominio entra davvero nell\'indice', () {
      // La prova sopra misura l'aritmetica; questa misura che l'aritmetica sia
      // quella che il codice USA. Senza, la voce si potrebbe chiudere
      // cambiando solo la prova: la funzione che compone riceve l'indice gia'
      // sommato, quindi il termine si verifica dove viene sommato.
      final sorgente =
          File('lib/core/horoscope/corrente_del_cielo.dart').readAsStringSync();
      expect(sorgente,
          contains('giornoOrdinale + indiceDelSegno + dominio.index'),
          reason: 'la giuntura e\' tornata a variare sul solo giorno: le '
              'quattro schede di un oroscopo riprenderebbero la stessa');
    });
  });

  group('Le due famiglie non aprono allo stesso modo', () {
    test('a nessun indice condividono le prime tre parole', () {
      List<String> primeTre(String frase) => frase
          .replaceAll(RegExp(r'[:.]'), '')
          .trim()
          .split(RegExp(r'\s+'))
          .take(3)
          .toList();

      expect(CorrenteDelCielo.giunturaCoiDuePunti.length,
          CorrenteDelCielo.giunturaColPunto.length,
          reason: 'le due famiglie hanno lunghezze diverse, quindi a qualche '
              'indice una delle due non esiste');
      final colpevoli = <String>[];
      for (var i = 0; i < CorrenteDelCielo.giunturaCoiDuePunti.length; i++) {
        final a = primeTre(CorrenteDelCielo.giunturaCoiDuePunti[i]);
        final b = primeTre(CorrenteDelCielo.giunturaColPunto[i]);
        if (a.join(' ').toLowerCase() == b.join(' ').toLowerCase()) {
          colpevoli.add('indice $i: "${a.join(' ')}" in tutte e due');
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'a questi indici le due famiglie aprono con le stesse tre '
              'parole, quindi la scelta fra punto e due punti resta '
              'invisibile:\n${colpevoli.join("\n")}');
    });

    test('e nessuna delle due si ripete al suo interno', () {
      for (final famiglia in [
        CorrenteDelCielo.giunturaCoiDuePunti,
        CorrenteDelCielo.giunturaColPunto,
      ]) {
        expect(famiglia.toSet(), hasLength(famiglia.length),
            reason: 'una famiglia di giunture ripete se stessa: due indici '
                'diversi danno lo stesso attacco');
      }
    });

    test('la forma col punto finisce col punto, e l\'altra coi due punti', () {
      // La ragione per cui le due famiglie esistono e' grammaticale: se si
      // perde la punteggiatura si perde la ragione.
      for (final g in CorrenteDelCielo.giunturaCoiDuePunti) {
        expect(g.endsWith(':'), isTrue, reason: '"$g" non chiede il seguito');
      }
      for (final g in CorrenteDelCielo.giunturaColPunto) {
        expect(g.endsWith('.'), isTrue, reason: '"$g" non chiude il periodo');
      }
    });
  });
}
