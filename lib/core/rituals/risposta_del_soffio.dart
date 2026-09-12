import '../astro/effemeridi.dart';
import '../astro/moon_phase.dart';
import '../astro/night_sky.dart';
import 'risposta_del_dono.dart';
import '../astro/natal_chart.dart';
import '../horoscope/cielo_di_oggi.dart';

/// LA RISPOSTA DEL SOFFIO: cosa si apre oggi, e cosa oggi non si lascia
/// forzare.
///
/// **Perche' il Soffio lascia una risposta e non altro.** Il Rito dell'Alba
/// chiude con una parola e un gesto, e il Soffio non deve somigliargli: se i
/// due riti finissero nello stesso modo, farne due sarebbe un raddoppio.
/// Il nome dice cosa promette: si soffia una domanda e torna una risposta.
///
/// **Due righe, e nessuna delle due comanda.** Non c'e' una domanda alla
/// persona, non c'e' un compito da eseguire, non c'e' un esito promesso, e non
/// c'e' un verbo all'imperativo. L'imperativo e' la forma dell'Alba, che
/// infatti dice "volgi lo sguardo", "appoggia le mani": qui si dichiara come
/// sta il cielo, e cosa se ne fa lo decide chi legge.
///
/// **Esce dai transiti veri, dalla porta che c'e' gia'.**
/// `CieloDiOggi.perIlGiorno` e' la stessa porta dell'Oroscopo e del Rito
/// dell'Alba. Non se ne apre una seconda: due porte sullo stesso cielo
/// possono dire due cose diverse nella stessa mattina, ed e' il difetto che
/// questo progetto ha gia' pagato piu' volte.
///
/// **Se il transito che una variante nomina non c'e', la variante non entra.**
/// Non esiste una riga di ripiego che parli lo stesso: quando il cielo non
/// offre un aspetto morbido, la riga di cio' che si apre semplicemente non
/// compare, e cosi' l'altra. Se non ne compare nessuna, non c'e' risposta, e
/// chi la mostra deve dirlo invece di inventarla.
class RispostaDelSoffio {
  const RispostaDelSoffio({required this.apre, required this.nonForzare});

  /// La porta che il cielo tiene aperta adesso. Nulla se oggi non c'e' un
  /// aspetto morbido: meglio una riga in meno di una riga che finge.
  final String? apre;

  /// Quella che oggi e' meglio non forzare. Nulla se oggi non c'e' un aspetto
  /// teso, il che accade davvero e non e' un guasto.
  final String? nonForzare;

  /// Vero quando c'e' almeno una delle due righe.
  bool get ceQualcosa => apre != null || nonForzare != null;

  /// **IL TITOLO E LA RISPOSTA DEL SOFFIO, DALLA SUA MATERIA.**
  /// Ordine CQ voce 2.02, 3 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** l'Alba e il Soffio danno risposte
  /// identiche.
  ///
  /// **La causa, misurata.** Il Soffio costruisce il suo dono con
  /// `DawnGift.forMaestro`, che dentro chiama `RitoAlba.diOggi` con la sola
  /// data: **il rito, la parola e la risposta erano letteralmente gli stessi
  /// oggetti dell'Alba.** Cambiava il Maestro nella cornice e nient'altro. Due
  /// Doni che dicono la stessa cosa a due ore di distanza sono un Dono solo
  /// mostrato due volte.
  ///
  /// **E il Soffio la sua materia ce l'aveva gia'**, ed e' questa classe: i
  /// transiti veri sulla carta di questa persona, cio' che si apre e cio' che
  /// non si lascia forzare. Stava piu' in basso nella schermata, sotto la
  /// risposta di un altro rito. Adesso sale in cima, dove la legge dei testi
  /// vuole la risposta.
  ///
  /// **Il titolo e' una frase chiusa e non promette niente**, come i nove del
  /// Risveglio: dice come sta il cielo di oggi per questa persona, e chi legge
  /// solo quella riga ha gia' ricevuto qualcosa.
  /// **IL TITOLO DICE A COSA SERVE IL RESPIRO DI OGGI.** Ordine del fondatore
  /// del 7 settembre 2026: *"non serve un rito da compiere per il soffio, c'e'
  /// gia' la respirazione da compiere, ma bisogna dichiarare a cosa serve,
  /// cosa si ottiene quel giorno facendo il respiro"*.
  ///
  /// Prima il titolo descriveva il cielo e basta, *"oggi il tuo cielo ha una
  /// porta aperta"*: vero e inutile, perche' non diceva cosa farne. Adesso
  /// nomina **cio' che il respiro di oggi ti da'**, e il fatto del cielo resta
  /// sotto, come ragione di quel che si e' appena promesso.
  RispostaDelDono comeRisposta() {
    final titolo = switch ((apre != null, nonForzare != null)) {
      (true, true) => 'Il respiro di oggi ti serve a riconoscere dove passare '
            'e dove non spingere.',
      (true, false) =>
        'Il respiro di oggi ti serve a riconoscere dove passare.',
      (false, true) =>
        'Il respiro di oggi ti serve a non spingere dove oggi non cede.',
      _ => 'Il respiro di oggi ti serve solo a fermarti.',
    };
    final righe = [
      if (apre != null) apre!,
      if (nonForzare != null) nonForzare!,
    ];
    return RispostaDelDono(
      titolo: titolo,
      risposta: righe.join(' '),
    );
  }

  /// **COSA DA' IL RESPIRO DI OGGI QUANDO IL CIELO SOPRA DI TE NON SI LEGGE.**
  ///
  /// **Il difetto che questo metodo chiude, misurato il 7 settembre 2026.**
  /// Parole del fondatore: *"i responsi di Alba e Soffio sono ancora uguali"*.
  /// La riparazione dell'ordine CQ voce 2.02 era vera ma **condizionata**:
  /// [diOggi] torna nulla senza transiti veri, cioe' senza carta natale
  /// completa, e allora `DawnGift.forMaestro` restituiva il rito dell'Alba
  /// intero, risposta compresa. Misurato sullo stesso giorno: **senza carta le
  /// due risposte erano identiche parola per parola**, con la carta no. La
  /// condizione non era scritta da nessuna parte.
  ///
  /// **La materia di questo ripiego non e' la carta natale, e' la Luna di
  /// oggi**: la sua fase e il segno che attraversa. Sono fatti astronomici
  /// veri, calcolati sulle stesse effemeridi del resto dell'app, e **non
  /// dipendono da nessun dato che la persona debba dare**. Cambiano ogni
  /// giorno, quindi due Doni non possono ricadere sulla stessa frase.
  ///
  /// **La lettura e' del Cerchio, e va dichiarata come tale**: la fase e il
  /// segno vengono dal cielo, cosa farne col respiro lo scrive il Cerchio.
  static RispostaDelDono senzaIlTuoCielo(DateTime giorno) {
    final luna = MoonPhase.forDate(giorno);
    final segno = NightSky.moonSign(giorno);
    final nome = luna.italianName.toLowerCase();
    final titolo = switch (nome) {
      'luna nuova' =>
        'Il respiro di oggi ti serve a nominare una cosa che vuoi cominciare.',
      'luna piena' =>
        'Il respiro di oggi ti serve a vedere cosa è già arrivato.',
      _ => luna.waxing
          ? 'Il respiro di oggi ti serve a raccogliere le forze su una cosa '
              'sola.'
          : 'Il respiro di oggi ti serve a lasciare andare una cosa che pesa.',
    };
    final verso = luna.waxing ? 'cresce' : 'cala';
    return RispostaDelDono(
      titolo: titolo,
      risposta: 'La Luna oggi $verso in ${segno.italianName}: è la luce '
          'che si muove più in fretta di tutte. Il respiro non cambia il '
          'cielo: ti mette nel passo in cui il cielo si trova adesso.',
    );
  }

  /// LA RISPOSTA DI OGGI, dai transiti veri sulla carta di questa persona.
  ///
  /// Nulla quando il cielo non e' stato interrogato davvero, cioe' quando la
  /// carta manca: senza ora e luogo di nascita non ci sono transiti sulla
  /// carta, e una risposta senza cielo sarebbe un oroscopo da giornale.
  static RispostaDelSoffio? diOggi(CieloDiOggi cielo) {
    if (!cielo.ceCieloVero) return null;
    // LE VOCI ARRIVANO GIA' ORDINATE PER ORBO CRESCENTE, cioe' dalla piu'
    // stretta: la prima di ogni famiglia e' quella che oggi pesa di piu'.
    final morbida = _prima(cielo, AspectHarmony.soft);
    final tesa = _prima(cielo, AspectHarmony.hard);
    final r = RispostaDelSoffio(
      apre: morbida == null ? null : _apre(morbida),
      nonForzare: tesa == null ? null : _nonForzare(tesa),
    );
    return r.ceQualcosa ? r : null;
  }

  static VoceDelCielo? _prima(CieloDiOggi cielo, AspectHarmony armonia) {
    for (final v in cielo.voci) {
      if (v.aspetto.harmony == armonia) return v;
    }
    return null;
  }

  /// La riga di cio' che si apre. Dichiarativa, e nomina il transito da cui
  /// viene: chi legge deve poter risalire al cielo, non fidarsi.
  static String _apre(VoceDelCielo v) =>
      'Oggi si apre ${_terreno[v.transito]!}, '
      'con ${v.transito.nome} in ${v.aspetto.italianName.toLowerCase()} '
      'al tuo ${v.bersaglio}.';

  /// La riga di cio' che non si lascia forzare. Anche questa dichiarativa: dice
  /// come sta il cielo, non cosa fare, e soprattutto non promette che
  /// aspettare funzionera'.
  static String _nonForzare(VoceDelCielo v) =>
      'Non si lascia forzare ${_terreno[v.transito]!}, '
      'con ${v.transito.nome} in ${v.aspetto.italianName.toLowerCase()} '
      'al tuo ${v.bersaglio}.';

  /// IL TERRENO DI OGNI CORPO, cioe' su cosa quel pianeta ha voce.
  ///
  /// Tradizione astrologica di base, la stessa che regge il resto dell'app: la
  /// significazione classica dei pianeti. Sono nomi di ambito, non predizioni,
  /// e per questo funzionano sia per cio' che si apre sia per cio' che non
  /// cede: e' lo stesso terreno, guardato da due parti.
  /// **Nessuna di queste voci contiene un verbo che possa leggersi come un
  /// comando.** Due lo contenevano, "ti fai riconoscere" e "ti fai capire": in
  /// italiano `fai` e' insieme indicativo e imperativo, e la prova che vieta la
  /// forma dell'Alba le ha prese. Riscritte, invece di ammorbidire la prova:
  /// una regola che si allarga per far passare il caso di oggi non sorveglia
  /// piu' niente domani.
  static const Map<CorpoCeleste, String> _terreno = {
    CorpoCeleste.sole: 'il modo in cui gli altri ti riconoscono',
    CorpoCeleste.luna: 'quello che senti prima di capirlo',
    CorpoCeleste.mercurio: 'il modo in cui le tue parole arrivano',
    CorpoCeleste.venere: 'cio' ' che ti avvicina agli altri',
    CorpoCeleste.marte: 'la spinta con cui cominci le cose',
    CorpoCeleste.giove: 'lo spazio che ti concedi',
    CorpoCeleste.saturno: 'quello che stai costruendo con pazienza',
    CorpoCeleste.urano: 'cio' ' che vuole cambiare forma',
    CorpoCeleste.nettuno: 'quello che immagini prima di vederlo',
    CorpoCeleste.plutone: 'cio' ' che stai lasciando andare',
  };
}
