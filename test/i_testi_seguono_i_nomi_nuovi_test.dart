import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gli_accenti_del_corpus.dart';

import 'sorgenti_di_lib.dart';

/// I TESTI SEGUONO I NOMI NUOVI. Ordine AR voce 08.
///
/// **Il difetto che questa guardia impedisce.** Un nome di traguardo copiato
/// in una schermata, in una notifica o in una frase di condivisione diventa
/// una seconda verita': il giorno che il corpus cambia, la persona legge un
/// nome nella festa e un altro nel Journal, e nessuna prova se ne accorge.
///
/// **Come si guarda.** Si prendono i nomi della revisione B che nella C non
/// esistono piu' e si cerca se qualcuno li nomina ancora. Il confronto e' sui
/// nomi INTERI e non sulle sottostringhe: "Cinque mattine" e' dentro "Cinque
/// mattine di seguito", che e' un nome vivo, e cercare pezzi avrebbe accusato
/// il codice giusto.
void main() {
  Set<String> nomiDi(String file) {
    final d = jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;
    return {
      for (final s in d['sentieri'] as List)
        for (final v in (s as Map)['voci'] as List)
          conGliAccenti((v as Map)['nome'] as String),
    };
  }

  test('nessun nome della revisione B sopravvive nel codice', () {
    // **IL CONFRONTO E' COL CORPUS VIVO, non con quello di allora.** Ordine AU
    // voce 03: la revisione D2 ha tolto "di seguito" da undici nomi, perche'
    // promettevano giorni di fila su condizioni a finestra, cioe' mentivano.
    // Tre di quei nomi tornano ad essere quelli che la revisione B aveva,
    // "Cinque mattine", "Trenta mattine", "Sessanta mattine": non e' un nome
    // vecchio sopravvissuto, e' il nome che il fondatore ha chiesto. Leggendo
    // la revisione C questa prova accusava il corpus vivo di essere vecchio.
    final nuovi = nomiDi('docs/corpus/Traguardi_165_Revisione_E.json');
    final vecchi = nomiDi('docs/corpus/Traguardi_165_Revisione_B.json')
        .where((n) => !nuovi.contains(n))
        .toList();
    expect(vecchi, isNotEmpty,
        reason: 'la revisione B non ha piu nomi propri: la prova gira a vuoto');
    final colpe = <String>[];
    for (final f in sorgentiDiCartelle(
      ['lib', 'test'],
      minimo: 900,
    )) {
      // **QUESTA PROVA NOMINA I NOMI VECCHI PER MESTIERE**: accusare se
      // stessa la renderebbe rossa per sempre.
      if (f.path.endsWith('i_testi_seguono_i_nomi_nuovi_test.dart')) continue;
      // **LA LINGUA DEGLI EVENTI NON NOMINA TRAGUARDI**, ordine BS voce 01.
      // Li' dentro "Mercurio torna diretto" e' come si dice un fatto del
      // cielo, e il cielo non cambia nome quando cambia il corpus: la
      // revisione E non ha piu' un traguardo che si chiama cosi', e senza
      // questa riga la prova accusava una frase di astronomia di essere il
      // nome di un gradino morto.
      if (f.path.endsWith('lingua_degli_eventi.dart')) continue;
      final testo = f.readAsStringSync();
      for (final nome in vecchi) {
        // Il nome INTERO, fra apici: e' cosi' che un nome finisce in una
        // stringa di codice, e cosi' si distingue da una sottostringa di un
        // nome vivo.
        if (testo.contains("'$nome'") || testo.contains('"$nome"')) {
          colpe.add('${f.path}: "$nome"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 08: nomi vecchi ancora vivi nel codice '
        '${colpe.length} (nomi spariti dalla revisione B: ${vecchi.length})');
    expect(colpe, isEmpty,
        reason: 'questi punti nominano un traguardo che non esiste piu: '
            '${colpe.take(5).join("; ")}');
  });

  test('chi mostra un traguardo prende il nome dal dato, non da una copia', () {
    // I punti che mostrano il nome di un traguardo devono leggerlo dal
    // Traguardo, non da una stringa loro: qui si enumera chi lo fa.
    const puntiCheNominano = [
      'lib/features/sigilli/celebrazione.dart',
      'lib/features/sigilli/card_del_traguardo.dart',
    ];
    for (final punto in puntiCheNominano) {
      final testo = File(punto).readAsStringSync();
      expect(testo.contains('.nome'), isTrue,
          reason: '$punto non legge piu il nome dal traguardo: se lo scrive '
              'da se, il giorno che il corpus cambia dira un nome vecchio');
    }
  });

  test('ogni traguardo ha un nome, e nessuno e vuoto', () {
    final senzaNome =
        Sentieri.tuttiITraguardi.where((t) => t.nome.trim().isEmpty).toList();
    expect(senzaNome, isEmpty,
        reason:
            'questi traguardi non hanno nome: ${senzaNome.map((t) => t.id)}');
  });
}
