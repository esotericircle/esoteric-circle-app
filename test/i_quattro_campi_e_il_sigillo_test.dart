import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/sigilli/stato_del_sigillo.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
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
        if (quanteParole(t.cosaApre) < 3) vuoti.add('${t.id}: cosa apre');
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
        expect(t.cosaApre.trim(), isNotEmpty, reason: t.id);
      }
    });

    test('l\'obiettivo e\' ancora quello dell\'ordine O', () {
      // La correzione lo dice: gli obiettivi non si sostituiscono, sono la
      // parte che passa le guardie. La condizione tipizzata E' l'obiettivo.
      for (final t in tutti) {
        expect(t.condizione, isNotNull, reason: t.id);
      }
      // E l'aritmetica resta quella decisa: 2.010 per sentiero, 6.030 in tutto.
      for (final s in Sentiero.values) {
        final somma =
            Sentieri.di(s).fold<int>(0, (a, t) => a + t.eos);
        expect(somma, 2010, reason: 'il sentiero ${s.name} somma $somma Eos');
      }
      expect(tutti.fold<int>(0, (a, t) => a + t.eos), 6030);
    });

    test('i tre Sigilli di aggancio valgono venti Eos e sono trasversali', () {
      for (final s in Sentiero.values) {
        final primi = Sentieri.di(s).where((t) => t.posizione <= 3).toList();
        expect(primi, hasLength(3));
        for (final t in primi) {
          expect(t.eos, 20, reason: '${t.id} non vale venti Eos');
        }
      }
    });

    test('l\'Allegato A e\' nel repo, ed e\' la sorgente dei tre campi', () {
      final allegato = File('docs/ordini/ORDINE_P_ALLEGATO_A.md');
      expect(allegato.existsSync(), isTrue,
          reason: 'se al momento di eseguire l\'allegato non c\'e\', la voce si '
              'ferma dichiarando premessa mancante');
      final testo = allegato.readAsStringSync();
      // Quanti dei 165 hanno preso il testo dall'Allegato: si conta cercando
      // il "cosa apre" dentro l'allegato, invece di crederci.
      final presi = tutti
          .where((t) => testo.contains(t.cosaApre.trim()))
          .length;
      expect(presi, greaterThan(0),
          reason: 'nessuno dei 165 porta un testo dell\'Allegato A: '
              'l\'accostamento non ha funzionato');
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
      final sorgente = File('lib/features/sigilli/sentiero_screen.dart')
          .readAsStringSync();
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
      // Le due intensita' restano, e la card resta sempre offerta.
      expect(sorgente, contains('traguardo.eGrande || primoInAssoluto'),
          reason: 'le due intensita\' sono sparite: cinquanta celebrazioni '
              'lunghe diventano un ostacolo, e un mini che passa in silenzio '
              'non e\' un traguardo');
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
