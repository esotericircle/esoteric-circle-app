import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/rito_alba_corpus.dart';
import 'package:esoteric_circle/core/rituals/risposta_del_dono.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL MOOD DEL CERCHIO.** Ordine CQ voci 6.23, 6.24 e 6.25, 4 settembre
/// 2026.
///
/// **La legge, come il fondatore l'ha dettata.** *"un titolo accattivante come
/// prima risposta che riassuma tutta la risposta. sotto la risposta diretta
/// che risponde alla domanda dell'utente: cosa significa per me? e adesso cosa
/// devo fare. piu' sotto il tasto approfondisci per quegli utenti che cercano
/// approfondimento e professionalita'."*
///
/// E il perche', dal 2 settembre: *"l'utente non cerca informazioni, cerca
/// risposte e vuole essere guidato. non gliene frega niente di transiti,
/// pianeti, ecc. non dico di non scrivere da dove arrivano le risposte, ma non
/// all'inizio."*
///
/// **Questa guardia sorveglia la LEGGE, non una schermata.** Il mood vale per
/// i cinque Doni, per i Tarocchi, per le Rune e per l'Oroscopo: una guardia
/// per schermata sarebbe nove copie della stessa regola, che divergono alla
/// prima modifica. Qui stanno le tre cose che la legge dice, misurate dove
/// vivono.
void main() {
  test('il titolo e una risposta corta, non una descrizione del cielo', () {
    // **SI MISURANO I TITOLI VERI**, composti dal corpus per tre Maestri e
    // tre dati del cielo, non un esempio scelto a mano.
    // **SI GIRANO TUTTE E NOVE LE COMBINAZIONI, e ci e' voluta la prova
    // del rosso.** La prima stesura passava per quattro date sperando che
    // producessero i tre dati del cielo: ne producevano due, e **un terzo
    // del corpus non veniva mai guardato**. Due innesti su un titolo che
    // quelle date non toccavano sono restati verdi.
    //
    // Qui si compone la risposta per ogni Maestro e ogni dato, che e' come
    // il corpus e' fatto: nove combinazioni, nessuna esclusa.
    final lunghezze = <int>[];
    final lunghi = <String>[];
    for (final maestro in Maestro.values) {
      for (final fatto in DatoDelCielo.values) {
        final risposta = RispostaDelDono.perIlRisveglio(
          maestro: maestro,
          fatto: fatto,
          parola: 'custodire',
          valoreDelFatto: 'Vergine',
        );
        final titolo = risposta.titolo;
        lunghezze.add(titolo.length);
        // **SESSANTA CARATTERI E' IL CONFINE, e si dichiara.** E' la misura
        // sotto la quale un titolo si legge in un colpo d'occhio su un
        // telefono, e sopra la quale va a capo tre volte diventando un
        // paragrafo con un altro nome.
        if (titolo.length > 60) lunghi.add('$titolo (${titolo.length})');
      }
    }
    final media = lunghezze.reduce((a, b) => a + b) / lunghezze.length;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.25: titoli misurati ${lunghezze.length}, media '
        '${media.round()} caratteri, il piu lungo '
        '${lunghezze.reduce((a, b) => a > b ? a : b)}');
    cardinaleMinimo(lunghezze.length, 9,
        cosa: 'titoli veri composti dal corpus',
        perche: 'Con pochi titoli la prova direbbe che sono tutti corti per '
            'non averne guardati abbastanza.');
    expect(lunghi, isEmpty,
        reason: 'questi titoli sono troppo lunghi per essere letti in un '
            'colpo d occhio, e un titolo che non si legge in un colpo d '
            'occhio non e una risposta:'
            '${String.fromCharCode(10)}${lunghi.join(String.fromCharCode(10))}');
  });

  test('e nessun titolo promette un esito', () {
    // **LA LEGGE DI CASA NON CAMBIA COL MOOD.** Un titolo diretto e' piu'
    // esposto alla promessa proprio perche' e' diretto: qui si tiene fermo
    // che dica cosa il giorno chiede, mai cosa succedera'.
    final promesse = <String>[];
    var guardati = 0;
    for (final maestro in Maestro.values) {
      for (final fatto in DatoDelCielo.values) {
        final titolo = RispostaDelDono.perIlRisveglio(
          maestro: maestro,
          fatto: fatto,
          parola: 'custodire',
          valoreDelFatto: 'Vergine',
        ).titolo;
        guardati++;
        for (final vietata in const [
          'otterrai', 'avrai', 'sarai', 'ti portera', 'vedrai', 'accadra',
          'succedera', 'riceverai',
        ]) {
          if (titolo.toLowerCase().contains(vietata)) {
            promesse.add('$titolo -> "$vietata"');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.25: titoli guardati $guardati, che promettono un '
        'esito ${promesse.length}');
    cardinaleMinimo(guardati, 9,
        cosa: 'titoli guardati in cerca di promesse',
        perche: 'Con zero titoli la prova sarebbe verde per non aver letto '
            'niente.');
    expect(promesse, isEmpty,
        reason: 'questi titoli promettono un esito: ${promesse.join(" | ")}');
  });

  test('la porta dell approfondimento e una sola in tutta l app', () {
    // **NOVE ARTI, UNA PORTA.** Scritta nove volte diventerebbe nove porte
    // che divergono al primo cambiamento, ed e' la famiglia di difetti che
    // questo progetto insegue da sempre.
    final porta = File('lib/design_system/components/da_dove_nasce.dart');
    expect(porta.existsSync(), isTrue,
        reason: 'il componente della porta non esiste piu');

    // Chi si apre una porta per conto suo, invece di passare da quella.
    final proprie = <String>[];
    var guardati = 0;
    for (final file in sorgentiDiLib()) {
      final percorso = file.path.replaceAll(RegExp(r'[\\/]'), '/');
      if (percorso.endsWith('da_dove_nasce.dart')) continue;
      guardati++;
      final testo = file.readAsStringSync();
      // Un testo che invita ad approfondire senza passare dal componente.
      if (RegExp(r"'(Approfondisci|Mostra di piu|Scopri di piu)")
          .hasMatch(testo)) {
        proprie.add(percorso.split('lib/').last);
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.24: sorgenti guardati $guardati, con una porta '
        'propria ${proprie.length}');
    cardinaleMinimo(guardati, 300,
        cosa: 'sorgenti di lib riletti in cerca di porte proprie',
        perche: 'Su un elenco vuoto la prova sarebbe verde per non aver '
            'aperto niente.');
    expect(proprie, isEmpty,
        reason: 'questi punti si aprono una porta propria invece di passare '
            'da DaDoveNasce: ${proprie.join(", ")}');
  });

  test('e la prosa che si legge ha una misura sola, venti punti', () {
    // **VENTI, E UNA SOLA.** Il fondatore ha chiesto testi piu' grandi tre
    // volte; per un giro ho provato con un ruolo nuovo accanto a questo, ed
    // era un secondo conto della stessa cosa.
    final base = TypographyTokens.lettura();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.23: la prosa che si legge vale '
        '${base.fontSize} punti, interlinea ${base.height}');
    expect(base.fontSize, 20,
        reason: 'la prosa non vale piu venti punti');
    // E non esiste un secondo ruolo che le somigli.
    final scala = File('lib/design_system/tokens/typography_tokens.dart')
        .readAsStringSync();
    expect(scala.contains('letturaAmpia'), isFalse,
        reason: 'e tornato un secondo ruolo per la prosa: due misure della '
            'stessa cosa sono due conti che divergono');
  });
}
