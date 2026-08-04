import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/transiti_del_giorno.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// QUI MUORE L'HASH: l'Oroscopo si compone dal cielo vero di questa persona.
///
/// **Cosa c'era prima, ed era misurabile.** La seconda meta' di ogni scheda
/// usciva da `HoroscopeData.dayPools`, frasi generiche scelte da una hash su
/// segno, giorno e anno. Conseguenza: due persone dello stesso segno con carte
/// natali diverse leggevano la stessa identica riga, e il testo cambiava di
/// giorno in giorno perche' cambiava un numero, non perche' fosse cambiato
/// qualcosa in cielo.
///
/// Le regole che questo file sorveglia, e ognuna vive in un posto solo:
///
/// 1. la carta natale cambia il testo, e la prova lo verifica su due carte;
/// 2. il giorno cambia il testo, e per la ragione giusta;
/// 3. nessuna frase data un transito al giorno quando il motore non lo sa;
/// 4. la Profonda produce davvero piu' testo della Breve;
/// 5. la hash resta, ma la scheda che ne esce si dichiara ripiego;
/// 6. la card da condividere legge le stesse schede della schermata.
void main() {
  // DUE CARTE VERE, e sono diverse davvero: nascite a diciotto anni e mezzo di
  // distanza, quindi Sole, Luna e i lenti stanno in punti lontani del giro.
  NatalChart carta({
    required double sole,
    required double luna,
    required double venere,
    required double marte,
    required double saturno,
    required double ascendente,
  }) =>
      NatalChart(
        sunSign: Zodiac.leo,
        planets: [
          PlanetPosition(
              id: 'sun', name: 'Sole', glyph: '☉', longitude: sole, sign: Zodiac.leo),
          PlanetPosition(
              id: 'moon', name: 'Luna', glyph: '☽', longitude: luna, sign: Zodiac.leo),
          PlanetPosition(
              id: 'venus', name: 'Venere', glyph: '♀', longitude: venere, sign: Zodiac.leo),
          PlanetPosition(
              id: 'mars', name: 'Marte', glyph: '♂', longitude: marte, sign: Zodiac.leo),
          PlanetPosition(
              id: 'saturn', name: 'Saturno', glyph: '♄', longitude: saturno, sign: Zodiac.leo),
        ],
        ascendantLongitude: ascendente,
        midheavenLongitude: (ascendente + 270.0) % 360.0,
        houses: [
          for (var n = 1; n <= 12; n++)
            HouseCusp(number: n, longitude: (ascendente + (n - 1) * 30.0) % 360.0),
        ],
        hasTime: true,
      );

  final cartaUna = carta(
      sole: 128.4, luna: 12.7, venere: 150.2, marte: 61.9, saturno: 300.5, ascendente: 205.0);
  final cartaDue = carta(
      sole: 131.1, luna: 244.8, venere: 96.3, marte: 331.4, saturno: 44.2, ascendente: 18.0);

  final giorno = DateTime.utc(2026, 8, 5, 12);
  final altroGiorno = DateTime.utc(2026, 8, 26, 12);

  List<HoroscopeCard> schede(NatalChart? c, DateTime quando,
          {bool profonda = false}) =>
      Horoscope.forSign(
        sign: Zodiac.leo,
        dayOfYear: Horoscope.dayOfYear(quando),
        year: quando.year,
        cielo: CieloDiOggi.perIlGiorno(adesso: quando, carta: c),
        profonde: {
          for (final d in HoroscopeDomain.values) d: profonda,
        },
      );

  group('VOCE 2a. Il cielo di questa persona, non un numero', () {
    test('Il cielo misurato porta transiti veri, con casa e bersaglio', () {
      final cielo = CieloDiOggi.perIlGiorno(adesso: giorno, carta: cartaUna);
      expect(cielo.ceCieloVero, isTrue,
          reason: 'con una carta completa non c\'e\' un solo transito attivo: '
              'la prova qui sotto misurerebbe il vuoto');
      expect(cielo.livello, LivelloPersonalizzazione.cartaCompleta);
      expect(cielo.voci.any((v) => v.casa != null), isTrue,
          reason: 'nessun transito sa in che casa passa, quindi il testo non '
              'potra\' mai dire DOVE nella vita');
      // L'ordine e' per orbo crescente: il primo e' quello che oggi pesa piu'.
      for (var i = 1; i < cielo.voci.length; i++) {
        expect(cielo.voci[i].orbe,
            greaterThanOrEqualTo(cielo.voci[i - 1].orbe));
      }
    });

    test('DUE CARTE DIVERSE, due testi diversi, su tutti e quattro i domini',
        () {
      final una = schede(cartaUna, giorno);
      final due = schede(cartaDue, giorno);
      for (var i = 0; i < HoroscopeDomain.values.length; i++) {
        expect(una[i].text, isNot(due[i].text),
            reason: 'la scheda ${HoroscopeDomain.values[i].label} dice la '
                'stessa identica cosa a due persone con carte natali diverse: '
                'e\' l\'oroscopo del segno, non della persona');
        expect(una[i].dalCieloVero, isTrue);
      }
    });

    test('LO STESSO GIORNO NON CAMBIA, e un altro giorno si', () {
      // Due letture nella stessa giornata devono dare la stessa cosa: se
      // cambiasse a ogni apertura, la persona penserebbe di aver letto male.
      expect(schede(cartaUna, giorno).map((c) => c.text).toList(),
          schede(cartaUna, giorno.add(const Duration(hours: 3))).map((c) => c.text).toList(),
          reason: 'due aperture nella stessa giornata danno testi diversi');
      final oggi = schede(cartaUna, giorno);
      final poi = schede(cartaUna, altroGiorno);
      expect(oggi.map((c) => c.text).toList(),
          isNot(poi.map((c) => c.text).toList()),
          reason: 'ventun giorni dopo il cielo dice esattamente la stessa '
              'cosa: il testo non sta guardando il cielo');
    });

    test('Il testo NOMINA il pianeta, la casa e il punto natale toccato', () {
      final generale = schede(cartaUna, giorno)
          .firstWhere((c) => c.domain == HoroscopeDomain.generale);
      final nominaUnPianeta = CorpoCeleste.values
          .any((c) => generale.text.contains(c.nome));
      expect(nominaUnPianeta, isTrue,
          reason: 'il testo non nomina nessun pianeta: e\' ancora una frase '
              'generica');
      expect(generale.text, contains('casa'),
          reason: 'il testo non dice in che settore della vita cade il '
              'passaggio, cioe\' parla di geometria invece che di te');
      expect(generale.text, contains('di nascita'),
          reason: 'il testo non nomina nessun punto della carta natale');
    });
  });

  group('VOCE 2b. Il giorno esatto non si promette', () {
    test('Saturno non si data mai al giorno, e la frase lo dichiara', () {
      // **IL NUMERO CHE DECIDE.** Misurato il 5 agosto 2026 con
      // `flutter test tool/quanto_e_incerto_il_giorno.dart` su tre date: lo
      // scarto di Saturno contro JPL Horizons e' 0,1414 gradi e Saturno
      // percorre 0,0159 gradi al giorno, cioe' fra 1,29 e 8,92 giorni di
      // incertezza su QUANDO l'aspetto e' esatto. Per dire che c'e' basta e
      // avanza, l'orbo e' due gradi. Per dire "oggi" no.
      final jd = TransitiDelGiorno.giornoGiulianoDi(giorno);
      final incerto = Effemeridi.giorniDiIncertezza(CorpoCeleste.saturno, jd);
      expect(incerto, greaterThan(1.0),
          reason: 'Saturno risulta certo entro il giorno: se il motore e\' '
              'davvero migliorato, questa regola va rimisurata invece che '
              'allentata a mano');

      const v = VoceDelCielo(
        transito: CorpoCeleste.saturno,
        bersaglio: 'Sole',
        idBersaglio: 'sun',
        aspetto: AspectType.square,
        orbe: 0.4,
        applicativo: true,
        casa: 10,
        retrogrado: false,
        giorniDiIncertezza: 5.2,
      );
      expect(v.ilGiornoSiPuoDire, isFalse);
      final testo = CorrenteDelCielo.frase(v);
      expect(testo, contains('in questi giorni'));
      expect(testo, contains('senza una data precisa'),
          reason: 'la frase non dichiara che il giorno non si sa');
    });

    test('Nessuna frase del cielo data un transito lento al giorno', () {
      // Enumerata su tutti i corpi e tutti gli aspetti, non su un campione.
      const vietate = ['oggi', 'domani', 'stasera', 'esatto', 'esatta'];
      for (final corpo in CorpoCeleste.values) {
        for (final tipo in AspectType.values) {
          final v = VoceDelCielo(
            transito: corpo,
            bersaglio: 'Sole',
            idBersaglio: 'sun',
            aspetto: tipo,
            orbe: 1.0,
            applicativo: true,
            casa: 7,
            retrogrado: false,
            giorniDiIncertezza: 3.0, // il giorno non si sa
          );
          final testo = CorrenteDelCielo.frase(v).toLowerCase();
          for (final parola in vietate) {
            expect(testo.contains(parola), isFalse,
                reason: '${corpo.nome} ${tipo.italianName}: la frase dice '
                    '"$parola" su un passaggio che il motore non sa datare. '
                    '«$testo»');
          }
        }
      }
    });

    test('Chi il giorno lo sa, il giorno lo puo\' dire', () {
      // Il guardiano dell'altra prova: se la lingua fosse larga SEMPRE, quella
      // sopra resterebbe verde senza sorvegliare niente.
      final jd = TransitiDelGiorno.giornoGiulianoDi(giorno);
      for (final corpo in const [
        CorpoCeleste.sole,
        CorpoCeleste.luna,
        CorpoCeleste.mercurio,
        CorpoCeleste.venere,
      ]) {
        expect(Effemeridi.giorniDiIncertezza(corpo, jd), lessThan(1.0),
            reason: '${corpo.nome} risulta incerto oltre il giorno');
      }
      const v = VoceDelCielo(
        transito: CorpoCeleste.venere,
        bersaglio: 'Luna',
        idBersaglio: 'moon',
        aspetto: AspectType.trine,
        orbe: 0.5,
        applicativo: true,
        casa: 5,
        retrogrado: false,
        giorniDiIncertezza: 0.01,
      );
      expect(v.ilGiornoSiPuoDire, isTrue);
      expect(CorrenteDelCielo.frase(v), isNot(contains('senza una data')));
    });

    test('Un retrogrado si dichiara, e solo chi retrograda davvero', () {
      const v = VoceDelCielo(
        transito: CorpoCeleste.mercurio,
        bersaglio: 'Ascendente',
        idBersaglio: 'asc',
        aspetto: AspectType.conjunction,
        orbe: 0.2,
        applicativo: false,
        casa: 1,
        retrogrado: true,
        giorniDiIncertezza: 0.01,
      );
      expect(CorrenteDelCielo.frase(v), startsWith('Mercurio è retrogrado.'));
      expect(CorrenteDelCielo.frase(v), contains('al tuo Ascendente'));
      // Il Sole e la Luna non retrogradano: se comparissero qui sarebbe il
      // motore a mentire, non il testo.
      final retro = AspettiDiOggi.retrogradiDelGiorno(giorno);
      expect(retro.contains(CorpoCeleste.sole), isFalse);
      expect(retro.contains(CorpoCeleste.luna), isFalse);
    });
  });

  group('VOCE 2c. La Profonda consegna davvero di piu\'', () {
    test('Profonda e Breve non danno lo stesso testo', () {
      final breve = schede(cartaUna, giorno);
      final profonda = schede(cartaUna, giorno, profonda: true);
      for (var i = 0; i < HoroscopeDomain.values.length; i++) {
        expect(profonda[i].text, isNot(breve[i].text),
            reason: 'la scheda ${HoroscopeDomain.values[i].label} dice la '
                'stessa identica cosa a chi ha pagato la Profonda: e\' una '
                'funzione venduta e non consegnata');
        expect(profonda[i].text.length, greaterThan(breve[i].text.length),
            reason: 'la Profonda non e\' piu\' lunga della Breve');
      }
    });

    test('E la Profonda aggiunge FATTI, non aggettivi', () {
      // Tre voci contro una: la differenza deve essere altra sostanza, cioe'
      // altri pianeti nominati, non lo stesso passaggio raccontato piu' largo.
      expect(CorrenteDelCielo.quanteVoci(profonda: false), 1);
      expect(CorrenteDelCielo.quanteVoci(profonda: true), 3);
      final cielo = CieloDiOggi.perIlGiorno(adesso: giorno, carta: cartaUna);
      final quanti = cielo.voci.map((v) => v.transito).toSet().length;
      expect(quanti, greaterThan(1),
          reason: 'il cielo di prova ha un pianeta solo, quindi questa prova '
              'non puo\' misurare nessuna aggiunta');
      final profonda = CorrenteDelCielo.componi(
          cielo: cielo, dominio: HoroscopeDomain.generale, profonda: true)!;
      final breve = CorrenteDelCielo.componi(
          cielo: cielo, dominio: HoroscopeDomain.generale, profonda: false)!;
      final pianetiInProfonda =
          CorpoCeleste.values.where((c) => profonda.contains(c.nome)).length;
      final pianetiInBreve =
          CorpoCeleste.values.where((c) => breve.contains(c.nome)).length;
      expect(pianetiInProfonda, greaterThan(pianetiInBreve),
          reason: 'la Profonda nomina gli stessi pianeti della Breve: e\' lo '
              'stesso fatto detto piu\' lungo');
    });
  });

  group('VOCE 2d. La hash resta, ma si dichiara', () {
    test('Senza carta si ripiega sulla hash, e la scheda lo DICE', () {
      final senza = schede(null, giorno);
      for (final c in senza) {
        expect(c.dalCieloVero, isFalse,
            reason: 'la scheda ${c.domain.label} dice di venire dal cielo, ma '
                'un cielo non c\'era');
      }
      // E il testo e' proprio quello della hash: il ripiego non e' un vuoto.
      final pool = HoroscopeData.dayPools[0]!;
      expect(pool.any((f) => senza.first.text.endsWith(f)), isTrue,
          reason: 'il ripiego non e\' piu\' la corrente della hash: allora il '
              'testo di chi non ha la carta viene da chissa\' dove');
      expect(CorrenteDelCielo.notaDelLivello(CieloDiOggi.nessuno),
          CorrenteDelCielo.ripiegoDichiarato);
      expect(CorrenteDelCielo.ripiegoDichiarato, contains('non ancora al tuo cielo'));
      expect(CorrenteDelCielo.ripiegoDichiarato, contains('Completa i dati di nascita'),
          reason: 'il ripiego dichiara la mancanza senza dire come rimediare, '
              'cioe\' e\' un vicolo cieco');
    });

    test('Il cielo essenziale non e\' una carta, e non finge di esserlo', () {
      final essenziale =
          NatalChart.essential(sunSign: Zodiac.leo, hasTime: false);
      final cielo =
          CieloDiOggi.perIlGiorno(adesso: giorno, carta: essenziale);
      expect(cielo.ceCieloVero, isFalse);
      expect(cielo.livello, LivelloPersonalizzazione.soloSegno);
      expect(CorrenteDelCielo.notaDelLivello(cielo),
          CorrenteDelCielo.ripiegoDichiarato);
    });

    test('Con la carta ma senza ora, si dichiara cosa manca', () {
      final senzaOra = NatalChart(
        sunSign: Zodiac.leo,
        hasTime: false,
        planets: cartaUna.planets,
      );
      final cielo = CieloDiOggi.perIlGiorno(adesso: giorno, carta: senzaOra);
      expect(cielo.livello, LivelloPersonalizzazione.cartaSenzaOra);
      expect(cielo.ceCieloVero, isTrue,
          reason: 'senza ora gli aspetti ai pianeti si calcolano lo stesso');
      expect(cielo.voci.every((v) => v.casa == null), isTrue,
          reason: 'senza ora di nascita e\' comparsa una casa: le cuspidi '
              'discendono dall\'orizzonte all\'istante della nascita, quindi '
              'quella casa e\' inventata');
      expect(CorrenteDelCielo.notaDelLivello(cielo),
          CorrenteDelCielo.ripiegoSenzaOra);
    });

    test('Con la carta completa non c\'e\' niente da dichiarare', () {
      final cielo = CieloDiOggi.perIlGiorno(adesso: giorno, carta: cartaUna);
      expect(CorrenteDelCielo.notaDelLivello(cielo), isNull);
    });
  });

  group('VOCE 2f. La lingua, che le prove sui fatti non guardavano', () {
    // **QUESTE TRE PROVE NASCONO DA CIO' CHE SI E' VISTO LEGGENDO L'USCITA
    // VERA.** Le prove sui fatti erano tutte verdi e il testo diceva "Sole sta
    // attraversando la tua decima casa. Forma un trigono al tuo Luna di
    // nascita", due errori di italiano in una riga sola, piu' la stessa frase
    // della casa ripetuta due volte di fila nella Profonda. I fatti erano
    // giusti: era la lingua che nessuno guardava.
    test('Il Sole e la Luna portano l\'articolo, gli altri no', () {
      expect(CorrenteDelCielo.colSuoArticolo(CorpoCeleste.sole), 'Il Sole');
      expect(CorrenteDelCielo.colSuoArticolo(CorpoCeleste.luna), 'La Luna');
      for (final c in CorpoCeleste.values) {
        if (c == CorpoCeleste.sole || c == CorpoCeleste.luna) continue;
        expect(CorrenteDelCielo.colSuoArticolo(c), c.nome,
            reason: '${c.nome} ha preso un articolo che in italiano non vuole');
      }
      // E il testo vero comincia con l'articolo quando tocca al Sole.
      final testo = CorrenteDelCielo.frase(const VoceDelCielo(
        transito: CorpoCeleste.sole,
        bersaglio: 'Luna',
        idBersaglio: 'moon',
        aspetto: AspectType.trine,
        orbe: 0.4,
        applicativo: false,
        casa: 10,
        retrogrado: false,
        giorniDiIncertezza: 0.01,
      ));
      expect(testo, startsWith('Il Sole sta attraversando'));
      expect(testo, isNot(contains('al tuo Luna')),
          reason: 'esce "al tuo Luna di nascita", che e\' un errore che si '
              'legge a occhio nudo alla prima riga dell\'Oroscopo');
      expect(testo, contains('alla tua Luna di nascita'));
    });

    test('Ogni punto natale prende l\'articolo del suo genere', () {
      // Enumerata su tutti i corpi piu' i due angoli, non su un campione.
      const femminili = {'moon', 'venus'};
      for (final c in CorpoCeleste.values) {
        final testo = CorrenteDelCielo.frase(VoceDelCielo(
          transito: CorpoCeleste.marte,
          bersaglio: c.nome,
          idBersaglio: c.id,
          aspetto: AspectType.sextile,
          orbe: 1.0,
          applicativo: null,
          casa: 3,
          retrogrado: false,
          giorniDiIncertezza: 0.06,
        ));
        expect(
            testo,
            contains(femminili.contains(c.id)
                ? 'alla tua ${c.nome} di nascita'
                : 'al tuo ${c.nome} di nascita'),
            reason: '${c.nome}: articolo sbagliato in «$testo»');
      }
    });

    test('La casa non si ridice due volte per lo stesso pianeta', () {
      final voci = [
        for (final b in const ['saturn', 'mars'])
          VoceDelCielo(
            transito: CorpoCeleste.venere,
            bersaglio: b == 'saturn' ? 'Saturno' : 'Marte',
            idBersaglio: b,
            aspetto: AspectType.trine,
            orbe: b == 'saturn' ? 1.8 : 3.2,
            applicativo: true,
            casa: 12,
            retrogrado: false,
            giorniDiIncertezza: 0.01,
          ),
      ];
      final testo = CorrenteDelCielo.componi(
        cielo: CieloDiOggi(
            voci: voci, livello: LivelloPersonalizzazione.cartaCompleta),
        dominio: HoroscopeDomain.amore,
        profonda: true,
      )!;
      const casa = 'sta attraversando la tua dodicesima casa';
      expect(casa.allMatches(testo).length, 1,
          reason: 'la frase della casa compare '
              '${casa.allMatches(testo).length} volte: la Profonda paga tre '
              'voci e ne scrive due e mezza. «$testo»');
      expect(testo, contains('Venere forma anche'),
          reason: 'tolta la frase della casa, la seconda voce resta senza '
              'soggetto e non si capisce chi forma cosa');
    });
  });

  group('VOCE 2e. La card da condividere segue la scheda', () {
    test('La sintesi della card esce dalle stesse schede della schermata', () {
      // La card riceve `cards` e ne legge `synthesis`: e' la stessa lista che
      // la schermata mostra, non il corpus riletto per conto suo.
      final cards = schede(cartaUna, giorno);
      final generale =
          cards.firstWhere((c) => c.domain == HoroscopeDomain.generale);
      expect(generale.synthesis, isNotEmpty);
      expect(generale.text, startsWith(generale.synthesis),
          reason: 'la sintesi non e\' piu\' l\'inizio del testo della scheda: '
              'chi condivide manda agli altri una frase che sul suo schermo '
              'non c\'e\'');
    });
  });
}
