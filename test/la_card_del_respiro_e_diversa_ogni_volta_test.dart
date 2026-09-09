import 'dart:io';

import 'package:esoteric_circle/features/maestri/aura/meditation/card_del_respiro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA CARD DEL RESPIRO E' DIVERSA OGNI VOLTA.** Ordine DB voce 10, e chiude
/// la voce CZ.09 rimasta ferma su lavoro non montato.
///
/// **Parole dell'ordine**: *"I tempi reali di inspiro e di espiro disegnano una
/// figura. Siccome nessuno respira come un altro, quella figura e' diversa ogni
/// volta e diversa da quella di chiunque."*
///
/// **PERCHE' QUI LA PROMESSA REGGE, e sulla card del Viso non reggeva.**
/// L'8 settembre la card del Viso diceva *"una costellazione su 104.976
/// possibili"*, e a 382 utenti era piu' probabile che due card fossero
/// identiche che il contrario: quella figura nasceva da **caselle**. Questa
/// nasce dalla quota del dentro di ogni respiro, cioe' da numeri in virgola
/// mobile misurati al millisecondo. **La differenza non e' di grado, e' di
/// natura.**
///
/// **REGOLA H.** Non basta provare che due respiri diversi danno figure
/// diverse: si prova anche che **la stessa serie da' la stessa figura**. Una
/// figura che cambia a ogni ridisegno non e' unica, e' casuale, e non e' di
/// nessuno.
void main() {
  test('DUE RESPIRI DIVERSI DANNO FIGURE DIVERSE', () {
    // Due serie che si somigliano molto: se anche queste si distinguono, si
    // distinguono tutte.
    const a = [0.52, 0.48, 0.55, 0.50, 0.53, 0.49];
    const b = [0.52, 0.49, 0.55, 0.50, 0.53, 0.49];
    final distanza = PittoreDellaFigura.distanzaFra(a, b);
    // ignore: avoid_print
    print('ORDINE DB VOCE 10: due respiri quasi uguali distano '
        '${distanza.toStringAsFixed(6)}');
    cardinaleMinimo(a.length, 6,
        cosa: 'respiri nella figura di prova',
        perche: 'Con due o tre respiri due figure si somigliano per forza, e '
            'questa prova direbbe che sono diverse senza averle guardate.');
    expect(distanza, greaterThan(0.0),
        reason: 'due serie di respiri diverse danno la stessa identica '
            'figura: allora la card non e di nessuno');
  });

  test('REGOLA H: la STESSA serie da la stessa figura', () {
    const a = [0.52, 0.48, 0.55, 0.50, 0.53, 0.49];
    expect(PittoreDellaFigura.distanzaFra(a, a), 0.0,
        reason: 'la stessa serie da due figure diverse: la figura e casuale, '
            'non e il respiro di quella persona');
  });

  test('LE TRE RIGHE SONO TRE, e nessuna promette un effetto', () {
    final righe = CardDelRespiro.righeDiAura(
        const [0.52, 0.48, 0.55], DateTime(2026, 9, 9), false);
    // ignore: avoid_print
    print('ORDINE DB VOCE 10: le righe sono\n- ${righe.join("\\n- ")}');
    expect(righe.length, 3,
        reason: 'le righe di Aura sono ${righe.length}: l ordine ne chiede '
            'tre, e una in piu o in meno cambia il peso della card');
    // **NESSUNA PROMESSA**, ordine DB voce 11 applicata al testo della card.
    for (final riga in righe) {
      for (final vietata in const [
        'guarisc', 'cura', 'terapia', 'dolore', 'pressione', 'dna',
        'malattia', 'sintomo', 'battito',
      ]) {
        expect(riga.toLowerCase().contains(vietata), isFalse,
            reason: 'la riga "$riga" contiene "$vietata": e una promessa, e '
                'su una card che gira fra estranei vale doppio');
      }
    }
  });

  test('CHI HA IL RESPIRO GUIDATO LO LEGGE SULLA CARD', () {
    // Ordine DB voce 10: *"chi ha scelto il respiro guidato ottiene la card
    // con la forma del ritmo guidato, dichiarata come tale"*. Sarebbe la
    // figura dell app e non la sua, e spacciarla per sua sarebbe la prima
    // bugia di questa funzione.
    final guidato = CardDelRespiro.righeDiAura(
        const [0.5, 0.5, 0.5], DateTime(2026, 9, 9), true);
    final proprio = CardDelRespiro.righeDiAura(
        const [0.52, 0.48, 0.55], DateTime(2026, 9, 9), false);
    // ignore: avoid_print
    print('ORDINE DB VOCE 10: guidato dice "${guidato.first}", proprio dice '
        '"${proprio.first}"');
    expect(guidato.first.toLowerCase(), contains('guidato'),
        reason: 'la card di chi ha usato il ritmo guidato non lo dichiara: '
            'gli si spaccia per suo un disegno che e dell app');
    expect(proprio.first.toLowerCase(), isNot(contains('guidato')),
        reason: 'la card di chi ha respirato da solo si dichiara guidata');
  });

  test('IL COLORE VIENE DAL CENTRO DI OGGI, e cambia', () {
    final lunedi = CardDelRespiro.righeDiAura(
        const [0.5], DateTime(2026, 9, 7), false);
    final martedi = CardDelRespiro.righeDiAura(
        const [0.5], DateTime(2026, 9, 8), false);
    expect(lunedi[1], isNot(martedi[1]),
        reason: 'la card dice lo stesso centro in due giorni diversi: il '
            'legame col centro di oggi non c e');
  });

  test('LA CARD PASSA DAL PUNTO UNICO DELLA CONDIVISIONE', () {
    // Ordine DB voce 10: *"passa dal punto unico della condivisione. Non se
    // ne scrive un altro."* E' la regola che l ordine P voce 28 ha imposto
    // dopo che i gesti di condivisione erano sparsi in sei posti.
    final sorgente = File(
            'lib/features/maestri/aura/meditation/card_del_respiro.dart')
        .readAsStringSync();
    final codice = senzaCommenti(sorgente);
    expect(codice.contains('PortaDellaCondivisione.daFile'), isTrue,
        reason: 'la card non passa dalla porta unica: e un secondo punto di '
            'condivisione, e fra sei mesi i due si comporteranno diversamente');
    // **E non apre nessuna strada sua verso la rete.**
    for (final vietata in const ['http', 'Uri.parse', 'Storage']) {
      expect(codice.contains(vietata), isFalse,
          reason: 'la card del respiro conosce "$vietata": deve passare dalla '
              'porta e non parlare da sola');
    }
  });
}
