import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/arcano_dell_alba/archivio_dell_alba.dart';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/filo_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I DONI DEL GIORNO, ordine P voci 16, 17 e 18.
///
/// La legge che governa la sezione: **un dono che si esaurisce quando lo apri
/// non produce ritorni. Un dono che apre qualcosa che si chiude piu' tardi,
/// si'.** Le tre voci sono tre modi di applicarla, e queste prove le misurano
/// una per una.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // **IL GRUPPO P.16 NON C'E' PIU'**, ordine DT voce 01: misurava l'Arcano del
  // Giorno e la sua vista rituale col giroscopio, che se ne sono andati col
  // dono. L'Arcano dell'Alba ha un gesto solo, il tocco su una carta coperta,
  // e le sue prove stanno in `l_arcano_dell_alba_si_gira_test.dart`.

  group('P.17 ogni rito dichiara cosa fa, perche\', e cosa resta', () {
    test('tutti i doni dichiarano le tre righe', () {
      // SI ENUMERA, non si elencano a mano i riti che ci si ricorda.
      for (final rito in DailyElement.values) {
        for (final riga in [
          (nome: 'cosa fai', testo: rito.cosaFai),
          (nome: 'perche', testo: rito.perche),
          (nome: 'cosa ti resta', testo: rito.cosaTiResta),
        ]) {
          expect(riga.testo.length, greaterThan(40),
              reason: '${rito.name} non dichiara "${riga.nome}"');
          expect(riga.testo, isNot(contains('—')),
              reason: 'trattino lungo in ${rito.name}, ${riga.nome}');
        }
        // Le tre righe dicono tre cose diverse, e nessuna ripete la
        // descrizione: tre etichette sopra lo stesso testo non sono tre righe.
        final tre = {rito.cosaFai, rito.perche, rito.cosaTiResta};
        expect(tre, hasLength(3), reason: '${rito.name} ripete se stesso');
        expect(tre, isNot(contains(rito.description)),
            reason: '${rito.name} riusa la descrizione della striscia');
      }
    });

    test('la terza riga nomina sempre qualcosa che RESTA', () {
      // E' la sola delle tre che produce ritorno, quindi e' l'unica su cui
      // vale la pena avere una misura invece di una buona intenzione.
      const segni = [
        'resta',
        'domani',
        'stasera',
        'fra poche ore',
        'porta',
        'nominer',
        'richiam',
        'condividere',
      ];
      final mute = <String>[];
      for (final rito in DailyElement.values) {
        final testo = rito.cosaTiResta.toLowerCase();
        if (!segni.any(testo.contains)) mute.add(rito.name);
      }
      expect(mute, isEmpty,
          reason: 'questi riti dicono cosa ti resta senza nominare niente che '
              'rimanga o che torni: ${mute.join(", ")}');
    });

    test('nessuna schermata di rito annuncia piu un rito', () {
      // **LA LEGGE SI E' ROVESCIATA. Ordine CQ voce 2.03**, 3 settembre 2026.
      //
      // L'ordine P voce 17 aveva chiesto che ogni rito dichiarasse cosa fai,
      // perche' e cosa ti resta, e la ragione era buona: i riti dicevano il
      // nome e mostravano un gesto, e chi apriva non sapeva cosa ne avrebbe
      // portato via.
      //
      // **Il fondatore ha misurato l'effetto e non l'intenzione**: l'Arcano
      // *"annuncia un rito che non esiste"*, e la prima cosa che si legge
      // aprendo un Dono e' un compito. La voce 2.00 lo ha trovato in tutti e
      // cinque, non solo li'. Cio' che resta al posto delle tre righe e' la
      // risposta, che l'ordine CO voce 17 aveva gia' scritto e messo sopra.
      //
      // **Le tre righe non sono state cancellate dal dato**: vivono ancora su
      // `DailyElement` e descrivono il Dono nel menu' degli avvisi, dove una
      // descrizione serve davvero. Cio' che esce e' la loro comparsa in cima
      // al responso.
      const schermate = [
        'lib/features/rituals/ritual_gift_card.dart', // Soffio
        // L'Arcano dell'Alba, ordine DT, al posto dell'Alba e dell'Oracolo.
        'lib/features/rituals/arcano_dell_alba_screen.dart',
        'lib/features/rituals/sunset_rune_screen.dart', // Tramonto
        'lib/features/rituals/dream_rite_screen.dart', // Sogno
      ];
      final conIlRito = <String>[];
      var guardate = 0;
      for (final file in schermate) {
        guardate++;
        if (File(file).readAsStringSync().contains('LeTreRigheDelRito(')) {
          conIlRito.add(file);
        }
      }
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: schermate di rito guardate $guardate, che '
          'annunciano ancora un rito ${conIlRito.length}');
      expect(guardate, 4,
          reason: 'l elenco delle schermate si e svuotato: questa prova '
              'sarebbe verde senza aver guardato niente');
      expect(conIlRito, isEmpty,
          reason: 'queste schermate annunciano ancora un rito con le sue tre '
              'righe di istruzioni:\n${conIlRito.join("\n")}');
    });

    test('il respiro contato non e\' piu\' un testo da leggere', () {
      // La frase "tre dentro e tre fuori, sei giri, corti come i tratti"
      // spariva come istruzione e diventava un respiro guidato: se tornasse
      // dentro il testo composto, tornerebbe il compito.
      final dono = File('lib/core/rituals/dawn_gift.dart').readAsStringSync();
      expect(dono.contains(r'${rito.respiro}'), isFalse,
          reason: 'il respiro contato e\' tornato dentro il testo del dono: '
              'una istruzione criptica scritta e\' un compito, un respiro '
              'guidato e\' un\'esperienza');
      final scheda =
          File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
      // **LA STORIA DI QUESTA RIGA HA TRE CAPITOLI, e l'ultimo comanda.**
      // P.17 chiedeva che la scheda guidasse il respiro; S.13 lo porto' nel
      // Soffio lasciando nella scheda un ponte di una riga; e la voce 07
      // dell'ordine BB ha tolto anche il ponte, per decisione del fondatore:
      // ogni dono ha la sua ora e il suo posto, e chi arriva all'Alba non va
      // mandato altrove. Questa prova pretendeva ancora il ponte del secondo
      // capitolo, cioe' l'esatto contrario della decisione in vigore,
      // sorvegliata da `il_respiro_vive_nel_soffio_test`. Ordine BD voce 02.
      expect(scheda, isNot(contains('ponte_verso_il_soffio')),
          reason: 'il ponte verso il Soffio e\' tornato nella scheda del '
              'dono: la voce BB 07 lo ha tolto per decisione del fondatore');
      // E il respiro guidato e' UNO SOLO in tutto il progetto.
      final sorgenti = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(sorgenti.length, greaterThan(100),
          reason: 'la ricerca ha guardato ${sorgenti.length} sorgenti');
      final quanti = sorgenti
          .where((f) => f.readAsStringSync().contains('class GuidaDelRespiro'))
          .length;
      expect(quanti, 1,
          reason: 'esistono $quanti respiri guidati: due respiri nello stesso '
              'progetto sono un\'altra occorrenza della famiglia delle due '
              'porte');
    });
  });

  group('P.18 i doni si agganciano fra loro', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('la parola del mattino torna la sera, e solo quella di oggi',
        () async {
      // **Dall'ordine DT e' il dono della carta dell'alba.**
      ArchivioDellAlba.dimenticaLaMemoria();
      final mattina = DateTime(2026, 8, 12, 7, 10);
      final presa = await ArchivioDellAlba.estraiOggi(mattina, caso: Random(5));
      final sera = DateTime(2026, 8, 12, 22, 40);
      expect(
          (await FiloDelGiorno.donoDiStamattina(sera))?.secondo, presa.secondo);
      // Domani sera quel dono non e' piu' "stamattina".
      final domani = DateTime(2026, 8, 13, 22, 40);
      expect(await FiloDelGiorno.donoDiStamattina(domani), isNull,
          reason: '"Stamattina la tua parola era X" con la parola di ieri e\' '
              'una bugia, e per giunta una che la persona riconosce');
    });

    test('il giorno rituale non finisce a mezzanotte', () async {
      // Chi apre il Sigillo del Sogno all'una di notte sta chiudendo il giorno
      // prima: se il filo si rompesse li', si romperebbe proprio nel momento
      // in cui deve tenere.
      ArchivioDellAlba.dimenticaLaMemoria();
      final mattina = DateTime(2026, 8, 12, 7, 0);
      final presa = await ArchivioDellAlba.estraiOggi(mattina, caso: Random(6));
      final notteFonda = DateTime(2026, 8, 13, 1, 20);
      expect((await FiloDelGiorno.donoDiStamattina(notteFonda))?.secondo,
          presa.secondo);
      // Ma dopo l'alba del giorno rituale successivo, no.
      final mattinaDopo = DateTime(2026, 8, 13, 7, 30);
      expect(await FiloDelGiorno.donoDiStamattina(mattinaDopo), isNull);
    });

    test('la domanda di Medora torna il mattino DOPO, non lo stesso giorno',
        () async {
      final stesa = DateTime(2026, 8, 12, 21, 0);
      await FiloDelGiorno.segnaLaDomanda(
          'Cosa sei disposto a lasciare andare?', stesa);
      // Lo stesso giorno non torna: sarebbe la stessa schermata che si ripete.
      expect(await FiloDelGiorno.domandaDiIeri(stesa), isNull);
      final domani = DateTime(2026, 8, 13, 7, 5);
      expect(await FiloDelGiorno.domandaDiIeri(domani),
          'Cosa sei disposto a lasciare andare?');
      // E dopo due giorni non e' piu' la domanda che ti era stata lasciata.
      final dopodomani = DateTime(2026, 8, 14, 7, 5);
      expect(await FiloDelGiorno.domandaDiIeri(dopodomani), isNull);
    });

    test('le due formule sono quelle dell\'ordine', () {
      // **LA FORMULA E' CRESCIUTA, e la legge no.** Ordine CQ voce 2.09, 3
      // settembre 2026: la riga diceva che parola era e finiva li', cioe'
      // portava un fatto e non una risposta. Adesso dice anche che cosa ne e'
      // stato. Quello che l'ordine P voce 18 pretende, cioe' che il richiamo
      // NOMINI la parola del mattino, resta intero, ed e' quello che si
      // misura: la frase esatta era una copia del testo, e una copia si rompe
      // ogni volta che il testo migliora.
      // **E LA COPIA SI E ROTTA DAVVERO, il 10 settembre 2026.** Ordine DD
      // voce 02: la parola dentro la frase adesso sta fra virgolette basse,
      // e questo `startsWith` pretendeva la formula parola per parola. Il
      // commento qui sopra lo aveva gia detto e la riga sotto lo faceva
      // ancora.
      //
      // **Cio che l ordine P voce 18 pretende e che il richiamo NOMINI la
      // parola del mattino**, e quello e cio che si misura adesso: che la
      // parola ci sia dentro la frase. Come si scrive lo sorveglia la
      // guardia della voce DD.02.
      final richiamo = FiloDelGiorno.richiamoDellaParola('Soglia');
      // ignore: avoid_print
      print('ORDINE P VOCE 18: il richiamo della sera dice "$richiamo"');
      expect(richiamo.contains('Soglia'), isTrue,
          reason: 'il richiamo della sera non nomina la parola del mattino: '
              '"$richiamo"');
      expect(richiamo, startsWith('Stamattina la tua parola era'));
      expect(FiloDelGiorno.richiamoDellaDomanda('E adesso?'),
          startsWith('Ieri Medora ti ha lasciato questa domanda.'));
    });

    test('il filo non apre una seconda porta per la runa del tramonto', () {
      // La runa entra gia' nel Sogno dalla cerniera di `SunsetRuneMemory`. Due
      // porte per la stessa cosa e' la famiglia di difetti piu' frequente di
      // questo progetto, quindi il filo del giorno non ne apre una seconda.
      final filo =
          File('lib/core/rituals/filo_del_giorno.dart').readAsStringSync();
      expect(filo.contains('rune'), isFalse,
          reason: 'il filo del giorno ha cominciato a tenere anche la runa: '
              'quella cerniera esiste gia\' in SunsetRuneMemory');
      final sogno = File('lib/features/rituals/dream_rite_screen.dart')
          .readAsStringSync();
      expect(sogno, contains('ultimaPerCerniera'),
          reason: 'il Sogno non nomina piu\' la runa del tramonto');
      expect(sogno, contains('parolaDiStamattina'),
          reason: 'il Sogno non richiama piu\' la parola del mattino');
    });
  });
}
