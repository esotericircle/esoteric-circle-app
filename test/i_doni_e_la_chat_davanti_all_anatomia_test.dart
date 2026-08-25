import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/responsi/dove_la_chat_porta_ogni_parte.dart';
import 'package:esoteric_circle/services/ai/impronta_dell_istruzione.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/responsi/legge_del_responso.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// I DONI DEL GIORNO E LA CHAT DAVANTI ALL'ANATOMIA. Ordine S voce 28.
///
/// **Cosa chiede la voce:** che i doni quotidiani e la chat dei Maestri applichino
/// la legge (S.15), l'anatomia (S.16) e il confine (S.17), come le altre arti.
///
/// **La misura viene prima della correzione**, come nelle voci S.23 e S.27. Qui la
/// misura ha trovato due situazioni diverse, e vale la pena distinguerle: i doni
/// sono righe singole per costruzione, la chat e' un discorso.
void main() {
  test('i doni del giorno stanno dentro il confine della voce S.17', () {
    // I tre doni deterministici: la riga dell'Oracolo, il messaggio del mattino e
    // il saluto della notte. ENUMERA i 366 giorni per ciascuno, che e' il corpus
    // intero, non un campione.
    final violazioni = <String>[];
    for (var giorno = 1; giorno <= 366; giorno++) {
      final quando = DateTime(2026, 1, 1).add(Duration(days: giorno - 1));
      final testi = <String, String>{
        'oracolo': DailyRituals.dayOracle(quando),
        'alba': DailyRituals.dawnMessage(quando),
        'sogno': DailyRituals.nightMessage(quando),
      };
      for (final voce in testi.entries) {
        final v = ConfineDelResponso.violazioni(voce.value);
        if (v.isNotEmpty) {
          violazioni.add('${voce.key} giorno $giorno: ${v.join("; ")}');
        }
      }
    }
    expect(violazioni, isEmpty, reason: violazioni.take(8).join('\n'));
  });

  test('i doni sono UNA RIGA, e non fingono di essere un responso intero', () {
    // **LA DISTINZIONE CHE LA VOCE CHIEDE DI FARE.** Un dono del giorno e' il colpo
    // d'occhio: una riga sola che si legge in due secondi, e l'azione la porta il
    // rito che gli sta attorno, non la riga. Pretendere le tre parti dell'anatomia
    // dentro settanta caratteri vorrebbe dire trasformare un dono in un responso, e
    // sarebbe la voce S.20 al contrario: la' si e' accorciato cio' che era lungo,
    // qui si allungherebbe cio' che e' corto per farlo somigliare a una regola.
    //
    // Quindi la misura non chiede tre parti: chiede che restino UNA riga, cioe' che
    // nessuno le allunghi di nascosto fino a farle diventare mezzo responso.
    var massimo = 0;
    var quale = '';
    for (var giorno = 1; giorno <= 366; giorno++) {
      final quando = DateTime(2026, 1, 1).add(Duration(days: giorno - 1));
      for (final voce in {
        'oracolo': DailyRituals.dayOracle(quando),
        'alba': DailyRituals.dawnMessage(quando),
        'sogno': DailyRituals.nightMessage(quando),
      }.entries) {
        if (voce.value.length > massimo) {
          massimo = voce.value.length;
          quale = '${voce.key} giorno $giorno';
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE S VOCE 28: il dono piu\' lungo e\' $massimo caratteri ($quale)');
    // **IL TETTO E' 120, dichiarato:** il censimento della voce S.18 misura 76 come
    // massimo dei tre doni, e 120 e' il tetto che lascia mezza riga di crescita
    // senza permettere che un dono diventi un paragrafo. Non e' il massimo misurato
    // arrotondato: e' la misura oltre la quale una riga smette di essere una riga.
    expect(massimo, lessThan(120),
        reason: 'un dono del giorno e\' arrivato a $massimo caratteri ($quale): '
            'non e\' piu\' un colpo d\'occhio, e' ' l\'azione la porta il rito, '
            'non la riga');
  });

  test('la chat porta la legge e il confine, dal punto unico', () {
    // Gia' presidiato altrove, e qui si tiene insieme il quadro della voce: la
    // legge della S.15 e il confine della S.17 arrivano al modello da `_commonRules`
    // e non riscritti con parole loro.
    for (final maestro in Maestro.values) {
      final istruzione = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      expect(istruzione, contains(LeggeDelResponso.perIlModello.split('\n').first),
          reason: '${maestro.id}: la legge del responso non arriva alla chat');
      expect(istruzione,
          contains(ConfineDelResponso.perIlModello.split(':').first),
          reason: '${maestro.id}: il confine non arriva alla chat');
    }
  });

  test('ogni parte del responso ha un posto dichiarato nella chat', () {
    // **QUESTA PROVA ERA UNA DICHIARAZIONE ED E' DIVENTATA UN LEGAME.** Diceva quali
    // parti dell'anatomia l'istruzione NOMINA, e la risposta era zero su tre. Era
    // vera, ed e' stata SUPERATA dalla decisione del 13 agosto: le tre parti sono
    // l'obbligo di CONTENUTO di un responso, i quattro strati sono la FORMA di una
    // risposta di chat, e sono due assi diversi. Pretendere che l'istruzione usi le
    // stesse parole fonderebbe due distinzioni utili in un vocabolario solo.
    //
    // Cio' che si pretende adesso: che ogni parte abbia un POSTO DICHIARATO. **Il
    // giorno che nasce una quarta parte dentro il responso e nessuno le trova una
    // casa nella chat, questa riga cade**, ed e' la ragione per cui la voce si chiude
    // qui invece che di nuovo fra sei mesi.
    var osservate = 0;
    final senzaCasa = <String>[];
    for (final parte in ParteDelResponso.nelResponso) {
      osservate++;
      if (DoveLaChatPortaOgniParte.per(parte) == null) {
        senzaCasa.add(parte.nome);
      }
    }
    expect(senzaCasa, isEmpty,
        reason: 'queste parti del responso non hanno un posto dichiarato nella '
            'chat: ${senzaCasa.join(", ")}');
    // **QUANTE OSSERVAZIONI, e cade se sono zero.** Lezione della voce S.27: una
    // prova che enumera puo' girare a vuoto e sembrare forte lo stesso.
    // ignore: avoid_print
    print('ORDINE S VOCE 28: parti osservate $osservate');
    expect(osservate, greaterThan(0),
        reason: 'la prova ha enumerato zero parti: non ha guardato niente');
    // E la tradizione NON deve avere una casa nella chat: vive nel pannello delle
    // fonti, e `dentroIlResponso` falso e' il modo in cui l'anatomia lo dice.
    expect(DoveLaChatPortaOgniParte.per(ParteDelResponso.tradizione), isNull,
        reason: 'la tradizione ha un posto dentro la chat: l\'anatomia dice che '
            'sta nel pannello delle fonti');
  });

  test('ogni posto dichiarato e\' vivo dentro la STRINGA EMESSA', () {
    // **NON SI LEGGE IL SORGENTE DEL COMPOSITORE.** Leggere il file direbbe che la
    // riga e' scritta, non che arriva al modello: si compone la stringa vera e ci si
    // cerca dentro il marcatore.
    var osservate = 0;
    final morti = <String>[];
    for (final maestro in Maestro.values) {
      final istruzione = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      for (final posto in DoveLaChatPortaOgniParte.tutte) {
        osservate++;
        if (!istruzione.contains(posto.marcatore)) {
          morti.add('${maestro.id}: "${posto.marcatore}" (${posto.parte.nome}) '
              'non e\' nella stringa emessa');
        }
      }
    }
    expect(morti, isEmpty, reason: morti.join(' | '));
    // ignore: avoid_print
    print('ORDINE S VOCE 28: marcatori cercati nella stringa emessa $osservate');
    expect(osservate, greaterThan(0),
        reason: 'la prova non ha cercato nessun marcatore: gira a vuoto');
  });

  test('l\'impronta dell\'istruzione coincide con quella registrata', () {
    // **LA GUARDIA CHE MANCAVA, ed e' il motivo per cui 636 caratteri sono entrati
    // nell'artefatto piu' fragile del progetto senza che una riga cadesse.**
    var osservate = 0;
    final cambiate = <String>[];
    for (final maestro in Maestro.values) {
      final istruzione = MaestroPersona.systemInstruction(
        maestro: maestro,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      final impronta = sha256.convert(utf8.encode(istruzione)).toString();
      osservate++;
      final registrata = ImprontaDellIstruzione.per(maestro);
      if (impronta != registrata) {
        cambiate.add('${maestro.id}: adesso $impronta, registrata $registrata');
      }
    }
    // ignore: avoid_print
    print('ORDINE S VOCE 28: impronte confrontate $osservate');
    expect(osservate, greaterThan(0));
    expect(cambiate, isEmpty,
        reason: 'l\'istruzione di sistema e\' cambiata rispetto a quella registrata '
            'il ${ImprontaDellIstruzione.registrateIl}. Non e\' vietato cambiarla: '
            'e\' vietato cambiarla in silenzio. Rilancia l\'attribuzione cieca e '
            'aggiorna le impronte, oppure dichiara nel rapporto che si consegna '
            'con una misura non valida. ${cambiate.join(" | ")}');
  });

  test('lo storico porta le impronte cadute, e nessuna di quelle di oggi', () {
    // **UNA COSTANTE CHE NESSUNO LEGGE E' UN COMMENTO CON LA SINTASSI DI DART.**
    // Lo storico esiste per dire a quale stringa appartiene una misura vecchia,
    // e il modo di sbagliare che si presidia qui e' preciso: cambiare
    // l'istruzione, aggiornare le impronte e LASCIARE nello storico quella
    // appena registrata, cosi' che la stessa impronta risulti insieme viva e
    // caduta. Da quel momento lo storico direbbe il falso.
    final storico = ImprontaDellIstruzione.storicoDelleImpronte;
    expect(storico, isNotEmpty,
        reason: 'lo storico e\' vuoto: la prima impronta caduta e\' del 2 '
            'agosto 2026 e non puo\' essere sparita');
    final testo = storico.join(' ');
    for (final entry in ImprontaDellIstruzione.impronte.entries) {
      expect(testo.contains(entry.value), isFalse,
          reason: 'l\'impronta di ${entry.key} risulta insieme registrata e '
              'caduta: una delle due dice il falso');
    }
  });

  test('l\'attribuzione cieca e\' valida su QUESTA istruzione', () {
    // **QUESTA PROVA NASCE ROSSA, IL 13 AGOSTO 2026, ED E' GIUSTO COSI': dice il
    // vero.** L'attribuzione cieca fu misurata il 2 agosto al 98,3 per cento; l'11
    // agosto il commit 97bb997, voci S.15 e S.17, ha aggiunto 636 caratteri netti
    // all'istruzione di tutti e tre i Maestri. Quel numero appartiene a una stringa
    // che non esiste piu'.
    //
    // **Il rosso e' la dichiarazione resa eseguibile.** Scrivere il 98,3 accanto
    // all'impronta di oggi sarebbe mettere il falso dentro un dato; lasciarlo in un
    // commento lo renderebbe ignorabile. Questa riga torna verde quando la misura
    // viene rifatta, e non prima.
    expect(ImprontaDellIstruzione.attribuzioneValida, isTrue,
        reason: 'LA MISURA DELL\'ATTRIBUZIONE CIECA NON E\' VALIDA su questa '
            'istruzione. Ultima misura nota: '
            '${ImprontaDellIstruzione.ultimaMisuraNota} Come si rimisura: '
            '${ImprontaDellIstruzione.comeSiRimisura}');
  });

}
