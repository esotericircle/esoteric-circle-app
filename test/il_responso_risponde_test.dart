import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL RESPONSO RISPONDE.** Ordine DL voci 07, 08, 10 e 13, 14 settembre
/// 2026.
///
/// Il fondatore ha scritto una domanda personale in tutte e quattro le
/// discese della prova della build 2250, e non ha mai ricevuto una risposta a
/// quella domanda. Da questo ordine il titolo, la risposta e il gesto li
/// scrive il modello, nella stessa chiamata della scena, e passano da guardie
/// che non si negoziano; la ripresa nomina l'oggetto della domanda; il gesto
/// dice un tempo solo.
///
/// **Ogni guardia ha la sua riga che la fa scattare, e una sola**: togliere
/// una guardia fa cadere la sua prova, perche' la riga passa o cade su
/// un'altra. E' cosi' che ciascuna e' stata vista rossa.
void main() {
  const domanda = 'Mia sorella diventerà presto mamma?';
  const neutra = CourtesyForm.neutral;

  MotivoDelloScarto? titolo(String t, {CourtesyForm forma = neutra}) =>
      LeGuardieDelResponso.delTitolo(t, domanda: domanda, forma: forma);
  MotivoDelloScarto? risposta(String r,
          {CourtesyForm forma = neutra,
          String? oggetto = 'tua sorella',
          List<String> scena = const []}) =>
      LeGuardieDelResponso.dellaRisposta(r,
          domanda: domanda,
          forma: forma,
          oggetto: oggetto,
          nomiDellaScena: scena);
  MotivoDelloScarto? azione(String a, {CourtesyForm forma = neutra}) =>
      LeGuardieDelResponso.dellAzione(a, domanda: domanda, forma: forma);

  group('LE GUARDIE DEL TITOLO, DELLA RISPOSTA E DEL GESTO', () {
    test('ogni motivo dello scarto ha una riga che lo fa scattare', () {
      final casi = <MotivoDelloScarto, MotivoDelloScarto?>{
        MotivoDelloScarto.vuota: titolo('  '),
        MotivoDelloScarto.troppoLunga:
            titolo('Il tempo di tua sorella non è il tuo'),
        MotivoDelloScarto.eUnaDomanda: titolo('Tua sorella lo sa già?'),
        MotivoDelloScarto.duePuntiNelTitolo:
            titolo('Tua sorella: il suo tempo'),
        MotivoDelloScarto.dueDuePunti:
            risposta('Una cosa: tua sorella: il suo tempo.'),
        MotivoDelloScarto.trattinoLungo:
            risposta('Tua sorella — il suo tempo è suo.'),
        MotivoDelloScarto.virgolaEe:
            risposta('Tua sorella ha il suo tempo, e tu hai il tuo.'),
        MotivoDelloScarto.primaPersona: risposta('Io vedo tua sorella serena.'),
        MotivoDelloScarto.previsioneCerta:
            risposta('Tua sorella avrà un bambino.'),
        MotivoDelloScarto.promessa:
            risposta('La gravidanza di tua sorella ha il suo ritmo.'),
        MotivoDelloScarto.diagnosi: risposta('Tua sorella non ha un disturbo.'),
        MotivoDelloScarto.nomeProprio:
            risposta('Tua sorella e Carla hanno tempi diversi.'),
        MotivoDelloScarto.genereContrario: risposta(
            'Sei pronto ad aspettare tua sorella.',
            forma: CourtesyForm.feminine),
        MotivoDelloScarto.nonNominaLaDomanda:
            risposta('Il tempo delle cose non si comanda.', oggetto: null),
        MotivoDelloScarto.anticipaLaScena: risposta(
            'Tua sorella è già sulla soglia del suo tempo.',
            scena: const ['soglia']),
        MotivoDelloScarto.consiglioDiVita:
            azione('Rifletti su tua sorella stasera.'),
        MotivoDelloScarto.senzaTempo: azione('Scrivi a tua sorella due righe.'),
        MotivoDelloScarto.toccaUnTerzo: azione('Affronta tua sorella stasera.'),
        MotivoDelloScarto.saluteDenaroLegge:
            azione('Compra un regalo per tua sorella entro sabato.'),
        // Il titolo ripetuto lo vede la lettura, che conosce i titoli gia'
        // dati: *"Il suo tempo è suo"* era gia' uscito, con un punto.
        MotivoDelloScarto.titoloRipetuto: LeGuardieDelResponso.leggi(
            {'titolo': 'il suo tempo è suo'},
            domanda: domanda,
            forma: neutra,
            titoliGiaDati: const ['Il suo tempo è suo.']).scarti.single.motivo,
      };
      // **IL CARDINALE**: tutti i motivi hanno la loro riga.
      expect(casi.keys.toSet(), MotivoDelloScarto.values.toSet());
      for (final e in casi.entries) {
        expect(e.value, e.key, reason: 'la riga del motivo ${e.key.name}');
      }
    });

    test(
        '"Tua sorella avrà un bambino" si scarta, "Non tocca a te saperlo '
        'prima di lei" no, come dice l\'ordine', () {
      expect(risposta('Tua sorella avrà un bambino.'),
          MotivoDelloScarto.previsioneCerta);
      expect(risposta('Non tocca a te saperlo prima di lei.'),
          isNot(MotivoDelloScarto.previsioneCerta));
      expect(risposta('Non tocca a te saperlo prima di tua sorella.'), isNull);
    });

    test('LE PREVISIONI SENZA FUTURO, dalla sonda col modello vero', () {
      MotivoDelloScarto? casa(String r) => LeGuardieDelResponso.dellaRisposta(r,
          domanda: "Venderò la casa prima dell'inverno?", forma: neutra);
      expect(casa('La casa è già venduta.'), MotivoDelloScarto.previsioneCerta);
      expect(casa('La casa ha già trovato un nuovo proprietario.'),
          MotivoDelloScarto.previsioneCerta);
      expect(
          LeGuardieDelResponso.dellaRisposta(
              'Il lavoro di tuo figlio non ha radici. Non è il momento giusto.',
              domanda: "Mio figlio troverà lavoro entro l'estate?",
              forma: neutra),
          MotivoDelloScarto.previsioneCerta);
      // Il passato della persona non e' una previsione.
      expect(casa('Hai già scelto la casa una volta.'), isNull);
    });

    test('le righe buone passano, nelle tre forme', () {
      for (final f in [
        CourtesyForm.masculine,
        CourtesyForm.feminine,
        CourtesyForm.neutral,
      ]) {
        expect(titolo('Il suo tempo è suo', forma: f), isNull);
        expect(
            risposta(
                'La notizia di tua sorella arriva quando lei decide. '
                'Tu puoi solo farle spazio.',
                forma: f),
            isNull);
        expect(
            azione('Stasera scrivi a tua sorella una riga, senza domande.',
                forma: f),
            isNull);
      }
    });

    test('la risposta del modello si legge, e senza domanda non si legge', () {
      final letti = LeGuardieDelResponso.leggi({
        'titolo': 'Il suo tempo è suo.',
        'risposta': 'Tua sorella avrà un bambino.',
        'azione': 'Stasera scrivi a tua sorella una riga, senza domande.',
      }, domanda: domanda, forma: neutra, oggetto: 'tua sorella');
      expect(letti.titolo, 'Il suo tempo è suo',
          reason: 'il punto in fondo al titolo si toglie');
      expect(letti.risposta, isNull);
      expect(letti.azione, isNotNull);
      expect(letti.scarti.single.motivo, MotivoDelloScarto.previsioneCerta);
      expect(
          LeGuardieDelResponso.leggi({'titolo': 'Il suo tempo'},
                  domanda: '', forma: neutra)
              .vuoti,
          isTrue);
    });
  });

  group('L\'OGGETTO DELLA DOMANDA, ordine DL voce 08', () {
    test('prende l\'articolo, le maiuscole dei nomi, e mai la prima persona',
        () {
      String? forma(String o, String d) => LaDomandaCapita.oggettoInForma(o, d);
      expect(forma('tuo lavoro', 'Sto sbagliando strada col mio lavoro?'),
          'il tuo lavoro');
      // **IL POSSESSIVO SOLO SE LA DOMANDA DICEVA MIO**: il lavoro e' del
      // figlio, e l'amico senza possessivo prende l'apostrofo.
      expect(forma('il tuo lavoro', 'Mio figlio troverà lavoro?'), 'il lavoro');
      expect(forma('il tuo amico', 'Un amico mi evita da mesi'), "l'amico");
      expect(forma('il tuo studio', 'Riprendo lo studio?'), 'lo studio');
      expect(forma('i tuoi amici', 'Gli amici mi cercano?'), 'gli amici');
      expect(forma('il tuo socio', 'Posso fidarmi del mio nuovo socio?'),
          'il tuo socio');
      expect(
          forma('tue energie', 'Dove metto le mie energie?'), 'le tue energie');
      expect(forma('tua sorella', 'Sua sorella mi scriverà?'), 'la sorella');
      expect(forma('tua sorella', domanda), 'tua sorella',
          reason: 'la parentela al singolare non vuole l\'articolo');
      expect(
          forma('giulia nella tua vita', 'Che posto ha Giulia nella mia vita?'),
          'Giulia nella tua vita');
      expect(forma('il trasloco', 'Devo fare il trasloco?'), 'il trasloco');
      expect(forma('dove sto andando', 'Non so più dove sto andando'), isNull,
          reason: 'la prima persona torna in bocca a chi legge');
      expect(forma('niente di tuo', 'Non riesco a finire niente'), isNull,
          reason: 'niente non nomina niente');
      expect(
          forma('trasferimento', 'Accetto il trasferimento a Milano?'), isNull,
          reason: 'senza articolo non si cuce alla preposizione');
      expect(forma('tuo marito', domanda), isNull,
          reason: 'il marito la domanda non lo nomina');
    });

    test('"su" davanti all\'oggetto prende l\'articolo', () {
      expect(LaVoceDelMondoDiSotto.suLOggetto('il trasloco'), 'sul trasloco');
      expect(LaVoceDelMondoDiSotto.suLOggetto("l'estate"), "sull'estate");
      expect(LaVoceDelMondoDiSotto.suLOggetto('gli esami'), 'sugli esami');
      expect(LaVoceDelMondoDiSotto.suLOggetto('la tua casa'), 'sulla tua casa');
      expect(LaVoceDelMondoDiSotto.suLOggetto('tua sorella'), 'su tua sorella');
      expect(LaVoceDelMondoDiSotto.suLOggetto('Giulia'), 'su Giulia');
    });

    test('la ripresa nomina l\'oggetto, e senza oggetto nomina il tema', () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      final storia = <UnViaggio>[];
      var conOggetto = 0;
      for (var i = 0; i < 24; i++) {
        final giorno = DateTime(2026, 9, 14).add(Duration(days: i));
        final r = IlResponsoDelViaggio.componi(
          dalModello: null,
          domanda: 'Devo fare il trasloco?',
          giorno: giorno,
          nitidezza: 1,
          discesa: i,
          giaOggi: 0,
          animale: animale,
          tema: TemaDellaDomanda.scelta,
          storia: storia,
          oggetto: 'il trasloco',
        );
        final p = r.paragrafi.first;
        expect(p, isNot(contains('su il ')), reason: p);
        if (p.contains('il trasloco') || p.contains('sul trasloco')) {
          conOggetto++;
        }
        storia.insert(
            0,
            r.comeSiConserva(
                quando: giorno,
                domanda: 'Devo fare il trasloco?',
                temaDellaDomanda: 'scelta',
                animaleSeguito: animale.name,
                nitidezza: 1));
      }
      expect(conOggetto, 24, reason: 'ogni ripresa nomina il trasloco');
      final senza = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: 'Devo fare il trasloco?',
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.scelta,
        storia: const [],
      );
      expect(senza.paragrafi.first, isNot(contains('trasloco')));
    });
  });

  group('I TESTI DEL MODELLO NEL RESPONSO E NEL DIARIO', () {
    test(
        'prendono il posto di quelli di casa, e il Diario conserva quelli e '
        'la loro fonte', () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      const scritti = TestiDelModello(
        titolo: 'Il suo tempo è suo',
        risposta: 'La notizia di tua sorella arriva quando lei decide.',
        azione: 'Stasera scrivi a tua sorella una riga, senza domande.',
      );
      final r = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: domanda,
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.attesa,
        storia: const [],
        scritti: scritti,
        oggetto: 'tua sorella',
        fontiGiaNote: const {'tema': 'modello'},
      );
      expect(r.titolo, scritti.titolo);
      expect(r.paragrafi[0], scritti.risposta);
      // La cucitura mette la minuscola dopo i due punti dell'apertura.
      expect(r.paragrafi[1],
          endsWith('stasera scrivi a tua sorella una riga, senza domande.'));
      expect(r.fonti, {
        'scena': 'riserva',
        'titolo': 'modello',
        'risposta': 'modello',
        'gesto': 'modello',
        'tema': 'modello',
      });
      final v = r.comeSiConserva(
          quando: DateTime(2026, 9, 14),
          domanda: domanda,
          temaDellaDomanda: 'attesa',
          animaleSeguito: animale.name,
          nitidezza: 1);
      final riletto = UnViaggio.fromJson(v.toJson())!;
      expect(riletto.titolo, scritti.titolo);
      expect(riletto.risposta, scritti.risposta);
      expect(riletto.gesto, scritti.azione);
      expect(riletto.oggetto, 'tua sorella');
      expect(riletto.fonti['gesto'], 'modello');
    });

    test('un testo scartato lascia la riserva, e la fonte dice perché', () {
      final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
      final letti = LeGuardieDelResponso.leggi({
        'titolo': 'Il suo tempo è suo',
        'risposta': 'Tua sorella avrà un bambino.',
        'azione': 'Affronta tua sorella stasera.',
      }, domanda: domanda, forma: neutra);
      final r = IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: domanda,
        giorno: DateTime(2026, 9, 14),
        nitidezza: 1,
        discesa: 0,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.attesa,
        storia: const [],
        scritti: letti,
      );
      expect(r.fonti['titolo'], 'modello');
      expect(r.fonti['risposta'], 'riserva: previsioneCerta');
      expect(r.fonti['gesto'], 'riserva: toccaUnTerzo');
      expect(r.paragrafi[0], isNot(contains('avrà')));
    });
  });

  test('LE FONTI DEL TEMPO SI CONTANO PER PEZZO', () {
    // **LA GRANDEZZA E' IL PEZZO CHE PORTA IL TEMPO, NON LA PAROLA**: *"nei
    // prossimi tre giorni"* e' un tempo solo e fa due riscontri, e il gesto
    // *"dormici una notte e rileggi domattina"* e' autosufficiente, come lo
    // chiama l'ordine. Il difetto della build 2250 era un tempo nel gesto e
    // un altro nel quando.
    expect(
        _fontiDelTempo(
            'Una cosa sola: esci a camminare. Nei prossimi tre giorni.'),
        1);
    expect(
        _fontiDelTempo(
            'Una cosa sola: dormici una notte e rileggi questa riga domattina.'),
        1);
    expect(
        _fontiDelTempo(
            'Una cosa sola: dormici una notte e rileggi questa riga domattina. Entro stasera.'),
        2);
    expect(_fontiDelTempo('Il passo di oggi: esci a camminare. Entro stasera.'),
        2);
    expect(
        _fontiDelTempo(
            'Il passo di oggi: datti tre giorni. Alla fine scegli comunque.'),
        2);
  });

  test(
      'NESSUN GESTO DICE DUE TEMPI, su trecento discese per tema e senza '
      'tema. Ordine DL voce 10', () {
    final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
    final doppi = <String>[];
    var guardati = 0;
    var colTempoProprio = 0;
    for (final tema in [...TemaDellaDomanda.values, null]) {
      final storia = <UnViaggio>[];
      for (var i = 0; i < 300; i++) {
        final giorno = DateTime(2026, 9, 14).add(Duration(days: i));
        final d = tema == null ? '' : 'Una domanda sul tema ${tema.name}';
        final r = IlResponsoDelViaggio.componi(
          dalModello: null,
          domanda: d,
          giorno: giorno,
          nitidezza: 1,
          discesa: i,
          giaOggi: 0,
          animale: animale,
          tema: tema,
          storia: storia,
        );
        final gesto = r.paragrafi[1];
        guardati++;
        if (LaVoceDelMondoDiSotto.gestiColTempo.any((g) =>
            gesto.toLowerCase().contains(g.toLowerCase().substring(1)))) {
          colTempoProprio++;
        }
        if (_fontiDelTempo(gesto) > 1) doppi.add(gesto);
        storia.insert(
            0,
            r.comeSiConserva(
                quando: giorno,
                domanda: d,
                temaDellaDomanda: tema?.name ?? '',
                animaleSeguito: animale.name,
                nitidezza: 1));
        if (storia.length > 60) storia.removeLast();
      }
    }
    // **IL CARDINALE**: settecento responsi, e fra loro i gesti che il
    // tempo lo portano dentro, che sono quelli che la voce prende.
    expect(guardati, 2100);
    expect(colTempoProprio, greaterThan(100));
    expect(doppi, isEmpty,
        reason: '${doppi.length} gesti con due tempi, per esempio:\n'
            '${doppi.take(5).join('\n')}');
  });
}

/// **QUANTI PEZZI DEL PARAGRAFO DEL GESTO DICONO UN TEMPO**: l'apertura, il
/// gesto e il quando. Ordine DL voce 10: *"nessun responso ha due
/// indicazioni di tempo"*.
int _fontiDelTempo(String paragrafo) {
  final p = paragrafo.trim();
  final basso = p.toLowerCase();
  String? apre;
  for (final a in LaVoceDelMondoDiSotto.apreIlGesto) {
    final senza = a.substring(0, a.length - 1).toLowerCase();
    if (basso.startsWith(senza)) apre = a;
  }
  String? quando;
  for (final q in LaVoceDelMondoDiSotto.quando) {
    if (basso.endsWith(q.toLowerCase())) quando = q;
  }
  var resto = p.substring(apre == null ? 0 : apre.length);
  if (quando != null) resto = resto.substring(0, resto.length - quando.length);
  bool conTempo(String? s) =>
      s != null && LeGuardieDelResponso.indicazioneDiTempo.hasMatch(s);
  return [conTempo(apre), conTempo(resto), conTempo(quando)]
      .where((x) => x)
      .length;
}
