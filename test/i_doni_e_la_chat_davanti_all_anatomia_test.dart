import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
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

  test('MISURA: dove sta ognuna delle tre parti dentro l\'istruzione della chat',
      () {
    // **QUESTA PROVA DICHIARA, e il numero che stampa e' la voce S.28.** La chat
    // esprime le tre parti dell'anatomia, ma con parole SUE e in tre punti diversi:
    // - la RISPOSTA e' la "frase di sintesi" piu' il "testo narrato" della struttura
    //   a quattro strati, che viene dai briefing e non da `ParteDelResponso`;
    // - COSA PUOI FARE e' `ConsiglioFinale.istruzione`, che vive in un punto suo;
    // - DA DOVE VIENE e' la regola dell'ancoraggio, che pretende che la risposta
    //   nomini i dati della persona.
    //
    // **Sono due anatomie scritte in due posti**, ed e' la famiglia delle due porte
    // che quest'ordine esiste per chiudere. Non si tocca qui, e la ragione sta nel
    // manifesto: cambiare l'istruzione di sistema invalida l'attribuzione cieca
    // delle tre voci, misurata al 98,3 per cento, che si rifa' solo con una chiamata
    // vera a Vertex.
    final istruzione = MaestroPersona.systemInstruction(
      maestro: Maestro.medora,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );
    final trovate = <String, bool>{};
    for (final parte in ParteDelResponso.nelResponso) {
      trovate[parte.nome] = istruzione.contains(parte.nome);
    }
    // ignore: avoid_print
    print('ORDINE S VOCE 28: parti dell\'anatomia nominate nell\'istruzione della '
        'chat: $trovate');
    // Cio' che la chat porta davvero, e che si presidia: il consiglio finale c'e',
    // e la struttura a quattro strati anche.
    expect(istruzione, contains(ConsiglioFinale.istruzione),
        reason: 'la chat non chiede piu\' il consiglio finale: e\' la parte che '
            'fa tornare, ed e\' cio\' che nell\'anatomia si chiama "cosa puoi '
            'fare"');
    expect(istruzione, contains('ANATOMIA A QUATTRO STRATI'),
        reason: 'la struttura della risposta e\' sparita dall\'istruzione');
  });
}
