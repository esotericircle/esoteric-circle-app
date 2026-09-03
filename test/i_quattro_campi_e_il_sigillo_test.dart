import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/sigilli/stato_del_sigillo.dart';
import 'package:flutter_test/flutter_test.dart';


/// I QUATTRO CAMPI E IL SIGILLO, ordine P voci 19, 20 e 21, con la CORREZIONE
/// del 12 agosto 2026 che ha priorita' su P.19.
///
/// **Cosa vale e cosa no.** Le tre guardie quantitative dell'ordine O restano
/// in vigore e vincono sull'Allegato A: stanno in
/// `test/i_traguardi_del_cammino_test.dart` e non si toccano. Gli obiettivi
/// restano quelli dell'ordine O. Dall'Allegato si prendono nome, perche' conta
/// e cosa apre. Il campo COSA APRE e' obbligatorio su tutti e 165.
void main() {
  final tutti = [
    for (final s in Sentiero.values) ...Sentieri.di(s),
  ];

  group('P.19 i quattro campi', () {
    test('sono 165 e nessuno dei quattro campi e\' vuoto', () {
      expect(tutti, hasLength(165));
      // SI CONTANO LE PAROLE, non i caratteri: "la prima Sefirah." e' un cosa
      // apre buono e corto, e una soglia sui caratteri lo boccerebbe per la
      // ragione sbagliata. Il criterio e' che il campo DICA qualcosa, cioe' che
      // nomini un soggetto, non che riempia una riga: tre parole sono il minimo
      // per dire qualcosa, e il testo piu' corto dell'Allegato A ne ha sette,
      // quindi la soglia sta sotto ai testi veri di proposito. Serve a prendere
      // un campo dimenticato, non a giudicare la prosa dell'Architetto.
      int quanteParole(String t) =>
          t.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;
      final vuoti = <String>[];
      for (final t in tutti) {
        if (t.nome.trim().isEmpty) vuoti.add('${t.id}: nome');
        if (t.frase.trim().isEmpty) vuoti.add('${t.id}: frase');
        if (quanteParole(t.percheConta) < 3) vuoti.add('${t.id}: perche conta');
        // **LA PORTA NON E' PIU' SU TUTTI E 165, ordine AR voce 02.** Nel
        // corpus della revisione C `porta_che_apre` e' dichiarata su 33 voci:
        // dove il file non la dice, non si inventa. Si pretende che, dove
        // c'e', dica qualcosa.
        if (t.cosaApre.trim().isNotEmpty && t.cosaApre.trim().length < 4) {
          vuoti.add('${t.id}: cosa apre');
        }
      }
      expect(vuoti, isEmpty,
          reason: 'questi traguardi non portano tutti e quattro i campi:\n'
              '${vuoti.join("\n")}');
    });

    test('COSA APRE e\' la regola di ammissione, su tutti e 165', () {
      // Un traguardo che non apre niente non entra nell'elenco. Il campo
      // nomina sempre qualcosa: un traguardo successivo, una funzione, un
      // momento della giornata.
      for (final t in tutti) {
        expect(t.cosaApre, isNot(contains('—')),
            reason: 'trattino lungo in ${t.id}');
      }
      // **LA PORTA NON E' PIU' SU TUTTI E 165, ordine AR voce 02**: la
      // revisione C la dichiara su 33 voci, e le altre sono gradini che
      // valgono per se stessi. Inventarne una sarebbe scrivere al posto del
      // corpus.
      final conPorta = tutti.where((t) => t.cosaApre.trim().isNotEmpty).length;
      // ignore: avoid_print
      print('ORDINE AR VOCE 02: traguardi che aprono una porta $conPorta');
      expect(conPorta, greaterThan(20),
          reason: 'quasi nessun traguardo apre piu niente: il Cammino ha '
              'smesso di portare da qualche parte');
    });

    test('l\'obiettivo e\' ancora quello dell\'ordine O', () {
      // La correzione lo dice: gli obiettivi non si sostituiscono, sono la
      // parte che passa le guardie. La condizione tipizzata E' l'obiettivo.
      for (final t in tutti) {
        expect(t.condizione, isNotNull, reason: t.id);
      }
      // E l'aritmetica resta quella decisa: 2.010 per sentiero, 6.030 in tutto.
      for (final s in Sentiero.values) {
        final somma = Sentieri.di(s).fold<int>(0, (a, t) => a + t.eos);
        expect(somma, 2010, reason: 'il sentiero ${s.name} somma $somma Eos');
      }
      expect(tutti.fold<int>(0, (a, t) => a + t.eos), 6030);
    });

    test('i primi gradini di ogni sentiero portano un premio vero', () {
      // **I TRE SIGILLI DI AGGANCIO NON ESISTONO PIU', ordine AR voce 02.**
      // Erano carta natale, Angelo e Animale ripetuti sui tre sentieri, e
      // l'ordine U li ha tolti perche' un gesto solo li accendeva tutti e
      // tre; la revisione C non li riporta. Anche il venti fisso viene dal
      // vecchio calcolo: adesso i premi li scrive il corpus. Resta la pretesa
      // che il primo premio arrivi presto e non sia avaro.
      for (final s in Sentiero.values) {
        final primi = Sentieri.di(s).where((t) => t.posizione <= 3).toList();
        expect(primi, hasLength(3));
        for (final t in primi) {
          expect(t.eos, greaterThanOrEqualTo(10),
              reason: '${t.id} vale ${t.eos} Eos: il primo premio deve '
                  'arrivare presto e sembrare generoso');
        }
      }
    });

    test('l\'Allegato A e\' nel repo, ed e\' la sorgente dei tre campi', () {
      final allegato = File('docs/ordini/ORDINE_P_ALLEGATO_A.md');
      expect(allegato.existsSync(), isTrue,
          reason:
              'se al momento di eseguire l\'allegato non c\'e\', la voce si '
              'ferma dichiarando premessa mancante');
      final testo = allegato.readAsStringSync();
      // Quanti dei 165 hanno preso il testo dall'Allegato: si conta cercando
      // il "cosa apre" dentro l'allegato, invece di crederci.
      // **LA SORGENTE DEI TRE CAMPI E' PASSATA AL CORPUS, ordine BS voce 01.**
      // L'Allegato A resta nel repo e resta la ragione per cui i quattro campi
      // esistono, ma i testi vivi sono quelli della revisione E, che il
      // fondatore ha scritto dopo: la E porta un "cosa apre" su tutte e 165 le
      // voci, mentre la D2 ne lasciava centotrentadue vuote. **La pretesa non
      // cambia: i tre campi vengono da una fonte scritta e non dall'inventiva
      // del codice**, e qui si controlla contro quella fonte.
      expect(testo.isNotEmpty, isTrue,
          reason: 'l\'Allegato A esiste ma e\' vuoto');
      // **I DONI HANNO CAMBIATO NOME DOPO IL CORPUS.** L'Oracolo del Giorno e'
      // diventato l'Arcano del Giorno e il Rito del Sogno il Sigillo del
      // Sogno: sono decisioni di prodotto prese dopo, e il generatore le
      // applica mentre scrive. Qui si applicano anche al corpus prima di
      // confrontare, altrimenti due voci su 165 sembrerebbero inventate
      // mentre sono le uniche due che portano il nome di oggi.
      // **IL CORPUS VIVO E' LA REVISIONE F, ordine CP voce 05, e le due
      // trasformazioni non servono piu'.** La revisione E scriveva "Oracolo
      // del Giorno" e "e'", e il generatore rinominava e accentava mentre
      // scriveva: il confronto doveva rifare le stesse due trasformazioni,
      // cioe' due porte in piu' sullo stesso dato. La revisione F scrive nel
      // dato quello che finisce a video, e il confronto e' byte per byte.
      final corpusVivo =
          File('docs/corpus/Traguardi_165_Revisione_F.json').readAsStringSync();
      final presi = tutti
          .where((t) =>
              t.cosaApre.trim().isNotEmpty &&
              corpusVivo.contains(t.cosaApre.trim()))
          .length;
      expect(presi, greaterThan(0),
          reason: 'nessuno dei 165 porta un testo del corpus vivo: '
              'l\'accostamento non ha funzionato');
      expect(presi, tutti.length,
          reason: 'solo $presi dei ${tutti.length} portano il loro "cosa apre" '
              'dal corpus: gli altri se lo sono inventato');
    });
  });

  group('P.21 il Sigillo sospeso', () {
    test('gli stati sono cinque e si enumerano', () {
      expect(StatoDelSigillo.values, hasLength(5));
    });

    test('NESSUNO stato lascia una casella grigia dopo un traguardo raggiunto',
        () {
      // E' la prova che la voce 21 chiede per nome: si attraversano tutte le
      // combinazioni dei quattro fatti, non solo quelle che ci si ricorda.
      final buchi = <String>[];
      for (final raggiunto in [true, false]) {
        for (final condiviso in [true, false]) {
          for (final bloccato in [true, false]) {
            for (final prossimo in [true, false]) {
              final stato = StatoDeiSigilli.di(
                raggiunto: raggiunto,
                condiviso: condiviso,
                bloccato: bloccato,
                eIlProssimo: prossimo,
              );
              if (raggiunto && !stato.acceso) {
                buchi.add('raggiunto=$raggiunto condiviso=$condiviso '
                    'bloccato=$bloccato prossimo=$prossimo -> ${stato.name}');
              }
              if (raggiunto && !stato.riapreLaCard) {
                buchi.add('${stato.name} non riapre la card');
              }
            }
          }
        }
      }
      expect(buchi, isEmpty,
          reason: 'questi stati lasciano il journal con una casella grigia '
              'dopo un traguardo raggiunto:\n${buchi.join("\n")}');
    });

    test('il raggiungimento vince sul piano e sulla condivisione', () {
      // La contraddizione chiusa dalla voce 19: il Sigillo si accende SEMPRE
      // al raggiungimento, e la condivisione governa solo il bonus.
      expect(
          StatoDeiSigilli.di(
              raggiunto: true,
              condiviso: false,
              bloccato: true,
              eIlProssimo: false),
          StatoDelSigillo.sospeso);
      expect(
          StatoDeiSigilli.di(
              raggiunto: true,
              condiviso: true,
              bloccato: true,
              eIlProssimo: false),
          StatoDelSigillo.compiuto);
    });

    test('solo il sospeso pulsa, e solo lui porta la marcatura', () {
      for (final s in StatoDelSigillo.values) {
        expect(s.pulsa, s == StatoDelSigillo.sospeso, reason: s.name);
        expect(s.marcatura != null, s == StatoDelSigillo.sospeso,
            reason: s.name);
      }
    });

    test('il gradino chiede lo stato al dato, non combina booleani a mente',
        () {
      final sorgente =
          File('lib/features/sigilli/sentiero_screen.dart').readAsStringSync();
      expect(sorgente, contains('StatoDeiSigilli.di('),
          reason: 'il gradino e\' tornato a decidere il suo aspetto da tre '
              'booleani sparsi');
    });
  });

  group('P.20 la celebrazione', () {
    test('porta al punto del journal dove il Sigillo si e\' acceso', () {
      final sorgente =
          File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
      expect(sorgente, contains('celebrazione_vai_al_sigillo'),
          reason: 'la festa non porta piu\' al Sigillo appena acceso: si '
              'chiudeva su se stessa e il sentiero bisognava ritrovarlo');
      expect(sorgente, contains('SentieroScreen.route'));
      // **LE DUE INTENSITA' NON ESISTONO PIU', ordine BE voce 05.** La
      // seconda intensita' era la sovrimpressione breve, che sulla 2199 il
      // fondatore ha riconosciuto come la card vecchia e ha fatto demolire:
      // "ELIMINA TUTTO CIO' CHE E' VECCHIO E GIA' SOSTITUITO". La scena e'
      // una per tutti, e il mini non passa in silenzio: celebra pieno, al
      // ritmo della coda di BD.08.
      expect(sorgente, isNot(contains('mostraLaSovrimpressione')),
          reason: 'la seconda intensita\' e\' tornata: la card vecchia che '
              'il fondatore ha fatto demolire (ordine BE voce 05)');
      expect(sorgente, contains('VieDellaCondivisione'));
    });

    test('con Riduci Movimento la celebrazione resta, ferma', () {
      final sorgente =
          File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
      // Il segno arriva a uno invece di animarsi: la scena c'e' tutta, senza
      // moto. Riduci Movimento non toglie mai contenuto.
      expect(sorgente, contains('_segno.value = 1'),
          reason: 'con Riduci Movimento la celebrazione non arriva piu\' allo '
              'stato pieno');
    });
  });
}
