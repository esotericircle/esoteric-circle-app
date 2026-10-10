import 'dart:io';

import 'package:esoteric_circle/core/maestro/cio_che_aura_ricorda.dart';
import 'package:esoteric_circle/core/maestro/memoria_del_respiro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **AURA DICE SOLO CIO' CHE RICORDA DAVVERO.** Ordine DB voci 07 e 09.
///
/// **Parole dell'ordine**: *"Una frase, mai due. E solo quando c'e' qualcosa di
/// vero da dire: se la memoria non ha niente, non si inventa niente e la
/// sessione si chiude com'e'. Una osservazione falsa distrugge in una riga la
/// fiducia che dieci vere hanno costruito."*
///
/// **REGOLA H, ed e' la meta' che conta di piu' qui.** Non basta provare che
/// la frase nasce quando c'e' qualcosa da dire: si prova soprattutto che
/// **NON nasce quando non c'e' niente**. Una funzione che dice sempre qualcosa
/// passerebbe a pieni voti la prova della presenza, e sarebbe quella che
/// distrugge la fiducia.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MemoriaDelRespiro conSessioni(List<SessioneDiRespiro> quali,
      {DateTime? adesso}) {
    final m = MemoriaDelRespiro(
        orologio: () => adesso ?? DateTime(2026, 9, 9, 22));
    for (final s in quali.reversed) {
      m.segna(s);
    }
    return m;
  }

  SessioneDiRespiro sessione(DateTime quando, int centro,
          {int secondi = 300, bool compiuta = true}) =>
      SessioneDiRespiro(
        quando: quando,
        centro: centro,
        durata: Duration(seconds: secondi),
        compiuta: compiuta,
        guidato: false,
      );

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('ALLA PRIMA SESSIONE IN ASSOLUTO NON DICE NIENTE', () {
    // **Il caso piu' importante.** Chi apre la Meditazione per la prima volta
    // non ha nessun passato: qualunque cosa Aura dicesse sarebbe inventata.
    final m = conSessioni([sessione(DateTime(2026, 9, 9, 22), 2)]);
    final frase = CioCheAuraRicorda.unaCosaSola(m, centroDiOggi: 2);
    // ignore: avoid_print
    print('ORDINE DB VOCE 09: alla prima sessione Aura dice '
        '${frase ?? "NIENTE"}');
    expect(frase, isNull,
        reason: 'alla prima sessione in assoluto Aura dice qualcosa: non puo '
            'ricordare niente, quindi quella frase e inventata, ed e la riga '
            'che distrugge la fiducia');
  });

  test('CON DUE SERE DI FILA NON PARLA ANCORA DI STRISCIA', () {
    // Due sere di fila capitano per caso: chiamarla striscia sarebbe dare un
    // significato a un caso.
    final m = conSessioni([
      sessione(DateTime(2026, 9, 9, 22), 2),
      sessione(DateTime(2026, 9, 8, 22), 2),
    ]);
    final frase = CioCheAuraRicorda.unaCosaSola(m, centroDiOggi: 2);
    // ignore: avoid_print
    print('ORDINE DB VOCE 09: con due sere di fila Aura dice '
        '${frase ?? "NIENTE"}');
    expect(frase == null || !frase.contains('2'), isTrue,
        reason: 'con due sere di fila Aura parla gia di striscia: due sere '
            'capitano per caso');
  });

  test('CON TRE SERE DI FILA LO DICE', () {
    final m = conSessioni([
      sessione(DateTime(2026, 9, 9, 22), 2),
      sessione(DateTime(2026, 9, 8, 22), 2),
      sessione(DateTime(2026, 9, 7, 22), 2),
    ]);
    final frase = CioCheAuraRicorda.unaCosaSola(m, centroDiOggi: 2);
    // ignore: avoid_print
    print('ORDINE DB VOCE 09: con tre sere di fila Aura dice '
        '${frase ?? "NIENTE"}');
    expect(frase, isNotNull,
        reason: 'tre sere di fila sono una cosa vera e Aura non la dice: '
            'l app aveva qualcosa di cui accorgersi e non se n e accorta');
    expect(frase, contains('3'),
        reason: 'la frase non porta il numero delle sere: senza, e una frase '
            'che poteva scrivere chiunque senza guardare niente');
  });

  test('LA PRIMA VOLTA SU UN CENTRO VINCE SULLA STRISCIA', () {
    // **La piu' rara vince.** In una vita di pratica la prima volta su un
    // centro capita sette volte; la terza sera di fila capita spesso. Dire la
    // cosa comune quando ce n era una rara e sprecare l unico momento in cui
    // l app poteva stupire.
    final m = conSessioni([
      sessione(DateTime(2026, 9, 9, 22), 5),
      sessione(DateTime(2026, 9, 8, 22), 2),
      sessione(DateTime(2026, 9, 7, 22), 2),
      sessione(DateTime(2026, 9, 6, 22), 2),
    ]);
    final frase = CioCheAuraRicorda.unaCosaSola(m, centroDiOggi: 5);
    // ignore: avoid_print
    print('ORDINE DB VOCE 09: primo giorno sul terzo occhio con quattro sere '
        'di fila, Aura dice "$frase"');
    expect(frase, isNotNull);
    expect(frase!.toLowerCase(), contains('prima volta'),
        reason: 'con una prima volta su un centro e una striscia insieme, '
            'Aura sceglie la striscia: butta via l osservazione piu rara');
  });

  test('IL RITORNO DOPO UNA LUNGA ASSENZA', () {
    final m = conSessioni([
      sessione(DateTime(2026, 9, 9, 22), 2),
      sessione(DateTime(2026, 8, 29, 22), 2),
    ]);
    final frase = CioCheAuraRicorda.unaCosaSola(m, centroDiOggi: 2);
    // ignore: avoid_print
    print('ORDINE DB VOCE 09: dopo undici giorni Aura dice "$frase"');
    expect(frase, isNotNull,
        reason: 'chi torna dopo undici giorni sta ricominciando, e l app non '
            'se ne accorge');
    expect(frase, contains('11'),
        reason: 'la frase non dice quanti giorni: senza il numero e una frase '
            'generica');
  });

  test('REGOLA H: UNA FRASE, MAI DUE', () {
    // Due osservazioni di fila diventano un rapporto sulla persona, e il
    // vincolo della voce DB.08 dice che nessun Maestro deve dichiarare di
    // osservare.
    final m = conSessioni([
      sessione(DateTime(2026, 9, 9, 22), 5),
      sessione(DateTime(2026, 9, 8, 22), 2),
      sessione(DateTime(2026, 9, 7, 22), 2),
      sessione(DateTime(2026, 9, 6, 22), 2),
    ]);
    final frase = CioCheAuraRicorda.unaCosaSola(m, centroDiOggi: 5)!;
    final periodi =
        frase.split(RegExp(r'[.!?]')).where((p) => p.trim().isNotEmpty).length;
    // ignore: avoid_print
    print('ORDINE DB VOCE 09: la frase ha $periodi periodi');
    expect(periodi, lessThanOrEqualTo(1),
        reason: 'la frase di Aura e fatta di $periodi periodi: e un rapporto '
            'sulla persona, e il vincolo dice che il Maestro deve sapere '
            'senza dichiarare di sapere');
  });

  test('REGOLA H: e nessun Maestro dichiara di osservare', () {
    // **Il vincolo della voce DB.08**, provato sulle frasi vere: *"nessun
    // Maestro deve mai dire alla persona che la sta osservando. Deve sapere,
    // non deve dichiarare di sapere."*
    final sorgente =
        File('lib/core/maestro/cio_che_aura_ricorda.dart').readAsStringSync();
    final codice = senzaCommenti(sorgente);
    for (final vietata in const [
      'ti osservo', 'ti sto osservando', 'ho notato che', 'sto monitorando',
      'i tuoi dati', 'ho registrato', 'sto tenendo traccia',
    ]) {
      expect(codice.toLowerCase().contains(vietata), isFalse,
          reason: 'una frase di Aura dichiara di osservare con "$vietata": '
              'deve sapere, non deve dirlo');
    }
  });

  test('LA FRASE E MONTATA A SCHERMO, non solo calcolata', () {
    // Questo progetto ha gia pagato la famiglia della figura calcolata e mai
    // disegnata: la voce CZ.09 e ferma esattamente per quello.
    final schermata = File(
            'lib/features/maestri/aura/meditation/meditation_screen.dart')
        .readAsStringSync();
    final codice = senzaCommenti(schermata);
    expect(codice.contains('meditazione_aura_ricorda'), isTrue,
        reason: 'la frase di Aura si calcola e non la legge nessuno');
    expect(codice.contains('CioCheAuraRicorda.unaCosaSola'), isTrue,
        reason: 'la schermata non chiede mai la frase alla memoria');
  });

  test('LA MEMORIA CONOSCE L ANDAMENTO, non solo le sessioni', () {
    // Ordine DB voce 07: *"ricorda anche l andamento, che e cio che nessuna
    // singola sessione dice"*.
    final m = conSessioni([
      for (var g = 0; g < 8; g++)
        sessione(DateTime(2026, 9, 9 - g, 22), g % 3, secondi: 300 + g * 20),
    ]);
    cardinaleMinimo(m.sessioni.length, 8,
        cosa: 'sessioni nella memoria di prova',
        perche: 'Con poche sessioni l andamento non esiste e questa prova '
            'direbbe che la memoria funziona senza averla riempita.');
    // ignore: avoid_print
    print('ORDINE DB VOCE 07: giorni di pratica ${m.giorniDiPratica}, di fila '
        '${m.giorniDiFila}, centro piu frequentato ${m.centroPiuFrequentato}, '
        'mai toccati ${m.centriMaiToccati.length}, cambio durata '
        '${m.quantoCambiaLaDurata?.toStringAsFixed(3) ?? "nullo"}');
    expect(m.giorniDiPratica, 8);
    expect(m.giorniDiFila, 8);
    expect(m.centroPiuFrequentato, isNotNull);
    expect(m.centriMaiToccati.length, 4,
        reason: 'con tre centri toccati su sette ne devono restare quattro');
    expect(m.quantoCambiaLaDurata, isNotNull,
        reason: 'con otto sessioni l andamento della durata si puo calcolare');
  });

  test('REGOLA H: con meno di sei sessioni l andamento NON si dichiara', () {
    final m = conSessioni([
      for (var g = 0; g < 4; g++) sessione(DateTime(2026, 9, 9 - g, 22), 1),
    ]);
    expect(m.quantoCambiaLaDurata, isNull,
        reason: 'con quattro sessioni la memoria dichiara un andamento: e '
            'rumore, e dirlo sarebbe l osservazione falsa che la voce vieta');
    expect(m.oraPiuFrequente, isNotNull,
        reason: 'con quattro sessioni tutte alle 22 l ora piu frequente '
            'esiste davvero');
  });

  test('IL RIASSUNTO PER I MAESTRI e breve e non e il dato grezzo', () {
    final m = conSessioni([
      for (var g = 0; g < 5; g++) sessione(DateTime(2026, 9, 9 - g, 22), g % 2),
    ]);
    final riassunto = m.riassuntoPerIMaestri;
    // ignore: avoid_print
    print('ORDINE DB VOCE 08: il riassunto dice "$riassunto"');
    expect(riassunto, isNotEmpty,
        reason: 'con cinque sessioni il riassunto e vuoto: i Maestri non '
            'sapranno mai che questa persona respira');
    expect(riassunto.length, lessThan(300),
        reason: 'il riassunto e lungo ${riassunto.length} caratteri: l ordine '
            'chiede il riassunto e non il dato grezzo di ogni sessione');
    // **E su una memoria vuota non entra niente nel contesto.**
    final vuota = MemoriaDelRespiro(orologio: () => DateTime(2026, 9, 9));
    expect(vuota.riassuntoPerIMaestri, isEmpty,
        reason: 'chi non ha mai meditato manda ai Maestri un riassunto della '
            'sua pratica: e una riga che parla di una cosa che non esiste');
  });
}
