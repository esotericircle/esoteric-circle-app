import '../astro/aspetti_di_oggi.dart';
import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import 'cielo_di_oggi.dart';
import 'horoscope.dart';

/// LA CORRENTE DEL GIORNO SCRITTA DAL CIELO VERO, e non pescata da un pool.
///
/// **Cosa c'era prima.** La seconda meta' di ogni scheda usciva da
/// `HoroscopeData.dayPools`, un elenco di frasi generiche scelte da una hash su
/// segno, giorno e anno. Cambiava tutti i giorni, ma non perche' fosse
/// cambiato qualcosa in cielo: cambiava perche' cambiava un numero. E due
/// persone dello stesso segno, con carte natali diverse, leggevano la stessa
/// riga identica.
///
/// Qui la stessa riga nasce da [CieloDiOggi]: nomina il pianeta che si muove,
/// la casa che sta attraversando, il punto della carta natale che tocca, e se
/// e' retrogrado. Sono i quattro fatti che un astrologo previsionale dice per
/// primi.
///
/// **E QUANDO IL CIELO NON C'E', SI DICE.** Chi ha dato solo la data di nascita
/// non ha una carta, quindi non ha aspetti ne' case: il ripiego sulla hash
/// resta, ma smette di essere muto. La scheda porta [ripiegoDichiarato], e dice
/// a parole che senza ora e luogo di nascita quella riga parla al segno e non
/// al cielo di questa persona.
class CorrenteDelCielo {
  const CorrenteDelCielo._();

  /// I PIANETI CHE OGNI DOMINIO ASCOLTA.
  ///
  /// **E' la tradizione, dichiarata come tradizione.** Le signorie planetarie
  /// occidentali assegnano Venere e Marte agli affetti, il Sole con Saturno e
  /// Mercurio alla costruzione e al lavoro, Giove con Venere ai benefici. Il
  /// Generale non filtra: ascolta tutto, e prende il passaggio piu' stretto,
  /// che e' quello che oggi pesa di piu'.
  static const Map<HoroscopeDomain, Set<CorpoCeleste>> pianetiDi = {
    HoroscopeDomain.generale: {},
    HoroscopeDomain.amore: {
      CorpoCeleste.venere,
      CorpoCeleste.marte,
      CorpoCeleste.luna,
    },
    HoroscopeDomain.carriera: {
      CorpoCeleste.sole,
      CorpoCeleste.saturno,
      CorpoCeleste.marte,
      CorpoCeleste.mercurio,
    },
    HoroscopeDomain.fortuna: {
      CorpoCeleste.giove,
      CorpoCeleste.venere,
      CorpoCeleste.sole,
    },
  };

  /// LE CASE CHE OGNI DOMINIO ASCOLTA, con la stessa tradizione.
  ///
  /// Quinta il piacere e gli amori, settima i legami stabili, ottava
  /// l'intimita' e cio' che si condivide: sono le tre case degli affetti.
  /// Seconda le risorse, sesta il lavoro di ogni giorno, decima la carriera:
  /// sono le tre del fare. Seconda, quinta e undicesima raccolgono guadagni,
  /// azzardo e desideri, che e' dove la tradizione mette la fortuna. La prima
  /// e' la persona stessa, quindi sta nel Generale.
  static const Map<HoroscopeDomain, Set<int>> caseDi = {
    // Il Generale non filtra: la prima casa E' la persona, quindi il suo
    // dominio e' il cielo intero, e prende il passaggio piu' stretto qualunque
    // sia. Scriverci {1} sembrava piu' preciso ed era il contrario: nessun
    // transito cadeva in prima casa, il filtro restava vuoto, e si finiva sul
    // ripiego all'elenco intero passando per una strada che non diceva niente.
    HoroscopeDomain.generale: {},
    HoroscopeDomain.amore: {5, 7, 8},
    HoroscopeDomain.carriera: {2, 6, 10},
    HoroscopeDomain.fortuna: {2, 5, 11},
  };

  /// Gli ordinali femminili delle dodici case: "la 7a casa" a video si legge
  /// male, e in un responso non si scrive un numero con l'apice.
  static const List<String> ordinaliDelleCase = [
    'prima',
    'seconda',
    'terza',
    'quarta',
    'quinta',
    'sesta',
    'settima',
    'ottava',
    'nona',
    'decima',
    'undicesima',
    'dodicesima',
  ];

  /// COSA E' UNA CASA, in una manciata di parole.
  ///
  /// La casa dice DOVE nella vita, ed e' la meta' che rende il transito una
  /// frase invece che geometria. Le definizioni sono quelle correnti della
  /// tradizione occidentale, tenute corte apposta: un responso non e' un
  /// manuale.
  static const List<String> materiaDelleCase = [
    'di come ti presenti',
    'delle tue risorse',
    'degli scambi vicini',
    'delle radici e della casa',
    'di ciò che ti dà gioia',
    'del lavoro di ogni giorno',
    'dei legami che contano',
    'di ciò che si condivide nel profondo',
    'degli orizzonti larghi',
    'di ciò che costruisci in pubblico',
    'degli amici e dei desideri',
    'del ritiro e del silenzio',
  ];

  /// L'ASPETTO COL SUO ARTICOLO, perche' "un opposizione" a video e' un errore
  /// di italiano e "un quadratura" pure. Cinque voci, quante ne ha
  /// [AspectType]: non si compone l'articolo a regola, si scrive.
  static const Map<AspectType, String> aspettoConArticolo = {
    AspectType.conjunction: 'una congiunzione',
    AspectType.sextile: 'un sestile',
    AspectType.square: 'una quadratura',
    AspectType.trine: 'un trigono',
    AspectType.opposition: 'un\'opposizione',
  };

  /// IL NOME DI UN PIANETA COL SUO ARTICOLO.
  ///
  /// **In italiano il Sole e la Luna l'articolo ce l'hanno, gli altri no.** Si
  /// dice "il Sole sta attraversando" e "la Luna forma", ma "Venere sta
  /// attraversando" e "Marte forma": Venere e Marte sono nomi propri. La prima
  /// stesura scriveva "Sole sta attraversando la tua decima casa", che a video
  /// suona come una traduzione fatta male, e nessuna prova lo prendeva perche'
  /// le prove guardavano i fatti e non la lingua.
  static String colSuoArticolo(CorpoCeleste corpo, {bool maiuscola = true}) {
    switch (corpo) {
      case CorpoCeleste.sole:
        return maiuscola ? 'Il Sole' : 'il Sole';
      case CorpoCeleste.luna:
        return maiuscola ? 'La Luna' : 'la Luna';
      default:
        return corpo.nome;
    }
  }

  /// I PUNTI NATALI DI GENERE FEMMINILE, per l'articolo del complemento.
  ///
  /// "al tuo Luna di nascita" era quello che usciva prima, e si legge come un
  /// errore perche' lo e'. Sono due su dieci corpi, piu' i due angoli che sono
  /// maschili tutti e due: si scrivono, non si indovinano da una regola sulle
  /// desinenze, che in italiano su questi nomi non regge.
  static const Set<String> bersagliFemminili = {'moon', 'venus'};

  /// QUANTE VOCI ENTRANO NEL TESTO, per profondita'.
  ///
  /// **Una sola per la Breve, tre per la Profonda, e la differenza deve
  /// vedersi.** La Profonda era venduta e non consegnata: il selettore non era
  /// nemmeno collegato, quindi si pagava per un'etichetta. Qui la Profonda
  /// aggiunge fatti veri, non aggettivi.
  static int quanteVoci({required bool profonda}) => profonda ? 3 : 1;

  /// LE VOCI CHE PARLANO A QUESTO DOMINIO, gia' in ordine di peso.
  ///
  /// Il Generale non filtra, gli altri tre tengono le voci che nominano un
  /// loro pianeta oppure una loro casa. Se il filtro non lascia niente si
  /// ripiega sull'elenco intero invece di tacere: un dominio senza transiti
  /// suoi ha comunque un cielo sopra, ed e' meglio dire il passaggio piu'
  /// stretto che c'e' piuttosto che tornare alla hash.
  static List<VoceDelCielo> vociPer(
      CieloDiOggi cielo, HoroscopeDomain dominio) {
    final pianeti = pianetiDi[dominio]!;
    final case_ = caseDi[dominio]!;
    if (pianeti.isEmpty && case_.isEmpty) return cielo.voci;
    final sue = [
      for (final v in cielo.voci)
        if (pianeti.contains(v.transito) ||
            (v.casa != null && case_.contains(v.casa)))
          v,
    ];
    return sue.isEmpty ? cielo.voci : sue;
  }

  /// UNA VOCE DEL CIELO IN UNA FRASE.
  ///
  /// Nomina, nell'ordine: se e' retrogrado, la casa che attraversa con la sua
  /// materia, il punto natale che tocca e con quale aspetto, e se il passaggio
  /// sta arrivando oppure sta passando.
  ///
  /// **E NON DATA MAI IL TRANSITO AL GIORNO.** Quando
  /// [VoceDelCielo.ilGiornoSiPuoDire] e' falso, cioe' quando l'incertezza sul
  /// giorno esatto supera il giorno, la frase si allarga e lo dichiara: e' il
  /// caso di Saturno, che il motore posiziona benissimo e data malissimo, da
  /// 1,29 a 8,92 giorni di incertezza.
  /// [gia] contiene le case gia' nominate, per pianeta: quando una voce ripete
  /// un pianeta gia' introdotto nella stessa casa, la frase della casa si
  /// toglie e resta la ripresa. Senza questo, la Profonda scriveva due volte di
  /// fila "Venere sta attraversando la tua dodicesima casa, quella del ritiro e
  /// del silenzio", cioe' pagava tre voci per due frasi e mezza.
  static String frase(VoceDelCielo v, {Set<String> gia = const {}}) {
    final nome = colSuoArticolo(v.transito);
    final righe = <String>[];
    if (v.retrogrado && !gia.contains(_chiaveRetro(v))) {
      righe.add('$nome è retrogrado.');
    }

    final ripresa = gia.contains(_chiaveCasa(v));
    if (!ripresa) {
      if (v.casa != null) {
        righe.add('$nome sta attraversando la tua '
            '${ordinaliDelleCase[v.casa! - 1]} casa, quella '
            '${materiaDelleCase[v.casa! - 1]}.');
      } else {
        righe.add('$nome è in transito nel tuo cielo.');
      }
    }

    final aspetto = aspettoConArticolo[v.aspetto]!;
    final coda = v.applicativo == true
        ? ' che si sta stringendo'
        : v.applicativo == false
            ? ' che si sta sciogliendo'
            : '';
    // Alla ripresa il soggetto va ridetto, perche' la frase di prima non c'e'.
    final apre = ripresa ? '$nome forma anche' : 'Forma';
    if (v.ilGiornoSiPuoDire) {
      righe.add('$apre $aspetto ${_alBersaglio(v)}$coda.');
    } else {
      // La lingua si allarga, e dice perche' si allarga.
      righe.add('$apre $aspetto ${_alBersaglio(v)}$coda, '
          'un passaggio lento che matura in questi giorni senza una data '
          'precisa.');
    }
    return righe.join(' ');
  }

  static String _chiaveCasa(VoceDelCielo v) => '${v.transito.id}/${v.casa}';
  static String _chiaveRetro(VoceDelCielo v) => 'retro/${v.transito.id}';

  /// Il complemento del punto natale toccato, con l'articolo del suo genere.
  static String _alBersaglio(VoceDelCielo v) {
    if (v.idBersaglio == AspettiDiOggi.idAscendente) {
      return 'al tuo Ascendente';
    }
    if (v.idBersaglio == AspettiDiOggi.idMedioCielo) {
      return 'al tuo Medio Cielo';
    }
    return bersagliFemminili.contains(v.idBersaglio)
        ? 'alla tua ${v.bersaglio} di nascita'
        : 'al tuo ${v.bersaglio} di nascita';
  }

  /// IL TESTO DEL GIORNO PER UN DOMINIO, oppure nullo se il cielo non c'e'.
  ///
  /// Nullo vuol dire che chi compone deve ripiegare sulla hash E dichiararlo:
  /// vedi [ripiegoDichiarato].
  static String? componi({
    required CieloDiOggi cielo,
    required HoroscopeDomain dominio,
    required bool profonda,
  }) {
    if (!cielo.ceCieloVero) return null;
    final sue = vociPer(cielo, dominio);
    if (sue.isEmpty) return null;
    final gia = <String>{};
    final pezzi = <String>[];
    for (final v in sue.take(quanteVoci(profonda: profonda))) {
      pezzi.add(frase(v, gia: gia));
      gia.add(_chiaveCasa(v));
      if (v.retrogrado) gia.add(_chiaveRetro(v));
    }
    return pezzi.join(' ');
  }

  /// LA RIGA CHE DICHIARA IL RIPIEGO.
  ///
  /// **Un ripiego muto e' la cosa peggiore che questa schermata possa fare**,
  /// perche' una riga generica scritta con lo stesso carattere di una vera si
  /// legge come vera. Chi ha dato solo la data di nascita legge il suo segno,
  /// non il suo cielo, e va detto con parole sue insieme al modo di rimediare.
  static const String ripiegoDichiarato =
      'Questa lettura parla al tuo segno, non ancora al tuo cielo: senza ora '
      'e luogo di nascita i transiti sulla tua carta non si possono calcolare. '
      'Completa i dati di nascita e Medora leggerà i passaggi veri sopra di te.';

  /// La stessa riga per chi ha la carta ma non l'ora.
  static const String ripiegoSenzaOra =
      'Senza l\'ora di nascita le case non si possono calcolare: qui leggi i '
      'passaggi sui tuoi pianeti, non ancora sui settori della tua vita.';

  /// La nota da mostrare sotto le schede, per il livello raggiunto. Nulla
  /// quando il cielo e' completo: li' non c'e' niente da dichiarare.
  static String? notaDelLivello(CieloDiOggi cielo) {
    switch (cielo.livello) {
      case LivelloPersonalizzazione.soloSegno:
        return ripiegoDichiarato;
      case LivelloPersonalizzazione.cartaSenzaOra:
        return ripiegoSenzaOra;
      case LivelloPersonalizzazione.cartaCompleta:
        return null;
    }
  }
}
