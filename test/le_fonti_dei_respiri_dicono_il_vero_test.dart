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
    print('ORDINE DB VOCE 01: pratiche pronte ${pratiche.length}, previste '
        '${LibreriaDeiRespiri.previste}');
  });

  test('LA LIBRERIA DICHIARA LA PROPRIA AMPIEZZA, e non mente', () {
    // Ordine DB voce 01: *"la libreria dichiara la propria ampiezza... chi
    // entra deve vedere che qui dentro c e piu di quanto finira"*.
    expect(LibreriaDeiRespiri.previste,
        greaterThan(LibreriaDeiRespiri.pronte.length),
        reason: 'le pratiche previste non sono piu di quelle pronte: o la '
            'libreria e finita, e allora non ha nulla da promettere, o il '
            'numero e sbagliato');
    // **E il numero promesso non e un vanto sproporzionato.** Dichiarare
    // millecinquecento pratiche avendone dieci sarebbe la stessa cosa che
    // rende inaffidabile l app di riferimento.
    expect(LibreriaDeiRespiri.previste,
        lessThan(LibreriaDeiRespiri.pronte.length * 8),
        reason: 'la libreria promette ${LibreriaDeiRespiri.previste} pratiche '
            'avendone ${LibreriaDeiRespiri.pronte.length}: e un numero da '
            'vetrina, e chi arriva in fondo si accorge che non esistono');
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
    const vietate = [
      'guarisc', 'cura', 'terapia', 'malattia', 'sintomo', 'disturbo',
      'dolore', 'ansia', 'insonnia', 'pressione', 'dna', 'immunitario',
      'infiammazion', 'depression', 'diagnosi',
    ];
    final testi = <String>[
      for (final p in LibreriaDeiRespiri.pronte) ...[p.nome, p.cosaSiFa],
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
        reason: 'la libreria nomina condizioni o promette effetti: '
            '${sconfinamenti.join(" | ")}');
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
