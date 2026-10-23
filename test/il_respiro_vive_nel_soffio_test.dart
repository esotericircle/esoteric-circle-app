import 'dart:io';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// IL RESPIRO GUIDATO VIVE NEL SOFFIO, E IN NESSUN ALTRO RITO. Ordine S voce 13.
///
/// **Il fatto.** Nell'Alba era comparsa la meditazione col respiro, arrivata come
/// effetto collaterale della voce P.17: quella voce aveva ragione a togliere
/// l'istruzione scritta ("tre dentro e tre fuori, sei giri"), che era un compito
/// da contare a mente, ma il rimedio ha portato il respiro guidato DENTRO ogni
/// dono del giorno. Il rito del mattino e' diventato il contenitore di un altro
/// rito.
///
/// **PERCHE' SI GUARDA CHI MONTA LA GUIDA, e non una schermata sola.** La guida
/// del respiro e' un widget del design system: la domanda della voce non e' "l'Alba
/// ce l'ha?" ma "chi ce l'ha, e ha il diritto di averla?". Percio' la prova
/// ENUMERA i montaggi in tutto `lib` e ammette un solo padrone.
void main() {
  test('la guida del respiro la monta solo il Soffio del Destino', () {
    final montaggi = <String>[];
    for (final voce in sorgentiDiLib()) {
      final percorso = voce.path.replaceAll('\\', '/');
      // Il componente stesso non conta: e' la sua definizione.
      if (percorso.endsWith('guida_del_respiro.dart')) continue;
      final righe = voce.readAsStringSync().split('\n');
      for (final riga in righe) {
        if (riga.trimLeft().startsWith('//')) continue;
        if (riga.contains('GuidaDelRespiro(')) {
          montaggi.add(percorso);
          break;
        }
      }
    }
    expect(montaggi, ['lib/features/rituals/breath_destiny_screen.dart'],
        reason: 'la guida del respiro e\' montata da: $montaggi. Il respiro '
            'guidato appartiene al Soffio del Destino ed e\' li\' che vive: un '
            'altro rito che se lo incastra dentro diventa il contenitore di un '
            'rito che non e\' suo');
  });

  test('dal dono del giorno al respiro NON si va piu', () {
    // **QUESTA PROVA E' STATA RIBALTATA, e la ragione va detta.** Ordine BB
    // voce 07: il fondatore ha chiesto di togliere il ponte dall'Alba al
    // Soffio, e prima di lui la voce 13 dell'ordine S lo aveva messo.
    //
    // **Tutte e due le decisioni sono sue e nessuna era sbagliata**: la voce S
    // toglieva il rito del Soffio incastrato dentro l'Alba, e lasciare una
    // porta era il modo piu' gentile di farlo. La voce BB dice che anche
    // quella porta e' di troppo, perche' **ogni dono ha la sua ora e il suo
    // posto nella fascia**, e chi arriva all'Alba non va mandato altrove.
    //
    // Cio' che questa prova sorveglia non cambia: **il respiro guidato non
    // torna dentro la scheda del dono**, che era il difetto vero della voce S.
    final scheda =
        File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
    expect(scheda.contains('ponte_verso_il_soffio'), isFalse,
        reason: 'dal dono del giorno si va ancora al Soffio: la voce BB 07 '
            'chiede che un dono non faccia da corridoio a un altro dono');
    expect(scheda.contains('GuidaDelRespiro('), isFalse,
        reason: 'il respiro guidato e tornato dentro la scheda del dono, ed e '
            'il difetto che la voce S 13 aveva chiuso');
  });

  test('solo il Soffio dichiara di guidare il respiro in scena', () {
    // Il dato che governa tutto sta in un punto solo, e questa prova lo tiene
    // vero: se domani un altro dono dicesse di guidare il respiro, la scheda
    // smetterebbe di offrirgli il ponte senza che nessuno se ne accorga.
    final chiLoGuida =
        DailyElement.values.where((d) => d.guidaIlRespiroInScena).toList();
    expect(chiLoGuida, [DailyElement.breath],
        reason:
            'questi doni dicono di guidare il respiro in scena: $chiLoGuida');
  });
}
