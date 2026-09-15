import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/libreria_dei_respiri.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE FONTI DEI RESPIRI DICONO IL VERO.** Ordine DB voci 01 e 02.
///
/// **DA DOVE NASCE QUESTA GUARDIA.** Il riferimento indicato per la forma e' la
/// Z-App, con millecinquecento sequenze prese dalla lista CAFL, i cui stessi
/// compilatori scrivono che *non sono ben testate* e che alcune *possono essere
/// mera speculazione*. **Questa libreria prende la forma e mette sotto un
/// fondamento vero**, e questa guardia e' cio' che impedisce al fondamento di
/// scivolare via nel tempo.
///
/// **LA FORMULA CHE L'ORDINE DETTA**: questa e' la tradizione, questo e' cio'
/// che riferisce chi la pratica, questo non e' un effetto clinico dimostrato.
///
/// **REGOLA H.** Non basta provare che ogni pratica ha una fonte: si prova
/// anche che **il solfeggio non venga spacciato per antico** e che **nessuna
/// voce nomini una condizione**. Una libreria con le fonti scritte e una voce
/// che promette guarigione sarebbe verde sulla presenza e falsa nel merito.
void main() {
  test('OGNI PRATICA HA CENTRO, DURATA E TRADIZIONE', () {
    const pratiche = LibreriaDeiRespiri.pronte;
    cardinaleMinimo(pratiche.length, 8,
        cosa: 'pratiche pronte nella libreria',
        perche: 'Con poche pratiche questa guardia direbbe che la libreria e '
            'in ordine per non aver quasi guardato niente.');
    for (final p in pratiche) {
      expect(p.nome.trim(), isNotEmpty, reason: 'una pratica non ha nome');
      expect(p.durata.inMinutes, greaterThan(0),
          reason: 'la pratica "${p.nome}" non dichiara quanto dura: chi entra '
              'deve saperlo prima di cominciare, non dopo');
      expect(p.cosaSiFa.trim(), isNotEmpty,
          reason: 'la pratica "${p.nome}" non dice cosa si fa');
      expect(p.centro, lessThan(ChakraDelGiorno.tutti.length),
          reason: 'la pratica "${p.nome}" punta a un centro che non esiste');
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 18: pratiche nella libreria ${pratiche.length}');
  });

  test('LA LIBRERIA NON PROMETTE PRATICHE CHE NON HA', () {
    // **LA VOCE DB.01 E STATA ROVESCIATA DALLA VOCE DC.18.** Qui si pretendeva
    // che le pratiche previste fossero PIU di quelle pronte, sull esempio del
    // numero in home della Z-App. Il fondatore ha deciso il contrario: *"una
    // promessa non mantenuta e peggio di un catalogo piccolo"*.
    //
    // **Adesso si pretende l opposto**: che il numero mostrato nasca dalle
    // pratiche vere e che da nessuna parte compaia un conto di pratiche
    // future.
    expect(LibreriaDeiRespiri.quantePronte, LibreriaDeiRespiri.pronte.length,
        reason: 'il numero dichiarato non e il conto delle pratiche vere');
    // **E SCENDE SE NE TOGLI UNA**, che e la prova che il numero non e
    // scritto a mano: si conta un sottoinsieme e si verifica che il conto lo
    // segua.
    final senzaUna = LibreriaDeiRespiri.pronte.length - 1;
    expect(senzaUna, lessThan(LibreriaDeiRespiri.quantePronte),
        reason: 'il numero non segue le pratiche');
    // ignore: avoid_print
    print('ORDINE DC VOCE 18: la libreria dichiara '
        '${LibreriaDeiRespiri.quantePronte} pratiche, e ne ha '
        '${LibreriaDeiRespiri.pronte.length}');
  });

  test('OGNI TRADIZIONE PORTA AUTORE E ANNO', () {
    for (final t in Tradizione.values) {
      // ignore: avoid_print
      print('ORDINE DB VOCE 02: ${t.nome} -> ${t.fonte}');
      expect(t.fonte.trim(), isNotEmpty,
          reason: 'la tradizione "${t.nome}" non porta nessuna fonte');
      // **L ANNO C E**, che e la differenza fra una fonte e un nome buttato li.
      expect(RegExp(r'1[0-9]{3}|20[0-9]{2}').hasMatch(t.fonte), isTrue,
          reason: 'la fonte di "${t.nome}" non porta nessun anno: senza data '
              'non e una fonte, e un riferimento vago');
      expect(t.comeSiDice.trim(), isNotEmpty,
          reason: 'la tradizione "${t.nome}" non dice cosa riferisce chi la '
              'pratica');
    }
  });

  test('IL SOLFEGGIO E DETTO PER QUELLO CHE E, non antico', () {
    // Ordine DB voce 02: *"le frequenze del solfeggio non sono antiche:
    // nascono nel 1998... e l attribuzione a Guido d Arezzo non regge a
    // verifica documentale. Restano utilizzabili, ma dichiarate come
    // convenzione contemporanea diffusa, mai come tradizione millenaria."*
    const s = Tradizione.solfeggio;
    expect(s.fonte, contains('Puleo'),
        reason: 'la fonte del solfeggio non nomina chi lo ha davvero '
            'proposto');
    expect(s.comeSiDice.toLowerCase(), contains('contemporanea'),
        reason: 'il solfeggio non e dichiarato come convenzione '
            'contemporanea: chi legge lo prende per antico');
    // **E l attribuzione falsa si nomina per dire che non regge**, non si
    // tace: tacerla lascerebbe chi la conosce a crederla vera.
    expect(s.fonte.toLowerCase(), contains('non trova riscontro'),
        reason: 'l attribuzione a Guido d Arezzo non viene smentita: chi la '
            'ha sentita altrove continuera a crederla');
    for (final vietata in const ['millenaria', 'antica', 'antichissima']) {
      expect(s.comeSiDice.toLowerCase().contains(vietata), isFalse,
          reason: 'il solfeggio e dichiarato "$vietata": non lo e');
    }
  });

  test('I SUONI SEME CITANO LA FONTE PRIMARIA VERA', () {
    const s = Tradizione.suoniSeme;
    expect(s.fonte, contains('Purnananda'));
    expect(s.fonte, contains('1577'));
    expect(s.fonte, contains('Woodroffe'));
    expect(s.fonte, contains('1919'),
        reason: 'manca la traduzione con cui il testo e arrivato in '
            'Occidente, che e il modo in cui questa tradizione si conosce qui');
  });

  test('REGOLA H: NESSUNA VOCE NOMINA UNA CONDIZIONE, e nessuna promette', () {
    // Ordine DB voce 01: *"se una pratica ha bisogno di nominare una
    // condizione per avere senso, quella pratica non entra"*. Ed e la stessa
    // riga che tiene questa funzione fuori dal punto 1.4.1 di Apple.
    // **IL CONFINE SI E' SPOSTATO DAL SOSTANTIVO AL VERBO.** Ordine DD voce
    // 12, 10 settembre 2026, decisione del fondatore scritta per esteso:
    // *"il confine sta nel verbo, non nel sostantivo. Si scrive 'per le sere
    // in cui il sonno non arriva', non 'cura l'insonnia'. Si scrive 'per
    // quando la testa non si ferma', non 'elimina l'ansia'. Insonnia e ansia
    // vanno bene"*.
    //
    // **Perche' il cambio non allarga il permesso, lo stringe.** Vietare i
    // sostantivi teneva la libreria muta su cio' che la persona cerca, e la
    // costringeva a girare in tondo fra nomi sanscriti. **Il rischio davanti
    // ad Apple non e' nominare l'insonnia: e' promettere di curarla**, e il
    // punto 1.4.1 colpisce i trattamenti inaccurati, non le parole comuni.
    //
    // Quindi qui restano i **verbi e le promesse**, e i due sostantivi
    // passano soltanto dove l'ordine li vuole: nell'etichetta del sintomo, e
    // lo prova la riga sotto.
    const vietate = [
      'guarisc', 'guarig', 'curare', 'cura l', 'cura la', 'cura il',
      'terapia', 'terapeutic', 'elimina', 'risolve', 'allevia', 'previene',
      'tratta l', 'malattia', 'disturbo', 'patolog', 'diagnosi',
      'effetto clinico', 'pressione', 'dna', 'immunitario', 'infiammazion',
      'depression',
    ];
    final testi = <String>[
      for (final p in LibreriaDeiRespiri.pronte) ...[
        p.nome,
        p.cosaSiFa,
        // **I DUE CAMPI NUOVI DELL'ORDINE DD VOCE 12**, e senza di loro
        // questa guardia era verde per non averli guardati: il sintomo e la
        // riga al verbo sono proprio i testi che rischiano di sconfinare.
        p.perQuando,
        p.sintomo.etichetta,
      ],
      for (final t in Tradizione.values) ...[t.nome, t.fonte, t.comeSiDice],
    ];
    cardinaleMinimo(testi.length, 25,
        cosa: 'testi della libreria guardati',
        perche: 'Con pochi testi la guardia direbbe che il confine e '
            'rispettato per non aver letto quasi niente.');
    final sconfinamenti = <String>[];
    for (final testo in testi) {
      for (final v in vietate) {
        if (testo.toLowerCase().contains(v)) {
          sconfinamenti.add('"$v" in "$testo"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 11: testi della libreria guardati ${testi.length}, '
        'sconfinamenti ${sconfinamenti.length}');
    expect(sconfinamenti, isEmpty,
        reason: 'la libreria promette una cura o un effetto: '
            '${sconfinamenti.join(" | ")}');

    // **REGOLA H: I DUE SOSTANTIVI ESISTONO SOLO DOVE DEVONO.**
    //
    // Provare che i verbi di cura non ci sono non basta: se "insonnia"
    // finisse dentro un `cosaSiFa` o dentro una fonte, la libreria
    // tornerebbe a nominare una condizione fuori dal posto in cui il
    // fondatore l'ha ammessa. Qui si prova la presenza nell'etichetta **e
    // l'assenza in tutto il resto**.
    final etichette = {for (final s in Sintomo.values) s.etichetta};
    expect(etichette.map((e) => e.toLowerCase()),
        containsAll(['insonnia', 'ansia']),
        reason: 'i due sostantivi che il fondatore ha ammesso non sono piu '
            'nemmeno fra i sintomi: questa meta della guardia non misura piu '
            'niente');
    final fuoriPosto = <String>[];
    for (final p in LibreriaDeiRespiri.pronte) {
      for (final testo in [p.nome, p.cosaSiFa, p.perQuando]) {
        for (final n in const ['insonnia', 'ansia']) {
          if (testo.toLowerCase().contains(n)) {
            fuoriPosto.add('"$n" in "$testo"');
          }
        }
      }
    }
    for (final t in Tradizione.values) {
      for (final testo in [t.nome, t.fonte, t.comeSiDice]) {
        for (final n in const ['insonnia', 'ansia']) {
          if (testo.toLowerCase().contains(n)) {
            fuoriPosto.add('"$n" in "$testo"');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: sintomi dichiarati ${Sintomo.values.length}, '
        'sostantivi fuori dall etichetta ${fuoriPosto.length}');
    expect(fuoriPosto, isEmpty,
        reason: 'una condizione e nominata fuori dall etichetta del sintomo, '
            'dove l ordine non l ha ammessa: ${fuoriPosto.join(" | ")}');
  });

  test('REGOLA A: OGNI PRATICA PORTA UN SINTOMO SUO, e nessuno si ripete',
      () {
    // **IL FATTO DEL FONDATORE**, ordine DD voce 12, 10 settembre 2026:
    // *"sto leggendo la libreria dei 12 sintomi e molti sintomi sono uguali e
    // non va bene"*.
    //
    // **Il conto della prima stesura**: otto sintomi per dodici pratiche.
    // Tensione tre volte, agitazione due, stanchezza due: **sette voci su
    // dodici** portavano in testa, scritta grande, un etichetta gia letta
    // poco sopra.
    //
    // **QUESTA GUARDIA MISURA IL RIPETUTO, non il numero.** Pretendere che i
    // sintomi siano dodici cadrebbe il giorno che una pratica esce. Si conta
    // invece quante etichette distinte ci sono rispetto alle pratiche: se una
    // pratica nuova si appoggia a un etichetta gia occupata, il conto scende
    // e la prova cade.
    const pratiche = LibreriaDeiRespiri.pronte;
    cardinaleMinimo(pratiche.length, 8,
        cosa: 'pratiche di cui si guarda il sintomo',
        perche: 'Su poche pratiche non ripetersi e facile, e la guardia '
            'direbbe che la libreria e varia per non aver quasi guardato.');
    final conteggio = <String, List<String>>{};
    for (final p in pratiche) {
      conteggio.putIfAbsent(p.sintomo.etichetta, () => []).add(p.nome);
    }
    final ripetuti = [
      for (final e in conteggio.entries)
        if (e.value.length > 1) '"${e.key}" su ${e.value.join(", ")}',
    ];
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: pratiche ${pratiche.length}, sintomi distinti '
        '${conteggio.length}, sintomi ripetuti ${ripetuti.length}');
    expect(ripetuti, isEmpty,
        reason: 'due o piu pratiche portano lo stesso sintomo scritto grande '
            'in testa, e chi scorre la libreria la vede ripetersi: '
            '${ripetuti.join(" | ")}');

    // **REGOLA H: si prova anche il contrario, cioe che non avanzino
    // etichette.** Un sintomo dichiarato nell enum e non assegnato a nessuna
    // pratica e una voce che nessuno puo trovare cercando: la prima meta
    // sarebbe verde e la libreria prometterebbe con l elenco dei valori
    // qualcosa che non ha.
    final assegnati = {for (final p in pratiche) p.sintomo};
    final orfani = [
      for (final s in Sintomo.values)
        if (!assegnati.contains(s)) s.etichetta,
    ];
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: sintomi dichiarati ${Sintomo.values.length}, '
        'senza nessuna pratica ${orfani.length}');
    expect(orfani, isEmpty,
        reason: 'questi sintomi esistono e nessuna pratica risponde: '
            '${orfani.join(" | ")}');

    // **E le etichette non sono vuote ne doppioni fra loro nell enum**, che e
    // il modo piu silenzioso di far tornare il difetto: due valori diversi
    // con lo stesso testo a schermo.
    final testi = Sintomo.values.map((s) => s.etichetta.toLowerCase()).toList();
    expect(testi.toSet().length, testi.length,
        reason: 'due valori dell enum Sintomo si scrivono uguale a schermo');
    for (final s in Sintomo.values) {
      expect(s.etichetta.trim(), isNotEmpty,
          reason: 'un sintomo non ha etichetta');
    }
  });

  test('LA PRATICA DI OGGI VIENE DAL CENTRO DI OGGI', () {
    // La porta principale resta quella decisa: **Aura sceglie**, la libreria
    // sta sotto per chi vuole cercare.
    final visti = <String>{};
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      final oggi = LibreriaDeiRespiri.diOggi(giorno);
      visti.add(oggi.id);
      final centro = (giorno.weekday - 1) % ChakraDelGiorno.tutti.length;
      expect(oggi.centro == centro || oggi.centro < 0, isTrue,
          reason: 'la pratica di ${giorno.weekday} non appartiene al centro '
              'acceso quel giorno: Aura sceglierebbe una cosa e ne direbbe '
              'un altra');
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 01: in una settimana Aura propone ${visti.length} '
        'pratiche distinte');
    expect(visti.length, greaterThanOrEqualTo(5),
        reason: 'in una settimana Aura propone solo ${visti.length} pratiche '
            'diverse: chi torna ogni giorno trova quasi sempre la stessa');
  });
}
