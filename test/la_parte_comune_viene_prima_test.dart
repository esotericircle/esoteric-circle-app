// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/chat/testo_del_responso.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA PARTE COMUNE DELL'ISTRUZIONE VIENE PRIMA. Ordine EX voce 05.**
///
/// La cache implicita di Vertex riusa solo l'INIZIO uguale di due richieste.
/// Due persone diverse (nome, forma di cortesia, nascita, memoria, domanda)
/// che parlano con lo stesso Maestro devono ricevere un'istruzione che
/// comincia allo stesso modo almeno fino alla regola del consiglio finale
/// compresa: la voce del Maestro, le regole di lingua, la misura, la forma,
/// i due strati. Prima dell'ordine EX la cortesia e la nascita stavano in
/// mezzo, e l'inizio comune finiva dopo poche righe.
void main() {
  String istruzione(Maestro m,
          {required bool sofia, required bool conSeguito, bool live = false}) =>
      MaestroPersona.systemInstruction(
        maestro: m,
        profile: sofia
            ? UserProfile(
                displayName: 'Sofia', courtesyForm: CourtesyForm.feminine)
            : UserProfile(
                displayName: 'Luca', courtesyForm: CourtesyForm.masculine),
        memory: sofia
            ? const MaestroMemory(
                sessionSummary: 'Abbiamo parlato di Berlino e di Marco.',
                facts: ['lavora in banca', 'ha un cane, Ombra'])
            : const MaestroMemory(
                sessionSummary: 'Abbiamo parlato della bottega di ceramica.',
                facts: ['insegna musica', 'vive a Bologna']),
        natal: sofia
            ? const NatalContext(
                sunSign: 'Cancro',
                moonSign: 'Bilancia',
                ascendant: 'Scorpione',
                lifeNumber: 7,
                lifeNumberTitle: 'il Cercatore')
            : const NatalContext(
                sunSign: 'Ariete',
                moonSign: 'Toro',
                ascendant: 'Leone',
                lifeNumber: 3,
                lifeNumberTitle: 'il Comunicatore'),
        domandaDiAdesso: sofia
            ? 'Il mio capo mi ha offerto un ruolo nuovo. Accetto?'
            : 'Apro la bottega di ceramica?',
        conSeguito: conSeguito,
        nelLive: live,
      );

  int inizioComune(String a, String b) {
    var i = 0;
    while (i < a.length && i < b.length && a.codeUnitAt(i) == b.codeUnitAt(i)) {
      i++;
    }
    return i;
  }

  test('due persone diverse: la stessa istruzione fino al consiglio finale',
      () {
    var casi = 0;
    for (final m in Maestro.values) {
      for (final conSeguito in [false, true]) {
        for (final live in [false, true]) {
          final a =
              istruzione(m, sofia: true, conSeguito: conSeguito, live: live);
          final b =
              istruzione(m, sofia: false, conSeguito: conSeguito, live: live);
          final comune = inizioComune(a, b);
          // Gli ultimi pezzi della parte comune devono stare dentro l'inizio
          // uguale: la forma del testo e il consiglio finale.
          for (final pezzo in [
            TestoDelResponso.vincoloDiFormato,
            ConsiglioFinale.istruzione,
          ]) {
            final fine = a.indexOf(pezzo);
            expect(fine, greaterThanOrEqualTo(0),
                reason: '${m.id}: manca un pezzo della parte comune');
            expect(fine + pezzo.length, lessThanOrEqualTo(comune),
                reason: '${m.id}, seguito $conSeguito, live $live: '
                    'l\'inizio uguale finisce al carattere $comune, prima '
                    'della fine di un pezzo comune (${fine + pezzo.length})');
          }
          if (!conSeguito && !live) {
            print('ORDINE EX VOCE 05, ${m.id}: inizio uguale $comune caratteri '
                'su ${a.length}');
          }
          casi++;
        }
      }
    }
    cardinaleMinimo(casi, 12, cosa: 'istruzioni confrontate');
  });
}
