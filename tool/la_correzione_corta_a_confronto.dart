// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/la_posizione_della_lettura.dart';
import 'package:esoteric_circle/core/chat/le_certezze_del_maestro.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// **LA CORREZIONE CORTA A CONFRONTO.** Ordine EX voce 07.
///
/// La voce cambia una cosa sola: quando una rete scarta una risposta, la
/// correzione si chiede corta invece che con la richiesta intera. Qui si
/// confrontano i due modi sulla STESSA risposta scartata: per ogni domanda
/// si chiede la prima risposta col provider vero; se la rete della prima
/// frase o quella delle certezze la scarta, la stessa correzione si chiede
/// nei due modi, "piena" (com'era prima della voce: istruzione intera,
/// conversazione, funzioni del cielo) e "corta" (la voce). Si fermano a
/// [quanti] risposte scartate.
///
///     QUANTI=24 flutter test -r expanded tool/la_correzione_corta_a_confronto.dart
///
/// Scrive `docs/collaudo/EX/qualita/piena.jsonl` e `corta.jsonl`, nella forma
/// del banco della qualita', per il fascicolo alla cieca.

const _fatti = [
  'lavora in banca da otto anni',
  'vive a Torino con la sorella',
  'ha un cane che si chiama Ombra',
  'sta pensando di trasferirsi a Berlino',
  'ha conosciuto Marco tre mesi fa',
  'ha litigato con la sorella a Natale',
  'dorme male prima delle scadenze',
  'ama la ceramica e vorrebbe aprire una bottega',
  'ha un colloquio a fine mese',
  'medita la mattina presto',
  'ha paura di deludere la madre',
  'ha 34 anni',
];

const _memoria = MaestroMemory(
  sessionSummary: 'Abbiamo parlato a lungo del trasferimento a Berlino, '
      'della relazione con Marco e del lavoro nuovo: la persona cerca una '
      'conferma prima di ogni scelta e ha paura di sbagliare.',
  facts: _fatti,
);

const _natale = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Bilancia',
  ascendant: 'Scorpione',
  lifeNumber: 7,
  lifeNumberTitle: 'il Cercatore',
);

/// Domande che chiedono una presa di posizione (si' o no, una scelta, un
/// quando), dove le due reti scattano piu' spesso, con la memoria che serve
/// accanto quando serve.
const _domande = <(String, Maestro, List<String>)>[
  ('Lui mi ha chiesto di vederci sabato. Ci vado?', Maestro.aura,
      ['ha conosciuto Marco tre mesi fa']),
  ('Il colloquio di fine mese andrà bene?', Maestro.medora,
      ['ha un colloquio a fine mese']),
  ('Mia sorella mi perdonerà per Natale?', Maestro.aura,
      ['ha litigato con la sorella a Natale']),
  ('Mi conviene trasferirmi a Berlino quest\'anno?', Maestro.medora,
      ['sta pensando di trasferirsi a Berlino']),
  ('Apro la bottega di ceramica o resto in banca?', Maestro.caligo,
      ['ama la ceramica e vorrebbe aprire una bottega', 'lavora in banca da otto anni']),
  ('Quando riuscirò a dormire bene?', Maestro.aura,
      ['dorme male prima delle scadenze']),
  ('Mia madre capirà la mia scelta?', Maestro.medora,
      ['ha paura di deludere la madre']),
  ('Marco è la persona giusta per me?', Maestro.medora,
      ['ha conosciuto Marco tre mesi fa']),
  ('Devo dire al mio capo che voglio andarmene?', Maestro.caligo,
      ['lavora in banca da otto anni', 'sta pensando di trasferirsi a Berlino']),
  ('Ombra si abituerà alla nuova casa se mi trasferisco?', Maestro.aura,
      ['ha un cane che si chiama Ombra']),
  ('Il lavoro nuovo arriverà presto?', Maestro.medora, <String>[]),
  ('Lui tornerà da me?', Maestro.aura, <String>[]),
  ('Accetto il ruolo nuovo o aspetto un\'offerta migliore?', Maestro.caligo,
      <String>[]),
  ('Riuscirò a comprare casa entro due anni?', Maestro.medora, <String>[]),
  ('Quando cambierà la mia fortuna?', Maestro.caligo, <String>[]),
  ('Devo scrivergli io o aspettare?', Maestro.aura, <String>[]),
  ('Questo è il momento giusto per cambiare città?', Maestro.medora,
      ['sta pensando di trasferirsi a Berlino']),
  ('Avrò successo con il mio progetto?', Maestro.caligo, <String>[]),
  ('Mi conviene firmare il contratto venerdì?', Maestro.medora, <String>[]),
  ('Sono pronta per una relazione seria?', Maestro.aura,
      ['ha conosciuto Marco tre mesi fa']),
  ('Supererò l\'esame di settembre?', Maestro.caligo, <String>[]),
  ('Il mio amico mi restituirà i soldi?', Maestro.medora, <String>[]),
  ('Vado alla festa di stasera o resto a casa?', Maestro.aura, <String>[]),
  ('Quando troverò la pace con mia sorella?', Maestro.caligo,
      ['ha litigato con la sorella a Natale']),
  ('Sarà un buon mese per il lavoro?', Maestro.medora,
      ['lavora in banca da otto anni']),
  ('Lascio il lavoro in banca per la ceramica?', Maestro.aura,
      ['ama la ceramica e vorrebbe aprire una bottega', 'lavora in banca da otto anni']),
  ('Riuscirò a non deludere mia madre?', Maestro.caligo,
      ['ha paura di deludere la madre']),
  ('Ce la farò a cambiare vita?', Maestro.medora, <String>[]),
  ('Mi sposerò entro i quarant\'anni?', Maestro.aura, ['ha 34 anni']),
  ('Devo fidarmi della mia nuova collega?', Maestro.caligo, <String>[]),
];

List<ChatMessage> _storia(Maestro m) {
  final ora = DateTime.now();
  return [
    for (var i = 0; i < 6; i++) ...[
      ChatMessage(
          role: ChatRole.user,
          text: 'Ti scrivo di nuovo: ci penso ogni giorno.',
          at: ora.subtract(Duration(days: 6 - i))),
      ChatMessage(
          role: ChatRole.maestro,
          autore: m,
          text: 'Guarda con calma ciò che hai davanti e parti da un gesto '
              'concreto.\n✦ Domani mattina fai la telefonata che rimandi.',
          at: ora.subtract(Duration(days: 6 - i, minutes: -1))),
    ],
  ];
}

void main() {
  setUpAll(preparaIlBanco);

  test('la correzione corta a confronto', () async {
    final quanti =
        int.tryParse(Platform.environment['QUANTI'] ?? '') ?? 20;
    final p = FirebaseMaestroAiProvider();
    final profilo = UserProfile(displayName: 'Sofia');
    final piena = <String>[];
    final corta = <String>[];
    var chieste = 0;
    for (var giro = 0; giro < 3 && piena.length < quanti; giro++) {
      for (var i = 0; i < _domande.length && piena.length < quanti; i++) {
        final (domanda, maestro, fatti) = _domande[i];
        final storia = _storia(maestro);
        Future<String> chiedi({String? correzione}) =>
            LaRichiestaDelTurno(domanda: domanda, daCorreggere: correzione)
                .per(() => p.reply(
                      maestro: maestro,
                      profile: profilo,
                      memory: _memoria,
                      history: storia,
                      userMessage: domanda,
                      natal: _natale,
                    ));
        String prima;
        try {
          prima = await chiedi();
          chieste++;
        } catch (e) {
          continue;
        }
        String? correzione;
        if (!LaPosizioneDellaLettura.rispetta(maestro, domanda, prima)) {
          correzione = LaPosizioneDellaLettura.correzione(
              maestro, LaPosizioneDellaLettura.primaFraseDi(prima),
              domanda: domanda);
        } else {
          final certe = LeCertezzeDelMaestro.inQuesteFrasi(prima);
          if (certe.isNotEmpty) {
            correzione = LeCertezzeDelMaestro.correzione(certe);
          }
        }
        if (correzione == null) continue;
        final id = 'X${(piena.length + 1).toString().padLeft(2, '0')}';
        final regPrima = registro.length;
        final pienaTesto = await chiedi(correzione: correzione);
        final regMezzo = registro.length;
        final cortaTesto = await p.correggi(
          maestro: maestro,
          profile: profilo,
          domanda: domanda,
          risposta: prima,
          correzione: correzione,
          memory: _memoria,
        );
        Map<String, Object?> riga(String giro, String testo,
                List<UnaChiamata> chiamate) =>
            {
              'giro': giro,
              'id': id,
              'maestro': maestro.id,
              'tipo': fatti.isEmpty ? 'merito' : 'memoria',
              'nelLive': false,
              'domanda': domanda,
              'scartata': prima,
              'risposta': testo,
              'seguito': null,
              'ripiego': false,
              'errore': null,
              'chiamateRisposta': [
                for (final x in chiamate)
                  {
                    'funzione': x.funzione,
                    'modello': x.modello,
                    'ingresso': x.ingresso,
                    'uscita': x.uscita,
                    'ragionamento': x.ragionamento,
                    'cache': x.dallaCache,
                  }
              ],
              'reteDopo': {
                'posizione': LaPosizioneDellaLettura.rispetta(
                    maestro, domanda, testo),
                'certezze': LeCertezzeDelMaestro.inQuesteFrasi(testo).length,
              },
              'fattiDellaMemoria': fatti,
              'cieloDelleDate': <String>[],
            };
        piena.add(jsonEncode(riga(
            'piena', pienaTesto, registro.sublist(regPrima, regMezzo))));
        corta.add(jsonEncode(
            riga('corta', cortaTesto, registro.sublist(regMezzo))));
        print('$id: scartata e corretta nei due modi');
      }
    }
    final cartella = Directory('docs/collaudo/EX/qualita')
      ..createSync(recursive: true);
    File('${cartella.path}/piena.jsonl').writeAsStringSync('${piena.join('\n')}\n');
    File('${cartella.path}/corta.jsonl').writeAsStringSync('${corta.join('\n')}\n');
    print('CORREZIONE CORTA A CONFRONTO: prime risposte chieste $chieste, '
        'scartate dalle reti ${piena.length}');
  }, timeout: const Timeout(Duration(minutes: 60)));
}
