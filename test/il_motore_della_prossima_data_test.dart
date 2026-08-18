import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MOTORE DELLA PROSSIMA DATA. Ordine AN voce 01.
///
/// **Le date si provano contro fonti terze, non contro se stesse.** Un
/// motore che si dichiara giusto da solo non e' provato: qui le due date
/// piu' facili da verificare fuori dal progetto, la prossima Luna piena e il
/// prossimo solstizio, si confrontano con le effemeridi pubbliche.
///
/// **E si prova la COERENZA con il motore di oggi**, che e' la garanzia che
/// non esista una seconda porta dell'astronomia: nel giorno che la prossima
/// data indica, `EventiDelCielo.diOggi` deve dire che quell'evento e'
/// attivo. Se i due divergessero, uno dei due mentirebbe.
void main() {
  test('la prossima Luna piena cade dove dicono le effemeridi', () {
    // Il 18 agosto 2026 la Luna e' calante verso la nuova del 12 agosto: la
    // piena successiva e' quella del 27 agosto 2026 (fonte terza: le
    // effemeridi pubbliche delle fasi lunari 2026).
    final elenco = ProssimiEventi.da(adesso: DateTime(2026, 8, 18));
    final piena =
        elenco.where((e) => e.evento == EventiDelCielo.lunaPiena).firstOrNull;
    expect(piena, isNotNull,
        reason: 'il motore non trova nessuna Luna piena entro l\'orizzonte: '
            'ne arriva una ogni ventinove giorni e mezzo');
    // ignore: avoid_print
    print('ORDINE AN VOCE 01: prossima Luna piena ${piena!.quando} '
        '(fra ${piena.fraQuantiGiorni} giorni)');
    expect(piena.quando.month, 8);
    expect(piena.quando.day, inInclusiveRange(26, 28),
        reason: 'la Luna piena e\' data al ${piena.quando.day} agosto, ma le '
            'effemeridi la mettono il 27');
  });

  test('il prossimo solstizio cade dove dicono le effemeridi', () {
    // Dal 18 agosto 2026 il prossimo solstizio e' quello d'inverno, il 21
    // dicembre 2026 (fonte terza: le effemeridi pubbliche).
    final elenco = ProssimiEventi.da(adesso: DateTime(2026, 8, 18));
    final solstizio =
        elenco.where((e) => e.evento == EventiDelCielo.solstizio).firstOrNull;
    expect(solstizio, isNotNull,
        reason: 'il motore non trova nessun solstizio entro l\'orizzonte');
    // ignore: avoid_print
    print('ORDINE AN VOCE 01: prossimo solstizio ${solstizio!.quando}');
    expect(solstizio.quando.month, 12);
    expect(solstizio.quando.day, inInclusiveRange(20, 22),
        reason: 'il solstizio e\' dato al ${solstizio.quando.day} dicembre, '
            'ma le effemeridi lo mettono il 21');
  });

  test('nel giorno che la prossima data indica, il motore di oggi conferma',
      () {
    // **LA COERENZA FRA LE DUE PORTE.** Se la prossima data dice che la Luna
    // piena e' il tal giorno, allora in quel giorno il motore di oggi deve
    // riconoscerla: e' cio' che dimostra che la porta dell'astronomia e' una
    // sola.
    final adesso = DateTime(2026, 8, 18);
    final elenco = ProssimiEventi.da(adesso: adesso, segno: Zodiac.leo);
    expect(elenco, isNotEmpty,
        reason: 'la prova non sta guardando niente: nessun evento in arrivo');
    var controllati = 0;
    final bugiardi = <String>[];
    for (final evento in elenco) {
      // **GLI ATTRAVERSAMENTI SI CONFRONTANO COL GIORNO DOPO, ed e' il
      // punto della correzione, non una deroga.** Il motore di oggi
      // riconosce solstizi, equinozi, ritorno solare e ritorni diretti
      // confrontando due mezzanotti: quando scatta, l'istante e' gia'
      // passato da qualche ora, quindi la data VERA e' il giorno prima e il
      // motore di oggi lo conferma il giorno dopo. Misurato sul solstizio
      // d'inverno 2026, che cade il 21 dicembre alle 15:50 UTC.
      final quandoLoVede = ProssimiEventi.attraversamenti.contains(evento.evento)
          ? DateTime(evento.quando.year, evento.quando.month,
              evento.quando.day + 1)
          : evento.quando;
      final diQuelGiorno = EventiDelCielo.diOggi(
        adesso: quandoLoVede,
        segno: Zodiac.leo,
      );
      controllati++;
      if (!diQuelGiorno.contains(evento.evento)) {
        bugiardi.add('${evento.evento}: la prossima data dice '
            '${evento.quando}, ma il motore di oggi non lo vede nemmeno il '
            '$quandoLoVede');
      }
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 01: eventi in arrivo confrontati $controllati');
    expect(controllati, greaterThan(5),
        reason: 'troppo pochi eventi confrontati: la prova gira quasi a vuoto');
    expect(bugiardi, isEmpty, reason: bugiardi.join('\n'));
  });

  test('senza segno e senza carta gli eventi personali non si calcolano', () {
    final anonimo = ProssimiEventi.da(adesso: DateTime(2026, 8, 18));
    final personali =
        anonimo.where((e) => e.personale).map((e) => e.evento).toList();
    expect(personali, isEmpty,
        reason: 'senza sapere chi sei il motore ha calcolato eventi tuoi: '
            '$personali. L\'assenza si dichiara, non si riempie');

    // Col segno, i suoi eventi compaiono.
    final conSegno =
        ProssimiEventi.da(adesso: DateTime(2026, 8, 18), segno: Zodiac.leo);
    final tuoi = conSegno.where((e) => e.personale).map((e) => e.evento);
    // ignore: avoid_print
    print('ORDINE AN VOCE 01: col segno arrivano $tuoi');
    expect(tuoi, contains(EventiDelCielo.lunaNelTuoSegno),
        reason: 'col segno noto la Luna nel tuo segno deve avere una data: '
            'ci passa ogni mese');
  });

  test('l\'elenco e\' cronologico e a parita\' di giorno vince il tuo', () {
    final elenco =
        ProssimiEventi.da(adesso: DateTime(2026, 8, 18), segno: Zodiac.leo);
    for (var i = 1; i < elenco.length; i++) {
      expect(elenco[i].fraQuantiGiorni,
          greaterThanOrEqualTo(elenco[i - 1].fraQuantiGiorni),
          reason: 'l\'elenco non e\' cronologico fra ${elenco[i - 1].evento} '
              'e ${elenco[i].evento}');
      if (elenco[i].fraQuantiGiorni == elenco[i - 1].fraQuantiGiorni &&
          elenco[i].personale) {
        expect(elenco[i - 1].personale, isTrue,
            reason: 'a parita\' di giorno un evento di tutti sta prima di uno '
                'tuo: ${elenco[i - 1].evento} prima di ${elenco[i].evento}');
      }
    }
  });

  test('gli stati continui non sono appuntamenti', () {
    final elenco =
        ProssimiEventi.da(adesso: DateTime(2026, 8, 18), segno: Zodiac.leo);
    for (final continuo in ProssimiEventi.statiContinui) {
      expect(elenco.where((e) => e.evento == continuo), isEmpty,
          reason: '$continuo compare come appuntamento: la Luna e\' sempre '
              'crescente o calante, e un calendario che lo ripete ogni '
              'giorno dice solo che il tempo passa');
    }
  });
}
