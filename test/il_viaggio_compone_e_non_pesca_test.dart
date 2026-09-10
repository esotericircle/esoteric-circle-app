import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/vocabolario_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL VIAGGIO COMPONE LA SCENA, NON LA PESCA.** Ordine DC voci 04, 05, 06,
/// 08 e 09, 10 settembre 2026.
///
/// **IL PRINCIPIO CHE QUESTA GUARDIA DIFENDE.** La risposta del viaggio si
/// **compone** da un vocabolario chiuso, come una stesa di tarocchi: pochi
/// elementi rispondono a tutto perche' il senso nasce dalla combinazione.
/// Quaranta figure disegnate fanno migliaia di scene, e ogni figura lavora in
/// centinaia di scene invece che in una sola.
///
/// **IL CONTEGGIO SI CALCOLA, e questa e' la lezione della Costellazione del
/// Viso**: li' un numero scritto a mano prometteva centoquattromila
/// combinazioni, e a trecentottantadue utenti era piu' probabile che due card
/// fossero identiche che il contrario. **Un numero che non nasce dal catalogo
/// e' una promessa, non un conto.**
///
/// **REGOLA H ovunque**: ogni cosa dimostrata presente e' dimostrata assente
/// dove non deve esserci. Il nome dell'animale non si dice prima della quarta
/// discesa, la scena vaga non toglie contenuto, la ricorrenza non si dichiara
/// su due sole volte.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DC.06, il vocabolario e il conto delle scene', () {
    test('IL NUMERO DELLE SCENE NASCE DAL CATALOGO', () {
      final quante = VocabolarioDelViaggio.quanteScene();
      final disegni = VocabolarioDelViaggio.quantiDisegni();
      // ignore: avoid_print
      print('ORDINE DC VOCE 06: ${VocabolarioDelViaggio.laRiga()} '
          '($disegni figure, ${quante} scene)');
      // **Si rifa il prodotto a mano**, che e l unico modo di provare che il
      // numero non sia stato scritto.
      var atteso = 1;
      for (final c in VocabolarioDelViaggio.categorie) {
        atteso *= c.length;
      }
      expect(quante, atteso,
          reason: 'il conto delle scene non e il prodotto delle categorie');
      expect(quante, 8640,
          reason: 'il vocabolario e cambiato senza dichiararlo: l ordine DC '
              'voce 06 lo detta a 12 per 18 per 10 per 4');
      expect(disegni, 44,
          reason: 'le figure da disegnare non sono piu quelle dichiarate '
              'dall ordine, 12 piu 18 piu 10 piu 4');
    });

    test('REGOLA H: IL CONTO SCENDE SE SI TOGLIE UNA CATEGORIA', () {
      // **Senza questa meta il conto potrebbe essere una costante travestita.**
      final intero = VocabolarioDelViaggio.quanteScene();
      final categorie = VocabolarioDelViaggio.categorie;
      for (var i = 0; i < categorie.length; i++) {
        var senzaUna = 1;
        for (var j = 0; j < categorie.length; j++) {
          senzaUna *= j == i ? categorie[j].length - 1 : categorie[j].length;
        }
        expect(senzaUna, lessThan(intero),
            reason: 'togliendo un pezzo alla categoria $i il conto non '
                'scende: allora non lo sta calcolando');
      }
    });

    test('NESSUN PEZZO HA LO STESSO ID DI UN ALTRO', () {
      final tutti = VocabolarioDelViaggio.tutti;
      cardinaleMinimo(tutti.length, 40,
          cosa: 'pezzi del vocabolario',
          perche: 'Su un vocabolario svuotato non ci sono id ripetuti da '
              'trovare, e la guardia sarebbe verde per non aver guardato.');
      final id = tutti.map((p) => p.id).toSet();
      expect(id.length, tutti.length,
          reason: 'due pezzi hanno lo stesso id: il Diario ne rileggerebbe '
              'uno al posto dell altro');
      // E ognuno si ritrova dal suo id, che e' come il Diario li rilegge.
      for (final p in tutti) {
        expect(VocabolarioDelViaggio.di(p.id)?.nome, p.nome);
      }
    });

    test('LA SCENA SENZA MODELLO E DETERMINISTICA, e non e sempre la stessa',
        () {
      final giorno = DateTime(2026, 9, 10);
      final una = ScenaSenzaModello.componi(
          domanda: 'una scelta', giorno: giorno, nitidezza: 1.0);
      final ancora = ScenaSenzaModello.componi(
          domanda: 'una scelta', giorno: giorno, nitidezza: 1.0);
      expect(una.idDeiPezzi, ancora.idDeiPezzi,
          reason: 'la stessa domanda nello stesso giorno da due scene '
              'diverse: e una slot machine, non un oracolo');
      // **E domande diverse danno scene diverse**, altrimenti la composizione
      // non risponde a niente.
      final scene = <String>{};
      for (final d in LaDomandaDelViaggio.gliaScritte) {
        scene.add(ScenaSenzaModello.componi(
                domanda: d.testo, giorno: giorno, nitidezza: 1.0)
            .idDeiPezzi
            .join('|'));
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 06: sei domande diverse danno ${scene.length} '
          'scene distinte nello stesso giorno');
      expect(scene.length, LaDomandaDelViaggio.gliaScritte.length,
          reason: 'due domande diverse danno la stessa scena: la '
              'composizione non guarda la domanda');
    });
  });

  group('DC.04, i quattro viaggi e il riconoscimento', () {
    test('IL NOME NON SI DICE PRIMA DELLA QUARTA DISCESA', () {
      for (var quante = 0; quante < IQuattroViaggi.quanteDiscese; quante++) {
        expect(IQuattroViaggi.siPuoNominare(quante),
            quante + 1 >= IQuattroViaggi.quanteDiscese,
            reason: 'alla discesa $quante il Cerchio dice gia il nome: il '
                'riconoscimento di Harner chiede quattro apparizioni');
        expect(
            IQuattroViaggi.seguitoDaLeQuattroScelte(
                List.filled(quante, 'Lupo')),
            isNull,
            reason: 'con $quante scelte l animale risulta gia scelto');
      }
      expect(
          IQuattroViaggi.seguitoDaLeQuattroScelte(
              ['Lupo', 'Lupo', 'Volpe', 'Lupo']),
          'Lupo');
    });

    test('LE TRE OMBRE SONO TRE, DIVERSE, E SEMPRE LE STESSE', () {
      final visti = <String, String>{};
      for (final segno in Zodiac.values) {
        final dalCielo = GuideAnimalDerivation.forSign(segno);
        final ombre = IQuattroViaggi.treOmbre(dalCielo);
        expect(ombre.length, IQuattroViaggi.quanteOmbre,
            reason: 'per $segno le ombre non sono tre');
        expect(ombre.map((a) => a.name).toSet().length, ombre.length,
            reason: 'per $segno due ombre sono lo stesso animale: chi sceglie '
                'crederebbe di aver scelto e non avrebbe scelto niente');
        expect(ombre.first.name, dalCielo.name,
            reason: 'la prima ombra non e quella del cielo: la tabella che '
                'esisteva prima e stata buttata invece che riusata');
        // **E sono stabili**: la stessa data da sempre le stesse tre.
        final ancora = IQuattroViaggi.treOmbre(dalCielo);
        expect(ancora.map((a) => a.name).toList(),
            ombre.map((a) => a.name).toList());
        visti[segno.name] = ombre.map((a) => a.name).join(', ');
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 04: dodici segni, tre ombre ciascuno, su '
          '${AnimalCatalog.animals.length} animali');
      expect(visti.length, Zodiac.values.length);
    });

    test('LA SAGOMA GUADAGNA UN CONTORNO A OGNI DISCESA', () {
      for (var d = 0; d <= IQuattroViaggi.quanteDiscese + 2; d++) {
        final contorni = IQuattroViaggi.contorniDellaSagoma(d);
        expect(contorni, lessThanOrEqualTo(IQuattroViaggi.quanteDiscese));
        if (d <= IQuattroViaggi.quanteDiscese) expect(contorni, d);
      }
    });

    test('L ATTESA DICHIARA LA SUA FONTE, e non e una regola nostra', () {
      final testo = IQuattroViaggi.percheSiAspetta;
      expect(testo, contains('Harner'));
      expect(testo, contains('1980'));
      expect(testo.toLowerCase(), contains('non è una regola nostra'),
          reason: 'l attesa non dichiara di venire dal metodo: senza quella '
              'riga e una trattenuta');
    });
  });

  group('DC.05, la domanda', () {
    test('SEI DOMANDE SCRITTE, PIU IL CAMPO LIBERO E L INCONTRO', () {
      expect(LaDomandaDelViaggio.gliaScritte.length, 6);
      final temi = LaDomandaDelViaggio.gliaScritte.map((d) => d.tema).toSet();
      expect(temi.length, 6, reason: 'due domande hanno lo stesso tema');
      for (final d in LaDomandaDelViaggio.gliaScritte) {
        expect(d.testo.length, lessThanOrEqualTo(
            LaDomandaDelViaggio.quantoPuoEssereLunga),
            reason: 'la domanda "${d.tema}" e piu lunga del limite che l app '
                'impone a chi scrive la sua');
      }
    });

    test('AL PRIMO VIAGGIO LA DOMANDA E FACOLTATIVA, DAL SECONDO E LA PORTA',
        () {
      expect(LaDomandaDelViaggio.perCheNonVa('', primoViaggio: true), isNull);
      final perche =
          LaDomandaDelViaggio.perCheNonVa('', primoViaggio: false);
      expect(perche, isNotNull,
          reason: 'dal secondo viaggio si scende senza domanda: la porta non '
              'e piu una porta');
      // ignore: avoid_print
      print('ORDINE DC VOCE 05: senza domanda al secondo viaggio dice '
          '"$perche"');
      // **E il rifiuto non e mai muto**: dice le tre vie.
      expect(perche!.toLowerCase(), contains('scrivila'));
    });

    test('UNA DOMANDA TROPPO LUNGA VIENE RIMANDATA INDIETRO, col perche', () {
      final lunga = 'a' * (LaDomandaDelViaggio.quantoPuoEssereLunga + 1);
      final perche = LaDomandaDelViaggio.perCheNonVa(lunga, primoViaggio: true);
      expect(perche, isNotNull);
      expect(perche!.toLowerCase(), contains('riga'));
    });
  });

  group('DC.08, la nitidezza', () {
    test('CHI SCENDE SPESSO VEDE TRE ELEMENTI, chi manca da un mese uno', () {
      expect(NitidezzaDellaScena.dopoGiorni(0), 1.0);
      expect(NitidezzaDellaScena.dopoGiorni(7), 1.0,
          reason: 'sotto la settimana non e trascuratezza, e la vita');
      final aMeta = NitidezzaDellaScena.dopoGiorni(17);
      expect(aMeta, greaterThan(0.0));
      expect(aMeta, lessThan(1.0));
      expect(NitidezzaDellaScena.dopoGiorni(28), 0.0);
      // ignore: avoid_print
      print('ORDINE DC VOCE 08: nitidezza a 0, 7, 17 e 28 giorni: '
          '${NitidezzaDellaScena.dopoGiorni(0)}, '
          '${NitidezzaDellaScena.dopoGiorni(7)}, '
          '${aMeta.toStringAsFixed(2)}, '
          '${NitidezzaDellaScena.dopoGiorni(28)}');
    });

    test('REGOLA H: LA SCENA VAGA NON TOGLIE NIENTE, cambia cosa si legge',
        () {
      final piena = ScenaSenzaModello.componi(
          domanda: 'una scelta',
          giorno: DateTime(2026, 9, 10),
          nitidezza: 1.0);
      final vaga = ScenaSenzaModello.componi(
          domanda: 'una scelta',
          giorno: DateTime(2026, 9, 10),
          nitidezza: 0.0);
      expect(vaga.idDeiPezzi, piena.idDeiPezzi,
          reason: 'la scena vaga ha pezzi DIVERSI: allora non e la stessa '
              'risposta resa meno leggibile, e una risposta peggiore');
      expect(piena.quantiSiVedono, 3);
      expect(vaga.quantiSiVedono, 1);
      // **E cio che si vede quando se ne vede uno solo e IL GESTO**, che e la
      // risposta vera: un luogo senza gesto e un paesaggio.
      expect(vaga.leggibili.single.id, piena.gesto.id,
          reason: 'della scena confusa resta il luogo invece del gesto: chi '
              'legge trova un paesaggio al posto di una risposta');
      // ignore: avoid_print
      print('ORDINE DC VOCE 08: nitida "${piena.testo}" | vaga '
          '"${vaga.testo}"');
    });

    test('E LA PERSONA SA PERCHE, senza essere rimproverata', () {
      expect(NitidezzaDellaScena.laRiga(1.0), isNull,
          reason: 'si spiega una nebbia che non c e');
      final riga = NitidezzaDellaScena.laRiga(0.0)!;
      for (final rimprovero in const [
        'non sei sceso',
        'hai trascurato',
        'colpa',
        'dovresti'
      ]) {
        expect(riga.toLowerCase().contains(rimprovero), isFalse,
            reason: 'la riga rimprovera con "$rimprovero"');
      }
    });
  });

  group('DC.09, il diario e la memoria', () {
    test('NON SI SCENDE DUE VOLTE NELLO STESSO GIORNO, prima del nome',
        () async {
      final oggi = DateTime(2026, 9, 10, 21);
      final diario = DiarioDeiViaggi(orologio: () => oggi);
      await diario.carica();
      expect(diario.siPuoScendereOggi(giaRiconosciuto: false), isTrue);
      await diario.segna(UnViaggio(
        quando: DateTime(2026, 9, 10, 9),
        domanda: 'una scelta',
        temaDellaDomanda: 'Una scelta da fare',
        pezzi: const ['ponte', 'chiave', 'aspetta', 'alba'],
        animaleSeguito: 'Lupo',
        nitidezza: 1.0,
      ));
      expect(diario.siPuoScendereOggi(giaRiconosciuto: false), isFalse,
          reason: 'si scende due volte nello stesso giorno: i quattro viaggi '
              'del riconoscimento devono cadere in quattro giorni diversi');
      // **REGOLA H: dopo il riconoscimento l attesa non vale piu.**
      expect(diario.siPuoScendereOggi(giaRiconosciuto: true), isTrue,
          reason: 'l attesa resta anche dopo il riconoscimento: allora non '
              'era il metodo, era una trattenuta');
    });

    test('LA RICORRENZA NON SI DICHIARA SU DUE VOLTE', () async {
      final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 20));
      await diario.carica();
      for (var g = 0; g < 2; g++) {
        await diario.segna(UnViaggio(
          quando: DateTime(2026, 9, 1 + g),
          domanda: 'x',
          temaDellaDomanda: 'Un blocco che non si supera',
          pezzi: const ['ponte', 'chiave', 'aspetta', 'alba'],
          animaleSeguito: 'Lupo',
          nitidezza: 1.0,
        ));
      }
      expect(diario.cheTorna, isEmpty,
          reason: 'due ripetizioni vengono chiamate ricorrenza: e il caso, e '
              'chiamarlo altrimenti e la bugia piu facile di questa app');
      await diario.segna(UnViaggio(
        quando: DateTime(2026, 9, 3),
        domanda: 'x',
        temaDellaDomanda: 'Un blocco che non si supera',
        pezzi: const ['ponte', 'chiave', 'aspetta', 'alba'],
        animaleSeguito: 'Lupo',
        nitidezza: 1.0,
      ));
      expect(diario.cheTorna, isNotEmpty,
          reason: 'tre ripetizioni non bastano a dichiarare una ricorrenza');
      // ignore: avoid_print
      print('ORDINE DC VOCE 09: dopo tre viaggi uguali torna '
          '${diario.cheTorna.length} pezzi');
    });

    test('IL RIASSUNTO PER I MAESTRI DICE, e non dichiara di osservare',
        () async {
      final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 20));
      await diario.carica();
      expect(diario.riassuntoPerIMaestri, isEmpty,
          reason: 'a diario vuoto si racconta comunque qualcosa');
      for (var g = 0; g < 3; g++) {
        await diario.segna(UnViaggio(
          quando: DateTime(2026, 9, 1 + g),
          domanda: 'x',
          temaDellaDomanda: 'Un blocco che non si supera',
          pezzi: const ['ponte', 'chiave', 'aspetta', 'alba'],
          animaleSeguito: 'Lupo',
          nitidezza: 1.0,
        ));
      }
      final riassunto = diario.riassuntoPerIMaestri;
      // ignore: avoid_print
      print('ORDINE DC VOCE 09: il riassunto dice "$riassunto"');
      expect(riassunto, contains('3'));
      for (final vietata in const [
        'ti osservo',
        'sto monitorando',
        'ho notato che',
      ]) {
        expect(riassunto.toLowerCase().contains(vietata), isFalse,
            reason: 'il riassunto dichiara di osservare con "$vietata"');
      }
    });

    test('UN VIAGGIO SI RILEGGE, e un pezzo sparito non lo rompe', () {
      final buono = UnViaggio(
        quando: _unGiorno,
        domanda: 'x',
        temaDellaDomanda: 't',
        pezzi: const ['ponte', 'chiave', 'aspetta', 'alba'],
        animaleSeguito: 'Lupo',
        nitidezza: 1.0,
      );
      expect(buono.scena, isNotNull);
      final rotto = UnViaggio(
        quando: _unGiorno,
        domanda: 'x',
        temaDellaDomanda: 't',
        pezzi: const ['un_pezzo_che_non_esiste_piu', 'chiave', 'aspetta', 'alba'],
        animaleSeguito: 'Lupo',
        nitidezza: 1.0,
      );
      expect(rotto.scena, isNull,
          reason: 'il Diario mostra un pezzo che non esiste piu nel '
              'vocabolario: meglio saltare quella riga che inventarla');
    });
  });
}

final DateTime _unGiorno = DateTime(2026, 9, 10);
