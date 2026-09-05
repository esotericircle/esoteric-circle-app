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
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: sole,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☽',
              longitude: luna,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'venus',
              name: 'Venere',
              glyph: '♀',
              longitude: venere,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'mars',
              name: 'Marte',
              glyph: '♂',
              longitude: marte,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'saturn',
              name: 'Saturno',
              glyph: '♄',
              longitude: saturno,
              sign: Zodiac.leo),
        ],
        ascendantLongitude: ascendente,
        midheavenLongitude: (ascendente + 270.0) % 360.0,
        houses: [
          for (var n = 1; n <= 12; n++)
            HouseCusp(
                number: n, longitude: (ascendente + (n - 1) * 30.0) % 360.0),
        ],
        hasTime: true,
      );

  final cartaUna = carta(
      sole: 128.4,
      luna: 12.7,
      venere: 150.2,
      marte: 61.9,
      saturno: 300.5,
      ascendente: 205.0);
  final cartaDue = carta(
      sole: 131.1,
      luna: 244.8,
      venere: 96.3,
      marte: 331.4,
      saturno: 44.2,
      ascendente: 18.0);

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
        expect(
            cielo.voci[i].orbe, greaterThanOrEqualTo(cielo.voci[i - 1].orbe));
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
      expect(
          schede(cartaUna, giorno).map((c) => c.text).toList(),
          schede(cartaUna, giorno.add(const Duration(hours: 3)))
              .map((c) => c.text)
              .toList(),
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
      final nominaUnPianeta =
          CorpoCeleste.values.any((c) => generale.text.contains(c.nome));
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
      expect(CorrenteDelCielo.ripiegoDichiarato,
          contains('non ancora al tuo cielo'));
      expect(CorrenteDelCielo.ripiegoDichiarato,
          contains('Completa i dati di nascita'),
          reason: 'il ripiego dichiara la mancanza senza dire come rimediare, '
              'cioe\' e\' un vicolo cieco');
    });

    test('Il cielo essenziale non e\' una carta, e non finge di esserlo', () {
      final essenziale =
          NatalChart.essential(sunSign: Zodiac.leo, hasTime: false);
      final cielo = CieloDiOggi.perIlGiorno(adesso: giorno, carta: essenziale);
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
      // **SI CERCA LA GLOSSA, non il verbo.** La prima stesura cercava "sta
      // attraversando la tua dodicesima casa", che e' la sintassi di UNA delle
      // cinque forme: col ventaglio aperto la stessa scheda puo' dire
      // "attraversa la tua dodicesima casa" e la prova non trovava piu'
      // niente, cioe' cascava per la ragione sbagliata. La glossa invece e' la
      // stessa in tutte le forme, perche' e' il pezzo che non si ripete.
      const casa = 'del ritiro e del silenzio';
      expect(casa.allMatches(testo).length, 1,
          reason: 'la glossa della casa compare '
              '${casa.allMatches(testo).length} volte: la Profonda paga tre '
              'voci e ne scrive due e mezza. «$testo»');
      expect(testo, contains('Venere forma anche'),
          reason: 'tolta la frase della casa, la seconda voce resta senza '
              'soggetto e non si capisce chi forma cosa');
    });
  });

  group('VOCE 2g. Il ventaglio delle forme, e la glossa detta una volta', () {
    // **I DUE DIFETTI VISTI NELLE ANTEPRIME DELLA BUILD 2148.** Tutte le
    // schede dicevano il transito con la stessa sintassi, e nella Generale la
    // glossa della decima casa compariva due volte nello stesso paragrafo,
    // per il Sole e per Giove.

    test('NESSUNA GLOSSA DI CASA compare due volte nella stessa scheda', () {
      // Scandisce un oroscopo intero, non una scheda a campione, e su tre
      // giorni distanti perche' il cielo cambia e con lui quali pianeti
      // finiscono nella stessa casa.
      for (final quando in [
        DateTime.utc(2026, 8, 5, 12),
        DateTime.utc(2026, 10, 19, 12),
        DateTime.utc(2027, 3, 2, 12),
      ]) {
        for (final profonda in [false, true]) {
          final carte = schede(cartaUna, quando, profonda: profonda);
          for (final c in carte) {
            for (final materia in CorrenteDelCielo.materiaDelleCase) {
              final quante = materia.allMatches(c.text).length;
              expect(quante, lessThanOrEqualTo(1),
                  reason: '${quando.toIso8601String().substring(0, 10)}, '
                      'scheda ${c.domain.label}, profonda $profonda: la glossa '
                      '"$materia" compare $quante volte nello stesso '
                      'paragrafo. «${c.text}»');
            }
          }
        }
      }
    });

    test('Il secondo pianeta nella stessa casa la NOMINA senza rispiegarla',
        () {
      // Il caso vero della build 2148: Sole e Giove tutti e due in decima.
      final voci = [
        for (final p in const [CorpoCeleste.sole, CorpoCeleste.giove])
          VoceDelCielo(
            transito: p,
            bersaglio: p == CorpoCeleste.sole ? 'Luna' : 'Sole',
            idBersaglio: p == CorpoCeleste.sole ? 'moon' : 'sun',
            aspetto: AspectType.trine,
            orbe: p == CorpoCeleste.sole ? 0.39 : 0.42,
            applicativo: true,
            casa: 10,
            retrogrado: false,
            giorniDiIncertezza: 0.05,
          ),
      ];
      final testo = CorrenteDelCielo.componi(
        cielo: CieloDiOggi(
            voci: voci, livello: LivelloPersonalizzazione.cartaCompleta),
        dominio: HoroscopeDomain.generale,
        profonda: true,
        giornoOrdinale: 216,
        indiceDelSegno: Zodiac.leo.index,
      )!;
      const glossa = 'quella di ciò che costruisci in pubblico';
      expect(glossa.allMatches(testo).length, 1,
          reason: 'la glossa della decima casa compare '
              '${glossa.allMatches(testo).length} volte. «$testo»');
      expect(testo, contains('Giove'),
          reason: 'il secondo pianeta e\' sparito insieme alla sua glossa');
      expect(testo, contains('nella stessa casa'),
          reason: 'il secondo pianeta non dice piu\' dove passa: tolta la '
              'glossa, e\' rimasto senza posto');
    });

    test('DUE SCHEDE dello stesso oroscopo non usano la stessa forma', () {
      // Enumerata su tutti i segni e su un anno intero, non a campione: se le
      // quattro schede coincidessero anche un giorno solo, quel giorno la
      // schermata mostrerebbe quattro volte la stessa sintassi.
      for (var segno = 0; segno < Zodiac.values.length; segno++) {
        for (var giorno = 0; giorno < 366; giorno++) {
          final forme = <FormaDellaFrase>{};
          for (final d in HoroscopeDomain.values) {
            forme.add(CorrenteDelCielo.formaDellaScheda(
                giornoOrdinale: giorno, indiceDelSegno: segno, dominio: d));
          }
          expect(forme.length, HoroscopeDomain.values.length,
              reason: 'segno $segno, giorno $giorno: le quattro schede usano '
                  '${forme.length} forme distinte invece di quattro');
        }
      }
    });

    test('Le forme sono PIU\' dei domini, ed e\' la ragione della garanzia',
        () {
      // Con quattro forme esatte l'ultima scheda ricadrebbe sulla prima: la
      // garanzia sopra regge perche' i domini sono meno delle forme.
      expect(FormaDellaFrase.values.length,
          greaterThan(HoroscopeDomain.values.length));
      expect(FormaDellaFrase.values.length, 5);
    });

    test('La forma non cambia a parita\' di giorno e segno', () {
      final una = CorrenteDelCielo.formaDellaScheda(
          giornoOrdinale: 216,
          indiceDelSegno: Zodiac.leo.index,
          dominio: HoroscopeDomain.amore);
      final altra = CorrenteDelCielo.formaDellaScheda(
          giornoOrdinale: 216,
          indiceDelSegno: Zodiac.leo.index,
          dominio: HoroscopeDomain.amore);
      expect(una, altra);
      // E cambia col giorno, altrimenti sarebbe una costante travestita.
      final forme = {
        for (var g = 0; g < 5; g++)
          CorrenteDelCielo.formaDellaScheda(
              giornoOrdinale: g,
              indiceDelSegno: Zodiac.leo.index,
              dominio: HoroscopeDomain.amore),
      };
      expect(forme.length, greaterThan(1),
          reason: 'la forma e\' la stessa in cinque giorni di fila: il '
              'ventaglio non si apre');
    });
  });

  group('VOCE 2h. Il transito non e\' un blocco incollato', () {
    test('La prima frase del cielo si aggancia a quella del segno', () {
      final carte = schede(cartaUna, giorno);
      for (final c in carte) {
        final agganci = [
          ...CorrenteDelCielo.giunturaCoiDuePunti,
          ...CorrenteDelCielo.giunturaColPunto,
        ];
        expect(agganci.any(c.text.contains), isTrue,
            reason: 'la scheda ${c.domain.label} attacca il transito senza '
                'nessun aggancio alla frase del segno: sono due testi '
                'incollati. «${c.text}»');
      }
    });

    test('Dopo i due punti non finisce mai un nome proprio di pianeta', () {
      // E' la ragione per cui le famiglie di giuntura sono due: "Marte" e
      // "Venere" la minuscola non la prendono.
      for (final c in CorpoCeleste.values) {
        final frase = CorrenteDelCielo.frase(VoceDelCielo(
          transito: c,
          bersaglio: 'Sole',
          idBersaglio: 'sun',
          aspetto: AspectType.trine,
          orbe: 1.0,
          applicativo: true,
          casa: 4,
          retrogrado: false,
          giorniDiIncertezza: 0.05,
        ));
        final conGiuntura = CorrenteDelCielo.conLaGiuntura(frase, 0);
        for (final corpo in CorpoCeleste.values) {
          expect(
              conGiuntura.contains(': ${corpo.nome.toLowerCase()} '), isFalse,
              reason: 'un nome proprio scritto minuscolo dopo i due punti: '
                  '«$conGiuntura»');
        }
      }
    });

    test('Nessuna frase porta due volte i due punti', () {
      for (final forma in FormaDellaFrase.values) {
        final frase = CorrenteDelCielo.frase(
          const VoceDelCielo(
            transito: CorpoCeleste.sole,
            bersaglio: 'Luna',
            idBersaglio: 'moon',
            aspetto: AspectType.trine,
            orbe: 0.4,
            applicativo: true,
            casa: 10,
            retrogrado: false,
            giorniDiIncertezza: 0.01,
          ),
          forma: forma,
        );
        final conGiuntura = CorrenteDelCielo.conLaGiuntura(frase, 0);
        expect(':'.allMatches(conGiuntura).length, lessThanOrEqualTo(1),
            reason: '$forma: due volte i due punti nello stesso periodo. '
                '«$conGiuntura»');
      }
    });

    test('Nessun periodo finisce con due punti fermi', () {
      for (final forma in FormaDellaFrase.values) {
        for (final certo in const [true, false]) {
          final frase = CorrenteDelCielo.frase(
            VoceDelCielo(
              transito: CorpoCeleste.saturno,
              bersaglio: 'Luna',
              idBersaglio: 'moon',
              aspetto: AspectType.square,
              orbe: 0.4,
              applicativo: true,
              casa: 10,
              retrogrado: false,
              giorniDiIncertezza: certo ? 0.5 : 5.2,
            ),
            forma: forma,
          );
          expect(frase.contains('..'), isFalse,
              reason: '$forma, giorno certo $certo: «$frase»');
        }
      }
    });

    test('Nessuna preposizione resta staccata dal suo articolo', () {
      // "Da la tua decima casa" era quello che usciva dalla forma che apre
      // con la casa: si scrive "Dalla".
      for (final forma in FormaDellaFrase.values) {
        final frase = CorrenteDelCielo.frase(
          const VoceDelCielo(
            transito: CorpoCeleste.mercurio,
            bersaglio: 'Marte',
            idBersaglio: 'mars',
            aspetto: AspectType.sextile,
            orbe: 1.0,
            applicativo: null,
            casa: 9,
            retrogrado: false,
            giorniDiIncertezza: 0.01,
          ),
          forma: forma,
        );
        for (final storta in const ['Da la ', 'da la ', 'di il ', 'a il ']) {
          expect(frase.contains(storta), isFalse,
              reason: '$forma: «$frase» contiene "$storta"');
        }
      }
    });

    test('Un pianeta femminile e\' RETROGRADA, non retrogrado', () {
      for (final c in CorpoCeleste.values) {
        final frase = CorrenteDelCielo.frase(VoceDelCielo(
          transito: c,
          bersaglio: 'Sole',
          idBersaglio: 'sun',
          aspetto: AspectType.conjunction,
          orbe: 0.2,
          applicativo: null,
          casa: 1,
          retrogrado: true,
          giorniDiIncertezza: 0.05,
        ));
        final atteso = c == CorpoCeleste.luna || c == CorpoCeleste.venere
            ? 'retrograda'
            : 'retrogrado';
        expect(frase, contains('è $atteso.'),
            reason: '${c.nome}: «${frase.split('.').first}»');
      }
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
