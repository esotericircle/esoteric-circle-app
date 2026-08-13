import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CONSIGLIO DEI TAROCCHI E L'ANATOMIA DEL RESPONSO. Ordine S voce 26.
///
/// **Cosa misura, e cosa NON tocca.** La voce S.26 chiede che i tarocchi applichino
/// la legge (S.15), l'anatomia (S.16) e il confine (S.17). Il confine gia' li
/// setaccia in `il_confine_del_responso_test`. Qui si misura l'ANATOMIA, e si
/// presidia l'unico pezzo che oggi e' al posto giusto: **il simbolo non compare nella
/// prima parte del consiglio**.
///
/// **La parte che manca non si inventa.** La misura scritta nel manifesto dice che il
/// consiglio dei tarocchi porta la parte 2 (cosa puoi fare) e la parte 3 (da dove
/// viene), ma NON la parte 1: la bolla apre con l'azione, e chi legge riceve un
/// consiglio prima di sapere cosa la lettura vede. Rimettere le due parti nell'ordine
/// dell'anatomia richiede un testo che non esiste, e i testi dei responsi sono
/// materiale dell'Architetto: e' scritto nel manifesto e la voce aspetta li'.
void main() {
  /// Il punto in cui il consiglio passa dall'azione al simbolo. E' una cucitura
  /// dichiarata nel compositore, non una stringa indovinata qui: se cambia, questa
  /// prova cade e chiede di aggiornarla di proposito.
  const cucitura = 'Le tre carte lo dicono insieme.';

  test('la cucitura fra consiglio e carte esiste in ogni lettura', () {
    final senza = <String>[];
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < 8; seme++) {
        final lettura = TarotReading.of(TarotSpread.draw(seed: seme), t);
        if (!lettura.consiglio.contains(cucitura)) {
          senza.add('${t.name} seme $seme');
        }
      }
    }
    expect(senza, isEmpty,
        reason: 'in queste letture non c\'e\' la cucitura "$cucitura", quindi '
            'non si puo\' piu\' dire dove finisce il consiglio e dove '
            'cominciano le carte:\n${senza.take(6).join("\n")}');
  });

  test('nessuna carta e\' nominata PRIMA della cucitura', () {
    // **LA REGOLA DELL@ANATOMIA: il simbolo compare in "da dove viene" e non prima.**
    // Nel consiglio dei tarocchi il simbolo arriva dopo la cucitura, ed e' l'unico
    // pezzo dell'anatomia che oggi sta al posto giusto: questa prova lo tiene li'.
    final colpe = <String>[];
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < 8; seme++) {
        final spread = TarotSpread.draw(seed: seme);
        final lettura = TarotReading.of(spread, t);
        final prima =
            lettura.consiglio.substring(0, lettura.consiglio.indexOf(cucitura));
        for (final c in spread.cards) {
          if (prima.contains(c.card.name) || prima.contains(c.displayName)) {
            colpe.add('${t.name} seme $seme: "${c.card.name}" prima della '
                'cucitura');
          }
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'una carta e\' nominata nella prima parte del consiglio: chi '
            'legge riceve il simbolo prima della risposta, ed e\' la regola '
            'che l\'anatomia della voce S.16 vieta:\n${colpe.take(6).join("\n")}');
  });

  test('la domanda di chiusura sta in fondo, e una volta sola', () {
    // La domanda e' il gancio di ritorno: se finisse in mezzo, spezzerebbe la
    // lettura invece di chiuderla.
    for (final t in TarotTopic.values) {
      final lettura = TarotReading.of(TarotSpread.draw(seed: 4), t);
      expect(lettura.consiglio.trimRight().endsWith(lettura.domanda), isTrue,
          reason: '${t.name}: la domanda di chiusura non chiude il consiglio');
      expect(lettura.domanda.allMatches(lettura.consiglio).length, 1,
          reason: '${t.name}: la domanda compare piu\' di una volta');
    }
  });

  test('la RISPOSTA viene prima dell\'AZIONE, come dice l\'anatomia', () {
    // **QUESTA PROVA ERA UNA DICHIARAZIONE ED E' DIVENTATA UNA GUARDIA.**
    //
    // Fino al 13 agosto 2026 diceva: il consiglio dei tarocchi porta la parte 2 e la
    // parte 3, e non la parte 1. Non giudicava, teneva vero il numero scritto nel
    // manifesto, e cadeva se la parte 1 fosse arrivata senza che nessuno aggiornasse
    // la voce. **E' successo esattamente questo:** l'allegato C ha portato le tre
    // risposte, il montaggio le ha messe al loro posto, e la prova e' caduta
    // chiedendo di aggiornare la voce S.26. Adesso presidia l'ordine invece di
    // dichiarare la mancanza.
    //
    // La grandezza misurata: dove comincia la risposta e dove comincia l'azione
    // dentro la stessa bolla. Se un giorno si invertissero, chi legge riceverebbe di
    // nuovo un consiglio prima di sapere cosa la lettura vede.
    for (final t in TarotTopic.values) {
      final lettura = TarotReading.of(TarotSpread.draw(seed: 4), t);
      final consiglio = lettura.consiglio;
      final doveRisposta = consiglio.indexOf(t.group.risposta);
      final doveAzione = consiglio.indexOf(t.group.consiglio);
      expect(doveRisposta, greaterThanOrEqualTo(0),
          reason: '${t.name}: la risposta del gruppo non c\'e\' nel consiglio');
      expect(doveAzione, greaterThan(0),
          reason: '${t.name}: l\'azione del gruppo non c\'e\' nel consiglio');
      expect(doveRisposta, lessThan(doveAzione),
          reason: '${t.name}: l\'azione viene prima della risposta, e l\'anatomia '
              'della voce S.16 dice il contrario');
      // E la bolla APRE con la lente dell'argomento, che e' cio' che rende sedici
      // aperture diverse da tre soli testi.
      expect(consiglio.startsWith('${t.lente}, '), isTrue,
          reason: '${t.name}: il consiglio non apre con la lente');
    }
    // Le tre parti dell'anatomia restano quelle: se ne nascesse una quarta dentro il
    // responso, questa misura parlerebbe di un altro oggetto.
    expect(ParteDelResponso.nelResponso.length, 3);
  });
}